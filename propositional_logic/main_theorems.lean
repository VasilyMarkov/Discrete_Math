variable (p q r s : Prop)

-- Modus ponens
theorem modus_ponens (h : p → q) (hp : p) : q := h hp
-- Hypothetical syllogism
theorem hs (hpq : p → q) (hqr : q → r) : p → r :=
  fun hp => hqr (hpq hp)
-- Modus tollens
theorem modus_tollens (h : p → q) (hnq: q → False) : p → False :=
  fun hp => hnq (h hp)
-- Addition
theorem addition (hp : p) : p ∨ q := Or.inl hp
-- Specialization
theorem specialization (h : p ∧ q) : p := h.left
-- Conjunction
theorem conjunction (hp : p) (hq : q) : p ∧ q := ⟨hp, hq⟩
-- Сhoice
theorem choice (h : p) (hp : p → (r ∨ s)) (hr : r → q) (hs : s → q) : q :=
  Or.elim (hp h) hr hs
-- Xor choice
theorem xor_choice (hpq : p ∨ q) (hpr : p → (r ∧ ¬r)) : q :=
  hpq.elim
    (fun hp => absurd (hpr hp).left (hpr hp).right)
    id
-- Reductio ad Absurdum
theorem absurdum (hpr : ¬p → (r ∧ ¬r)) : p :=
  Classical.byContradiction (fun hnp => absurd (hpr hnp).left (hpr hnp).right)
