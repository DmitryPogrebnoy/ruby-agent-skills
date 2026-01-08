# Skill Improvement Issues

Issues found by comparing skill against https://sorbet.org/docs/overview and related sources.

## High Priority

### ~~1. Add `T.nilable` and `T::Boolean` to syntax reference~~ ✅ DONE
- ~~`T.nilable(Type)` for optional/nullable values not documented~~
- ~~`T::Boolean` should be used instead of `TrueClass/FalseClass`~~
- ~~These are very common patterns~~
- **Status**: Already documented in syntax.md (lines 125-131 for T.nilable, line 320 for T::Boolean)

### 2. Add `# frozen_string_literal: true` to example
- Standard Ruby best practice
- Should appear after typed sigil in example

### ~~3. Add guidance to preserve existing typed sigil level~~ ✅ DONE
- ~~Skill always suggests `# typed: strict`~~
- ~~Should respect existing sigil level~~
- ~~Don't upgrade without user consent~~
- ~~Add rule: preserve existing strictness unless asked to change~~
- **Status**: Added rule to preserve existing sigil, updated Step 2 with conditional guidance, changed default to `# typed: true` for new files

## Medium Priority

### 4. Add `override` modifier for inherited methods
- `sig { override.returns(Type) }` pattern not covered
- Important for proper inheritance typing

### 5. Add block parameter example with `T.proc`
- Block parameters syntax not shown in example
- Add: `sig { params(blk: T.proc.params(x: Integer).returns(String)).void }`

### 6. Clarify `void` vs `returns`
- Example uses both but no explanation
- `void` - for side effects, return value ignored
- `returns(Type)` - when return value matters

## Low Priority

### 7. Add common errors section
- Error 7002: Type mismatch
- Error 7005: Return value doesn't match signature
- Error 7017: Missing signatures in strict mode
- Would help with troubleshooting

### 8. Add abstract methods pattern
- `sig { abstract.returns(Type) }` not covered
- Requires `extend T::Helpers` and `abstract!`

### 9. Mention flow-sensitive typing
- Sorbet understands `is_a?`, `nil?` checks
- Type narrowing happens automatically after guards
