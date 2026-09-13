-- 3a
example: ¬ ∀ (p q r : Bool), (p → q) → (p → r) → (q ∨ r) → p := by decide
-- 3b
example: ∀ (p q r : Bool), (¬p ∨ q) → (¬q ∨ r) → ¬r → ¬p := by decide
-- 3c
example: ∀ (p q r : Bool), (p → q) → (p → r) → ¬(p ∧ q) → ¬p := by decide
-- 3c
example: ∀ (p q r : Bool), (¬p ∨ ¬q) → (r ∨ ¬q) → ¬p → (r ∨ ¬p) := by decide

-- 5a
example: ∀ (r s t w : Bool), (s ∨ t) → (t → r) → (s → w) → (r ∨ w) := by decide
-- 5b
example: ∀ (p q r : Bool), (p → q) → (q → r) → r → p := by decide
-- 5c
example: ∀ (p q s t : Bool), (p → q) → (¬q → ¬s) → (s → t) → (t ∨ q) -> (p ∨ s) := by decide

-- 6d
example: ∀ (p r s q : Bool), (q ∨ ¬p) → (r ∨ ¬q) → p → s → (r ∨ s) := by decide

-- just check
example: ∀ (x w : Bool), (¬x → ¬w) → (x ∨ ¬w) := by decide
