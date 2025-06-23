# System Documentation Guide

## Last Updated
2025-06-23

## Purpose and Intent

This guide provides standards and best practices for maintaining system documentation in the project. It ensures consistency, completeness, and usefulness of all system documentation files, making it easier for developers to understand, use, and extend the game's systems.

---

## Documentation Structure

Each system documentation file should follow this general structure:

1. **Title and Last Updated Date**
   ```markdown
   # System Name Documentation
   
   ## Last Updated
   YYYY-MM-DD
   ```

2. **Purpose and Intent**
   - Overview of the system's role in the game
   - Core responsibilities and features
   - How it fits into the overall architecture

3. **Design**
   - Core components and their responsibilities
   - Design principles and patterns
   - Key abstractions

4. **Architecture**
   - Component diagrams
   - Relationships to other systems
   - Data flow diagrams

5. **Key Subsystems/Features**
   - Detailed descriptions of major subsystems
   - Implementation status
   - Usage examples

6. **Data Structures**
   - Key data classes and their properties
   - Example usage
   - Validation rules

7. **Communication Patterns**
   - EventBus signals used
   - Direct API calls
   - Integration points with other systems

8. **Usage Examples**
   - Code snippets showing common operations
   - Integration examples

9. **Implementation Status**
   - What's implemented
   - What's planned/in progress
   - Future enhancements

10. **Developer Notes**
    - Common pitfalls
    - Performance considerations
    - Testing approach

11. **Documentation Maintenance**
    - Guidelines for updating the documentation
    - Process for adding new features
    - Style guidelines

12. **References**
    - Links to related documentation
    - Design documents
    - Implementation guides

---

## Documentation Maintenance Section

Every system documentation file should include a "Documentation Maintenance" section with guidelines specific to that system. This section should cover:

### Adding New Features

1. **Update Feature Information**: When implementing a new feature, update the relevant section or add a new one.

2. **Add Feature Details**: Include:
   - Feature description and purpose
   - Key components and data structures
   - Integration with other systems
   - Usage examples with code snippets

3. **Update Architecture Diagrams**: If the feature changes the system architecture, update diagrams.

4. **Document Communication Changes**: If the feature introduces new signals or API methods, document them.

### Documenting Data Structures

1. **Class Properties**: When adding new properties to data classes, document their purpose and constraints.

2. **Validation Rules**: Document any validation rules for data properties.

3. **Example Usage**: Provide examples showing how to use the data structures.

### Documentation Style Guidelines

1. **Consistency**: Maintain consistent formatting and structure.

2. **Code Examples**: Include practical code examples for new features.

3. **ASCII Diagrams**: Use ASCII diagrams for complex concepts.

4. **Last Updated**: Update the date whenever significant changes are made.

---

## ASCII Diagrams

Use ASCII diagrams to illustrate system architecture, data flow, and component relationships. Keep diagrams simple and focused on the key elements.

### Component Diagram Example

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|    Component A |---->|    Component B |---->|    Component C |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
```

### Data Flow Example

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|    Producer    |---->|    Processor   |---->|    Consumer    |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
      |                       |                      |
      v                       v                      v
+----------------+     +----------------+     +----------------+
| Data Created   |     | Data Processed |     | Data Consumed  |
+----------------+     +----------------+     +----------------+
```

---

## Code Examples

Include practical code examples for all key features and operations. Examples should be:

- **Concise**: Focus on the specific operation being demonstrated
- **Complete**: Include all necessary imports and context
- **Commented**: Explain key steps
- **Realistic**: Show real-world usage, not contrived examples

### Example Format

```gdscript
# Get a resource from a land parcel
var parcel = demesne.get_parcel(x, y)
var resource_amount = parcel.get_resource_amount("wood")

# Check if we have enough resources
if resource_amount >= required_amount:
    # Use the resource
    parcel.add_resource("wood", -required_amount, true)
    Logger.info(f"Used {required_amount} wood from parcel ({x}, {y})")
```

---

## Implementation Status

Clearly indicate the implementation status of each feature or component:

- **Implemented**: Feature is complete and available in the current version
- **Planned/In Progress**: Feature is designed but not yet fully implemented
- **Future Enhancement**: Feature is planned for a future version

Example:
```markdown
**Implementation Status**:
- Base price loading is implemented via GoodsManager ✓
- Dynamic pricing is planned but not yet implemented ⏳
- Price history tracking is planned but not yet implemented ⏳
```

---

## Cross-Referencing

Link to related documentation to help developers navigate between systems:

- **System References**: Link to other system documentation files
- **Design Documents**: Link to design documents in `dev/docs/designs/`
- **Game Bible**: Link to relevant sections in the game bible

Example:
```markdown
## References

- [Economic System](../game_bible/01_economic_system.md) - Game bible entry
- [System Interactions](systems_overview.md) - Overview of system interactions
- [Market System Design](../designs/market_system_design.md) - Detailed design document
```

---

## Creating New System Documentation

When creating documentation for a new system:

1. **Use the Structure**: Follow the structure outlined in this guide
2. **Reference Existing Docs**: Look at similar system documentation for examples
3. **Include All Sections**: Even if some sections are minimal for now
4. **Add to Overview**: Update `systems_overview.md` to reference the new documentation
5. **Add to References**: Update related system documentation to reference the new system

---

## Documentation Review Process

Before committing new or updated system documentation:

1. **Technical Accuracy**: Ensure all technical details are accurate
2. **Completeness**: Check that all key aspects of the system are documented
3. **Code Examples**: Verify that code examples are correct and follow best practices
4. **Cross-References**: Ensure all links to other documentation are valid
5. **Formatting**: Check that Markdown formatting is correct and consistent

---

## Maintaining This Guide

This guide itself should be updated whenever:

1. New documentation standards are established
2. Best practices evolve
3. New documentation sections are required
4. Documentation tools or processes change

Always update the "Last Updated" date when making significant changes to this guide.
