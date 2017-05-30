/*
 * File:
 *   stm_numa.h
 * Author(s):
 *   Pascal Felber <pascal.felber@unine.ch>
 *   Patrick Marlier <patrick.marlier@unine.ch>
 * Description:
 *   STM internal functions for Write-back ETL.
 *
 * Copyright (c) 2007-2012.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, version 2
 * of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * This program has a dual license and can also be distributed
 * under the terms of the MIT license.
 */

#ifndef _STM_NUMA_H_
#define _STM_NUMA_H_

#include "stm_internal.h"
#include "atomic.h"


static INLINE stm_word_t
stm_numa_extend(stm_tx_t *tx, stm_word_t t)
{
  r_entry_t *r;
  int i;
  stm_word_t l;

  PRINT_DEBUG("==> stm_numa_extend(%p[%lu])\n", tx, (unsigned long)tx->clock);

  /* Extend reads */
  r = tx->r_set.entries;
  for (i = tx->r_set.nb_entries; i > 0; i--, r++) {
    /* Read lock */
    l = ATOMIC_LOAD(r->lock);
    /* Unlocked and still the same version? */
    if (LOCK_GET_OWNED(l)) {
      /* Do we own the lock? */
      w_entry_t *w = (w_entry_t *)LOCK_GET_ADDR(l);
      /* Simply check if address falls inside our write set (avoids non-faulting load) */
      if (!(tx->w_set.entries <= w && w < tx->w_set.entries + tx->w_set.nb_entries))
      {
        /* Locked by another transaction: cannot extend */
        return VERSION_MAX;
      }
      /* We own the lock: OK */
    } else {
      if (LOCK_GET_TIMESTAMP(l) != r->version) {
        /* Other version: cannot extend */
        return VERSION_MAX;
      }
      /* Same version: OK */
    }
  }
  
  assert ( t >= tx->clock );
  tx->clock = t;
  return t;
}


static INLINE void
stm_numa_rollback(stm_tx_t *tx)
{
  w_entry_t *w;
  int i;

  PRINT_DEBUG("==> stm_numa_rollback(%p[%lu])\n", tx, (unsigned long)tx->clock);

  assert(IS_ACTIVE(tx->status));

  /* Drop locks */
  i = tx->w_set.nb_entries;
  if (i > 0) {
    w = tx->w_set.entries;
    for (; i > 0; i--, w++) {
      if (w->next == NULL) {
        /* Only drop lock for last covered address in write set */
        ATOMIC_STORE(w->lock, LOCK_SET_TIMESTAMP(w->version));
      }
    }
    /* Make sure that all lock releases become visible */
    ATOMIC_MB_WRITE;
  }
}

/*
 * Load a word-sized value (invisible read).
 */
static INLINE stm_word_t
stm_numa_read_invisible(stm_tx_t *tx, volatile stm_word_t *addr)
{
  volatile stm_word_t *lock;
  stm_word_t l, l2, value, version;
  r_entry_t *r;
  w_entry_t *w;

  PRINT_DEBUG2("==> stm_numa_read_invisible(t=%p[%lu],a=%p)\n", tx, (unsigned long)tx->clock, addr);

  assert(IS_ACTIVE(tx->status));

  /* Get reference to lock */
  lock = GET_LOCK(addr);

  /* FIXME check for duplicate reads and get value from read set */

  /* Read lock, value, lock */
 restart:
  l = ATOMIC_LOAD_ACQ(lock);
 restart_no_load:
  if (unlikely(LOCK_GET_WRITE(l))) {
    /* Locked */
    /* Do we own the lock? */
    w = (w_entry_t *)LOCK_GET_ADDR(l);
    /* Simply check if address falls inside our write set (avoids non-faulting load) */
    if (likely(tx->w_set.entries <= w && w < tx->w_set.entries + tx->w_set.nb_entries)) {
      /* Yes: did we previously write the same address? */
      while (1) {
        if (addr == w->addr) {
          /* Yes: get value from write set (or from memory if mask was empty) */
          value = (w->mask == 0 ? ATOMIC_LOAD(addr) : w->value);
          break;
        }
        if (w->next == NULL) {
          /* No: get value from memory */
          value = ATOMIC_LOAD(addr);
          break;
        }
        w = w->next;
      }
      /* No need to add to read set (will remain valid) */
      return value;
    }

    /* Conflict: CM kicks in (we could also check for duplicate reads and get value from read set) */
    /* Abort */
    stm_rollback(tx, STM_ABORT_RW_CONFLICT);
    return 0;
  } else {
    /* Not locked */
    value = ATOMIC_LOAD_ACQ(addr);
    l2 = ATOMIC_LOAD_ACQ(lock);
    if (unlikely(l != l2)) {
      l = l2;
      goto restart_no_load;
    }
    /* Check timestamp */
    version = LOCK_GET_TIMESTAMP(l);

    /* If already read, we cannot see another version. */
    // TODO make it reverse order
    r = stm_has_read(tx, lock);
    if (r != NULL) {
      if (r->version != version) {
        stm_rollback(tx, STM_ABORT_VALIDATE);
        return 0;
      } else {
        /* Same version, just return the value */
        goto return_value;
      }
    }

    /* Valid version? */
    if (unlikely(version > tx->clock)) {

      /* Extend snapshot? */
      if (stm_numa_extend(tx, version) == VERSION_MAX) {
        stm_rollback(tx, STM_ABORT_VAL_READ);
        return 0;
      }

      /* Verify that version has not been overwritten (read value has not
       * yet been added to read set and may have not been checked during
       * extend) */
      l2 = ATOMIC_LOAD_ACQ(lock);
      if (l != l2) {
        l = l2;
        goto restart_no_load;
      }

    }

    /* Add address and version to read set */
    if (tx->r_set.nb_entries == tx->r_set.size)
      stm_allocate_rs_entries(tx, 1);
    r = &tx->r_set.entries[tx->r_set.nb_entries++];
    r->version = version;
    r->lock = lock;

  }

 return_value:
  return value;
}

static INLINE stm_word_t
stm_numa_read(stm_tx_t *tx, volatile stm_word_t *addr)
{
  return stm_numa_read_invisible(tx, addr);
}

static INLINE w_entry_t *
stm_numa_write(stm_tx_t *tx, volatile stm_word_t *addr, stm_word_t value, stm_word_t mask)
{
  volatile stm_word_t *lock;
  stm_word_t l, version;
  r_entry_t *r;
  w_entry_t *w;
  w_entry_t *prev = NULL;

  PRINT_DEBUG2("==> stm_numa_write(t=%p[%lu],a=%p,d=%p-%lu,m=0x%lx)\n",
               tx, (unsigned long)tx->clock, addr, (void *)value, (unsigned long)value, (unsigned long)mask);

  /* Get reference to lock */
  lock = GET_LOCK(addr);

  /* Try to acquire lock */
 restart:
  l = ATOMIC_LOAD_ACQ(lock);
 restart_no_load:
  if (unlikely(LOCK_GET_OWNED(l))) {
    /* Locked */

    /* Do we own the lock? */
    w = (w_entry_t *)LOCK_GET_ADDR(l);
    /* Simply check if address falls inside our write set (avoids non-faulting load) */
    if (likely(tx->w_set.entries <= w && w < tx->w_set.entries + tx->w_set.nb_entries)) {
      /* Yes */
      if (mask == 0) {
        /* No need to insert new entry or modify existing one */
        return w;
      }
      prev = w;
      /* Did we previously write the same address? */
      while (1) {
        if (addr == prev->addr) {
          /* No need to add to write set */
          if (mask != ~(stm_word_t)0) {
            if (prev->mask == 0)
              prev->value = ATOMIC_LOAD(addr);
            value = (prev->value & ~mask) | (value & mask);
          }
          prev->value = value;
          prev->mask |= mask;
          return prev;
        }
        if (prev->next == NULL) {
          /* Remember last entry in linked list (for adding new entry) */
          break;
        }
        prev = prev->next;
      }
      /* Get version from previous write set entry (all entries in linked list have same version) */
      version = prev->version;
      /* Must add to write set */
      if (tx->w_set.nb_entries == tx->w_set.size)
        stm_rollback(tx, STM_ABORT_EXTEND_WS);
      w = &tx->w_set.entries[tx->w_set.nb_entries];
      goto do_write;
    }
    /* Conflict: CM kicks in */
    /* Abort */
    stm_rollback(tx, STM_ABORT_WW_CONFLICT);
    return NULL;
  }

  /* Not locked */
  version = LOCK_GET_TIMESTAMP(l);

  r = stm_has_read(tx, lock);
  if (r != NULL) {
    if (r->version != version) {
      stm_rollback(tx, STM_ABORT_VALIDATE);
      return 0;
    }
  }

  /* We own the lock here (ETL) */
  if (unlikely(version > tx->clock)) {
    if (stm_numa_extend(tx, version) == VERSION_MAX) {
      /* Unlock  and abort */
      stm_rollback(tx, STM_ABORT_VAL_WRITE);
      return NULL;
    }
  }

 acquire:
  /* Acquire lock (ETL) */
  if (unlikely(tx->w_set.nb_entries == tx->w_set.size))
    stm_rollback(tx, STM_ABORT_EXTEND_WS);
  w = &tx->w_set.entries[tx->w_set.nb_entries];
  if (unlikely(ATOMIC_CAS_FULL(lock, l, LOCK_SET_ADDR_WRITE((stm_word_t)w)) == 0)){
      stm_rollback(tx, STM_ABORT_VAL_WRITE);
      return NULL;
  }

do_write:
  /* Add address to write set */
  w->addr = addr;
  w->mask = mask;
  w->lock = lock;
  if (unlikely(mask == 0)) {
    /* Do not write anything */
#ifndef NDEBUG
    w->value = 0;
#endif /* ! NDEBUG */
  } else {
    /* Remember new value */
    if (mask != ~(stm_word_t)0)
      value = (ATOMIC_LOAD(addr) & ~mask) | (value & mask);
    w->value = value;
  }
  w->version = version;
  w->next = NULL;
  if (prev != NULL) {
    /* Link new entry in list */
    prev->next = w;
  }
  tx->w_set.nb_entries++;
  tx->w_set.has_writes++;

  return w;
}

static INLINE stm_word_t
stm_numa_RaR(stm_tx_t *tx, volatile stm_word_t *addr)
{
  /* Possible optimization: avoid adding to read set again */
  return stm_numa_read(tx, addr);
}

static INLINE stm_word_t
stm_numa_RaW(stm_tx_t *tx, volatile stm_word_t *addr)
{
  stm_word_t l;
  w_entry_t *w;

  l = ATOMIC_LOAD_ACQ(GET_LOCK(addr));
  /* Does the lock owned? */
  assert(LOCK_GET_WRITE(l));
  /* Do we own the lock? */
  w = (w_entry_t *)LOCK_GET_ADDR(l);
  assert(tx->w_set.entries <= w && w < tx->w_set.entries + tx->w_set.nb_entries);

  /* Read directly from write set entry. */
  return w->value;
}

static INLINE stm_word_t
stm_numa_RfW(stm_tx_t *tx, volatile stm_word_t *addr)
{
  /* Acquire lock as write. */
  stm_numa_write(tx, addr, 0, 0);
  /* Now the lock is owned, read directly from memory is safe. */
  /* TODO Unsafe with CM_MODULAR */
  return *addr;
}

static INLINE void
stm_numa_WaR(stm_tx_t *tx, volatile stm_word_t *addr, stm_word_t value, stm_word_t mask)
{
  /* Probably no optimization can be done here. */
  stm_numa_write(tx, addr, value, mask);
}

static INLINE void
stm_numa_WaW(stm_tx_t *tx, volatile stm_word_t *addr, stm_word_t value, stm_word_t mask)
{
  stm_word_t l;
  w_entry_t *w;

  l = ATOMIC_LOAD_ACQ(GET_LOCK(addr));
  /* Does the lock owned? */
  assert(LOCK_GET_WRITE(l));
  /* Do we own the lock? */
  w = (w_entry_t *)LOCK_GET_ADDR(l);
  assert(tx->w_set.entries <= w && w < tx->w_set.entries + tx->w_set.nb_entries);
  /* in WaW, mask can never be 0 */
  assert(mask != 0);
  while (1) {
    if (addr == w->addr) {
      /* No need to add to write set */
      if (mask != ~(stm_word_t)0) {
        if (w->mask == 0)
          w->value = ATOMIC_LOAD(addr);
        value = (w->value & ~mask) | (value & mask);
      }
      w->value = value;
      w->mask |= mask;
      return;
    }
    /* The entry must exist */
    assert (w->next != NULL);
    w = w->next;
  }
}

static INLINE int
stm_numa_commit(stm_tx_t *tx)
{
  w_entry_t *w;
  stm_word_t t, clock;
  unsigned int i;

  PRINT_DEBUG("==> stm_numa_commit(%p[%lu])\n", tx, (unsigned long)tx->clock);

  /* Try to validate */
  t = stm_numa_extend(tx, tx->clock);
  if (t == VERSION_MAX) {
    /* Cannot commit */
    stm_rollback(tx, STM_ABORT_VALIDATE);
    return 0;
  }

  /* Advance the timestamp by 1 */
  /* Set the numa clock to this value if below */
  
  t++;
  clock = GET_CLOCK;
  if (t > clock) {
#if defined(GLOBAL_CLOCK)
    assert(0);
#endif
    while (t > clock && CAS_CLOCK(clock, t) == 0) {
      clock = GET_CLOCK;
    }
  }

  /* Install new versions, drop locks and set new timestamp */
  w = tx->w_set.entries;
  for (i = tx->w_set.nb_entries; i > 0; i--, w++) {
    if (w->mask != 0)
      ATOMIC_STORE(w->addr, w->value);
    /* Only drop lock for last covered address in write set */
    if (w->next == NULL) {
      assert(t > w->version);
      ATOMIC_STORE_REL(w->lock, LOCK_SET_TIMESTAMP(t));
    }
  }
  
  return 1;
}

#endif /* _STM_NUMA_H_ */

