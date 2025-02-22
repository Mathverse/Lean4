/-
Copyright (c) 2021 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner
-/
prelude
import Init.NotationExtra

namespace Nat

private theorem log2_terminates : ∀ n, n ≥ 2 → n / 2 < n
  | 2, _ => by decide
  | 3, _ => by decide
  | n+4, _ => by
    rw [div_eq, if_pos]
    refine succ_lt_succ (Nat.lt_trans ?_ (lt_succ_self _))
    exact log2_terminates (n+2) (succ_lt_succ (zero_lt_succ _))
    exact ⟨by decide, succ_lt_succ (zero_lt_succ _)⟩

/--
Computes `⌊max 0 (log₂ n)⌋`.

`log2 0 = log2 1 = 0`, `log2 2 = 1`, ..., `log2 (2^i) = i`, etc.
-/
@[extern "lean_nat_log2"]
def log2 (n : @& Nat) : Nat :=
  if h : n ≥ 2 then log2 (n / 2) + 1 else 0
termination_by measure id
decreasing_by exact log2_terminates _ h
