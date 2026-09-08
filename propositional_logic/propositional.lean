variable (p q r : Prop)

-- Modus ponens. A proof of `p → q` is literally a function.
example (hpq : p → q) (hp : p) : q := hpq hp

-- The same thing in tactic mode.
example (hpq : p → q) (hp : p) : q := by
  exact hpq hp

-- Conjunction: introduce with anonymous constructor ⟨_, _⟩,
-- eliminate by destructuring.
theorem and_swap : p ∧ q → q ∧ p := by
  intro h
  obtain ⟨hp, hq⟩ := h
  exact ⟨hq, hp⟩

-- Disjunction: choose a side to introduce, split to eliminate.
theorem or_swap : p ∨ q → q ∨ p := by
  intro h
  rcases h with hp | hq
  · right; exact hp
  · left;  exact hq

-- Currying. Note that the term-mode proof is just a lambda:
-- ∧ is a pair, so uncurrying a pair is the identity in disguise.
theorem curry : (p ∧ q → r) → (p → q → r) :=
  fun h hp hq => h ⟨hp, hq⟩

-- Contraposition. `¬p` unfolds to `p → False`, so this needs nothing new.
theorem contrapose : (p → q) → (¬q → ¬p) := by
  intro hpq hnq hp
  exact hnq (hpq hp)

-- Double negation introduction is constructive; the converse is not.
-- (Named `dn_intro`, not `not_not_intro` — Lean core already declares
-- `not_not_intro` with this exact statement in `Init.Core`.)
theorem dn_intro : p → ¬¬p :=
  fun hp hnp => hnp hp

-- Transitivity of implication is just function composition.
theorem imp_trans : (p → q) → (q → r) → (p → r) :=
  fun hpq hqr hp => hqr (hpq hp)

-- `p → q, q → r ⊢ r` is NOT a valid inference — see `invalid_inference.lean`
-- for the counterexample; don't confuse it with `imp_trans` above.

/-
  Classical territory. `¬¬p → p` is NOT provable structurally —
  it needs the axiom of choice via `Classical.byContradiction`.
-/
theorem not_not_elim : ¬¬p → p :=
  fun h => Classical.byContradiction h

#check @and_swap
#check @curry
#print axioms dn_intro        -- no axioms: fully constructive
#print axioms not_not_elim    -- depends on Classical.choice