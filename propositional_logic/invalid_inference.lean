/-
  `p → q, q → r ⊢ r` is NOT a valid inference — don't confuse it with
  implication transitivity (`p → q, q → r ⊢ p → r`), which concludes
  `p → r`, not `r` outright.

  To disprove a rule, negate its universal closure and give a countermodel:
  take p = q = r = False. Both premises hold trivially (`False → False`
  is `id`), yet the "conclusion" `r` is `False`.
-/
theorem invalid_pq_qr_r : ¬ (∀ p q r : Prop, (p → q) → (q → r) → r) := by
  intro h
  exact h False False False id id

#print axioms invalid_pq_qr_r
