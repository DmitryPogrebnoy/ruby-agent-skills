# Ruby Type Signature Skills

A Claude Code plugin providing skills for efficient work with Ruby type signatures (RBS).

## Overview

This plugin provides five **model-invoked skills** for working with RBS (Ruby Signature) files. Skills are automatically activated by Claude when relevant to your task - you don't need to explicitly call them.

| Skill | Triggers When You Ask To... |
|-------|----------------------------|
| **rbs-generate** | Generate types, create .rbs files, add type signatures |
| **rbs-validate** | Check types, validate RBS, find type errors |
| **rbs-sync** | Update types after code changes, sync signatures |
| **rbs-annotate** | Add inline @rbs comments, annotate methods |
| **rbs-stdlib** | Setup gem types, configure type collections |

## Installation

### From GitHub (Recommended)

**Step 1:** Add the marketplace to Claude Code:
```
/plugin marketplace add DmitryPogrebnoy/ruby-type-signature-agent-skills
```

**Step 2:** Install the plugin:
```
/plugin install ruby-type-signature-skills
```

### Manual Installation

Clone to your personal plugins directory:

```bash
git clone https://github.com/DmitryPogrebnoy/ruby-type-signature-agent-skills.git ~/.claude/plugins/ruby-agent-skills
```

Or add to a specific project:

```bash
cd your-project
git clone https://github.com/DmitryPogrebnoy/ruby-type-signature-agent-skills.git .claude/plugins/ruby-agent-skills
```

## Usage

Skills are **model-invoked** - Claude automatically uses them based on your request. Just describe what you want:

```
Generate RBS signatures for lib/user.rb
```

```
Validate all my type definitions
```

```
Update the RBS files after I changed the User class
```

```
Add inline type annotations to app/services/payment.rb
```

```
Help me setup type signatures for my Rails gems
```

## Plugin Structure

```
ruby-type-signature-skills/
├── .claude-plugin/
│   ├── plugin.json           # Plugin manifest
│   └── marketplace.json      # Marketplace catalog (for GitHub install)
├── skills/
│   ├── rbs-generate/
│   │   ├── SKILL.md          # Generate RBS from Ruby
│   │   └── examples/         # Supporting example files
│   │       ├── user.rb
│   │       ├── user.rbs
│   │       ├── collection.rb
│   │       └── collection.rbs
│   ├── rbs-validate/
│   │   └── SKILL.md          # Validate RBS correctness
│   ├── rbs-sync/
│   │   └── SKILL.md          # Sync RBS with code changes
│   ├── rbs-annotate/
│   │   └── SKILL.md          # Inline type annotations
│   └── rbs-stdlib/
│       └── SKILL.md          # Gem and stdlib types
├── LICENSE
└── README.md
```

## Requirements

For full functionality, ensure these tools are available:

- **rbs** (required): `gem install rbs`
- **steep** (recommended): `gem install steep`
- **typeprof** (optional): `gem install typeprof`

## RBS Quick Reference

### Basic Types

```rbs
String, Integer, Float, Symbol, bool, nil, void, untyped
```

### Collections

```rbs
Array[String]
Hash[Symbol, Integer]
Set[User]
```

### Optional Types

```rbs
String?          # String or nil
Integer | nil    # Same as Integer?
```

### Union Types

```rbs
String | Integer
:success | :failure
```

### Method Signatures

```rbs
def method_name: (Type param) -> ReturnType
def optional: (?Type param) -> ReturnType
def keyword: (name: String, ?age: Integer) -> ReturnType
def block: () { (Item) -> void } -> self
```

### Generic Classes

```rbs
class Container[T]
  def add: (T item) -> void
  def get: () -> T?
end
```

## Examples

See `skills/rbs-generate/examples/` for complete examples:

- `user.rb` / `user.rbs` - Basic class with attributes and methods
- `collection.rb` / `collection.rbs` - Generic class with type parameters

## Contributing

Contributions welcome! Please submit issues and pull requests at [GitHub](https://github.com/DmitryPogrebnoy/ruby-type-signature-agent-skills).

## License

MIT License - see [LICENSE](LICENSE) for details.
