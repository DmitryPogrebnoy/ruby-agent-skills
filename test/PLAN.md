# Evaluation Plan: `generating-rbs` Skill

## Overview

Evaluate the skill's effectiveness by comparing two approaches across three real-world Ruby gems.

### Testing Approaches

| Approach | Description | Output Directory |
|----------|-------------|------------------|
| **Baseline** | Claude Code with top model (Opus), **no skill** | `sig_baseline/` |
| **With Skill** | Claude Code with top model (Opus), **skill enabled** | `sig_with_skill/` |

### Test Targets (ordered by difficulty)

| # | Gem | Repository | Size | Complexity | Key Patterns |
|---|-----|------------|------|------------|--------------|
| 1 | **pundit** | [varvet/pundit](https://github.com/varvet/pundit) | Small | 🟢 Simple | Authorization, mixins, clean architecture |
| 2 | **ruby_llm** | [crmne/ruby_llm](https://github.com/crmne/ruby_llm) | Medium | 🟡 Medium | API clients, streaming, callbacks |
| 3 | **faraday** | [lostisland/faraday](https://github.com/lostisland/faraday) | Large | 🔴 Complex | Middleware, adapters, metaprogramming |

### Evaluation Goal

Measure the **delta** between Baseline and With Skill approaches:
- Does the skill improve completion rate?
- Does the skill reduce validation errors?
- Does the skill reduce iterations needed?
- Does the skill improve type coverage?

---

## Test Target 1: pundit (🟢 Simple)

### 1.1 Setup
```bash
git clone https://github.com/varvet/pundit.git test/pundit
cd test/pundit
bundle install
```

### 1.2 Baseline Metrics
```bash
find lib -name "*.rb" | wc -l                           # Ruby files
grep -r "class\|module" lib --include="*.rb" | wc -l    # Classes/modules
```

### 1.3 Run Baseline (No Skill)
```
Prompt: "Generate RBS signatures for all files in lib/pundit/ and place them in sig_baseline/"
```

### 1.4 Run With Skill
```
Prompt: "Generate RBS signatures for all files in lib/pundit/ and place them in sig_with_skill/"
```

### 1.5 Validate Both
```bash
bundle exec rbs -I sig_baseline validate
bundle exec rbs -I sig_with_skill validate
```

### 1.6 Key Areas to Test
- [ ] Policy base class and inheritance
- [ ] `Pundit` module mixed into controllers
- [ ] Scope classes (nested class pattern)
- [ ] Authorization error classes
- [ ] Helper methods with block parameters

---

## Test Target 2: ruby_llm (🟡 Medium)

### 2.1 Setup
```bash
git clone https://github.com/crmne/ruby_llm.git test/ruby_llm
cd test/ruby_llm
bundle install
```

### 2.2 Baseline Metrics
```bash
find lib -name "*.rb" | wc -l
grep -r "class\|module" lib --include="*.rb" | wc -l
```

### 2.3 Run Baseline (No Skill)
```
Prompt: "Generate RBS signatures for all files in lib/ruby_llm/ and place them in sig_baseline/"
```

### 2.4 Run With Skill
```
Prompt: "Generate RBS signatures for all files in lib/ruby_llm/ and place them in sig_with_skill/"
```

### 2.5 Validate Both
```bash
bundle exec rbs -I sig_baseline validate
bundle exec rbs -I sig_with_skill validate
```

### 2.6 Key Areas to Test
- [ ] API client classes with HTTP methods
- [ ] Streaming response handlers
- [ ] Configuration objects
- [ ] Error classes hierarchy
- [ ] Callback/hook patterns

---

## Test Target 3: faraday (🔴 Complex)

### 3.1 Setup
```bash
git clone https://github.com/lostisland/faraday.git test/faraday
cd test/faraday
bundle install
```

### 3.2 Baseline Metrics
```bash
find lib -name "*.rb" | wc -l
grep -r "class\|module" lib --include="*.rb" | wc -l
```

### 3.3 Run Baseline (No Skill)
```
Prompt: "Generate RBS signatures for all files in lib/faraday/ and place them in sig_baseline/"
```

### 3.4 Run With Skill
```
Prompt: "Generate RBS signatures for all files in lib/faraday/ and place them in sig_with_skill/"
```

### 3.5 Validate Both
```bash
bundle exec rbs -I sig_baseline validate
bundle exec rbs -I sig_with_skill validate
```

### 3.6 Key Areas to Test
- [ ] Middleware stack architecture
- [ ] Connection adapters with inheritance
- [ ] Request/Response objects
- [ ] Builder pattern with blocks
- [ ] Options/configuration hashes
- [ ] Dynamic method definitions

---

## Evaluation Metrics

### Per-Gem Metrics

| Metric | Description | How to Measure |
|--------|-------------|----------------|
| **Completion** | All files processed | Count generated .rbs files vs .rb files |
| **Validation** | `rbs validate` passes | Run validation command |
| **Type Coverage** | % non-untyped methods | `grep -c "untyped" sig_*/**/*.rbs` |
| **Accuracy** | Signatures match implementation | Manual review of 10 random methods |
| **Iterations** | Fix cycles needed | Count validation → fix loops |

### Scoring Rubric

| Score | Criteria |
|-------|----------|
| 0-2 | Skill fails to complete, major errors |
| 3-4 | Partial completion, many validation errors |
| 5-6 | Completes with validation errors, needs multiple fix cycles |
| 7-8 | Completes, validates, minor accuracy issues |
| 9-10 | Completes, validates, accurate, minimal `untyped` usage |

---

## Success Criteria

### Skill is Valuable If:

| Criteria | Threshold |
|----------|-----------|
| Average score improvement | ≥ +1.0 points |
| Iteration reduction | ≥ 20% fewer cycles |
| Type coverage improvement | ≥ +10% coverage |
| Validation pass rate improvement | Baseline fails → With Skill passes |

### Overall Rating

| Level | Criteria |
|-------|----------|
| **Not Useful** | Skill adds < +0.5 score improvement |
| **Marginally Useful** | Skill adds +0.5 to +1.0 improvement |
| **Useful** | Skill adds +1.0 to +2.0 improvement |
| **Very Useful** | Skill adds > +2.0 improvement |

---

## Execution Order

### 1. pundit (Simple)
```bash
cd test/pundit

# Baseline
claude --model opus
> "Generate RBS signatures for all files in lib/pundit/ and place them in sig_baseline/"

# With Skill
claude --model opus  # with skill enabled
> "Generate RBS signatures for all files in lib/pundit/ and place them in sig_with_skill/"

# Compare
bundle exec rbs -I sig_baseline validate
bundle exec rbs -I sig_with_skill validate
```

### 2. ruby_llm (Medium)
```bash
cd test/ruby_llm
# Same process as above
```

### 3. faraday (Complex)
```bash
cd test/faraday
# Same process as above
```

---

## Directory Structure

```
test/
├── PLAN.md
├── pundit/
│   ├── lib/
│   ├── sig_baseline/      ← Baseline results
│   └── sig_with_skill/    ← With Skill results
├── ruby_llm/
│   ├── lib/
│   ├── sig_baseline/
│   └── sig_with_skill/
└── faraday/
    ├── lib/
    ├── sig_baseline/
    └── sig_with_skill/
```

---

## Next Steps

1. Clone all three repositories into `test/`
2. For each gem (pundit → ruby_llm → faraday):
   - Run baseline (no skill) → output to `sig_baseline/`
   - Run with skill → output to `sig_with_skill/`
   - Validate both and compare results
3. Calculate deltas and determine skill value-add
