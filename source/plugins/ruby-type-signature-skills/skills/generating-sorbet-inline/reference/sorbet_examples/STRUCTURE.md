# Sorbet Examples

Ruby gems that use Sorbet type signatures as real-world references.

## Contents

- [Packwerk](#packwerk)
  - [Files by Pattern](#files-by-pattern) - Abstract modules, classes, collections, T.nilable, T.let, mixins, class methods, blocks, inheritance
  - [Complete File List](#complete-file-list) - Full directory tree

## Packwerk

Source: https://github.com/Shopify/packwerk

A Ruby gem for enforcing modularity and boundaries in Rails applications. Uses `# typed: strict` throughout with comprehensive Sorbet signatures.

### Files by Pattern

#### Abstract Modules & Interfaces

Files demonstrating `abstract!`, `interface!`, and abstract method signatures:

- [checker.rb](packwerk/packwerk/checker.rb) - `abstract!` module with abstract methods, `class << self` signatures
- [output_style.rb](packwerk/packwerk/output_style.rb) - `interface!` module with abstract methods
- [offenses_formatter.rb](packwerk/packwerk/offenses_formatter.rb) - Interface pattern
- [parsers/parser_interface.rb](packwerk/packwerk/parsers/parser_interface.rb) - `interface!` with `requires_ancestor`

#### Classes with Full Signatures

Files showing comprehensive class typing with `attr_reader`, `initialize`, instance methods:

- [package.rb](packwerk/packwerk/package.rb) - Class with `attr_reader` sigs, `Comparable`, `T::Boolean` returns
- [configuration.rb](packwerk/packwerk/configuration.rb) - Complex class with many typed attributes
- [offense.rb](packwerk/packwerk/offense.rb) - Data class with typed attributes
- [reference.rb](packwerk/packwerk/reference.rb) - Struct-like class with typed attributes
- [reference_offense.rb](packwerk/packwerk/reference_offense.rb) - Inheriting class with typed methods
- [unresolved_reference.rb](packwerk/packwerk/unresolved_reference.rb) - Simple data class

#### Collection Types

Files demonstrating `T::Array`, `T::Hash`, `T::Set`:

- [package_set.rb](packwerk/packwerk/package_set.rb) - `T::Array[Package]`, `T::Hash` usage
- [offense_collection.rb](packwerk/packwerk/offense_collection.rb) - Collection handling
- [graph.rb](packwerk/packwerk/graph.rb) - Complex `T::Hash` with union key types

#### T.nilable and Optional Values

- [cache.rb](packwerk/packwerk/cache.rb) - `T.nilable` for optional caching
- [constant_context.rb](packwerk/packwerk/constant_context.rb) - Nullable attributes
- [parsed_constant_definitions.rb](packwerk/packwerk/parsed_constant_definitions.rb) - Optional returns

#### T.let for Instance Variables

- [commands/uses_parse_run.rb](packwerk/packwerk/commands/uses_parse_run.rb) - `T.let` in initialize and methods
- [checker.rb](packwerk/packwerk/checker.rb) - `T.let` with `T.nilable` for memoization
- [extension_loader.rb](packwerk/packwerk/extension_loader.rb) - `T.let` for class instance vars

#### Module Mixins with requires_ancestor

- [commands/uses_parse_run.rb](packwerk/packwerk/commands/uses_parse_run.rb) - `requires_ancestor { BaseCommand }`
- [parsers/parser_interface.rb](packwerk/packwerk/parsers/parser_interface.rb) - `requires_ancestor { Kernel }`

#### Class Methods (self. and class << self)

- [checker.rb](packwerk/packwerk/checker.rb) - `class << self` with `extend T::Sig`
- [cli.rb](packwerk/packwerk/cli.rb) - `def self.` class methods
- [parsers/factory.rb](packwerk/packwerk/parsers/factory.rb) - Factory class methods

#### Block Parameters with T.proc

- [node_visitor.rb](packwerk/packwerk/node_visitor.rb) - Block parameter signatures
- [file_processor.rb](packwerk/packwerk/file_processor.rb) - Proc types in signatures

#### Inheritance and Override

- [reference_offense.rb](packwerk/packwerk/reference_offense.rb) - Subclass with inherited types
- [commands/check_command.rb](packwerk/packwerk/commands/check_command.rb) - Command pattern inheritance
- [output_styles/coloured.rb](packwerk/packwerk/output_styles/coloured.rb) - Interface implementation

### Complete File List

```
packwerk/
├── packwerk.rb                              # Main entry point
└── packwerk/
    ├── application_validator.rb             # Validator class
    ├── association_inspector.rb             # Inspector interface
    ├── cache.rb                             # Caching with T.nilable
    ├── checker.rb                           # Abstract module pattern
    ├── cli.rb                               # CLI class methods
    ├── commands.rb                          # Command registry
    ├── commands/
    │   ├── base_command.rb                  # Base command class
    │   ├── check_command.rb                 # Check implementation
    │   ├── help_command.rb                  # Help implementation
    │   ├── init_command.rb                  # Init implementation
    │   ├── lazy_loaded_entry.rb             # Lazy loading pattern
    │   ├── update_todo_command.rb           # Update implementation
    │   ├── uses_parse_run.rb                # Mixin with requires_ancestor
    │   ├── validate_command.rb              # Validate implementation
    │   └── version_command.rb               # Version implementation
    ├── configuration.rb                     # Config class with many attrs
    ├── const_node_inspector.rb              # AST inspection
    ├── constant_context.rb                  # Context with nilables
    ├── constant_discovery.rb                # Discovery pattern
    ├── constant_name_inspector.rb           # Name inspection interface
    ├── disable_sorbet.rb                    # Sorbet disable helper
    ├── extension_loader.rb                  # Dynamic loading
    ├── file_processor.rb                    # File processing with blocks
    ├── files_for_processing.rb              # File collection
    ├── formatters/
    │   ├── default_offenses_formatter.rb    # Default formatter
    │   └── progress_formatter.rb            # Progress output
    ├── generators/
    │   ├── configuration_file.rb            # Config generation
    │   └── root_package.rb                  # Package generation
    ├── graph.rb                             # Graph with complex types
    ├── node.rb                              # Simple Struct usage
    ├── node_helpers.rb                      # Helper methods
    ├── node_processor.rb                    # Node processing
    ├── node_processor_factory.rb            # Factory pattern
    ├── node_visitor.rb                      # Visitor with blocks
    ├── offense.rb                           # Offense data class
    ├── offense_collection.rb                # Collection handling
    ├── offenses_formatter.rb                # Formatter interface
    ├── output_style.rb                      # Interface example
    ├── output_styles/
    │   ├── coloured.rb                      # Interface implementation
    │   └── plain.rb                         # Interface implementation
    ├── package.rb                           # Core class with Comparable
    ├── package_set.rb                       # Set operations
    ├── package_todo.rb                      # Todo handling
    ├── parse_run.rb                         # Parse execution
    ├── parsed_constant_definitions.rb       # Definitions handling
    ├── parsers.rb                           # Parser registry
    ├── parsers/
    │   ├── erb.rb                           # ERB parser
    │   ├── factory.rb                       # Parser factory
    │   ├── parser_interface.rb              # Interface with requires_ancestor
    │   └── ruby.rb                          # Ruby parser
    ├── rails_load_paths.rb                  # Rails integration
    ├── reference.rb                         # Reference data class
    ├── reference_checking/
    │   ├── checkers/
    │   │   └── dependency_checker.rb        # Checker implementation
    │   └── reference_checker.rb             # Reference checking
    ├── reference_extractor.rb               # Extraction logic
    ├── reference_offense.rb                 # Offense subclass
    ├── run_context.rb                       # Execution context
    ├── spring_command.rb                    # Spring integration
    ├── unresolved_reference.rb              # Unresolved refs
    ├── validator.rb                         # Validation base
    ├── validator/
    │   └── result.rb                        # Validation result
    ├── validators/
    │   └── dependency_validator.rb          # Dep validation
    └── version.rb                           # Version constant
```
