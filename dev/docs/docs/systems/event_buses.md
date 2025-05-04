# Event Buses System Documentation

## Purpose and Intent

The event bus system consists of two global autoloads: `EventBusGame` and `EventBusUI`. Together, they provide centralised, decoupled communication channels for game logic and UI events, respectively. This design enables unrelated systems and components to interact via signals without direct references, supporting modularity, maintainability, and scalability across the project.

---

## EventBusGame

### Purpose
Acts as the central event bus for all game-related signals, enabling decoupled communication between unrelated game systems (e.g., turn progression, resource updates, surveys, environmental events).

### Design
- **Central Signal Hub:** All game logic signals are defined and emitted via EventBusGame.
- **Decoupled Communication:** Systems emit and listen for signals on the event bus, avoiding direct dependencies.
- **Global Access:** Registered as an autoload singleton, accessible from any script.
- **Signal Naming:** Signals are clearly named and documented, with `@warning_ignore("unused_signal")` to avoid linter warnings.
- **No Logic:** Contains only signal definitions and documentation—no business logic or data storage.

### Architecture
```
+-------------------+
|  EventBusGame     |
|   (autoload)      |
+-------------------+
        |      |      |      |
        v      v      v      v
  SystemA  SystemB  SystemC  FeatureX
```
All game systems and features can emit or listen for signals by referencing the EventBusGame autoload.

### Usage
- Connect to signals:
  - `EventBusGame.connect("turn_complete", Callable(self, "_on_turn_complete"))`
- Emit signals:
  - `EventBusGame.emit_signal("turn_complete")`
- All signals are documented in the script and should be used for cross-system communication.

Example:
```gdscript
# Connect to a signal
EventBusGame.connect("economic_alert", Callable(self, "_on_economic_alert"))

# Emit a signal
EventBusGame.emit_signal("economic_alert", "inflation", 1.5, 2.0)
```

---

## EventBusUI

### Purpose
Acts as the central event bus for all UI-related signals, enabling decoupled communication between unrelated UI components (e.g., notifications, visual feedback, land grid updates, survey completions).

### Design
- **Central Signal Hub:** All UI logic signals are defined and emitted via EventBusUI.
- **Decoupled Communication:** UI components emit and listen for signals on the event bus, avoiding direct dependencies.
- **Global Access:** Registered as an autoload singleton, accessible from any script.
- **Signal Naming:** Signals are clearly named and documented, with `@warning_ignore("unused_signal")` to avoid linter warnings.
- **No Logic:** Contains only signal definitions and documentation—no business logic or data storage.

### Architecture
```
+-------------------+
|   EventBusUI      |
|   (autoload)      |
+-------------------+
        |      |      |      |
        v      v      v      v
   UI A    UI B   UI C   FeaturePanel
```
All UI systems and panels can emit or listen for signals by referencing the EventBusUI autoload.

### Usage
- Connect to signals:
  - `EventBusUI.connect("show_notification", Callable(self, "_on_show_notification"))`
- Emit signals:
  - `EventBusUI.emit_signal("show_notification", "Hello!", "info")`
- All signals are documented in the script and should be used for cross-UI communication.

Example:
```gdscript
# Connect to a signal
EventBusUI.connect("land_grid_updated", Callable(self, "_on_land_grid_updated"))

# Emit a signal
EventBusUI.emit_signal("show_visual_feedback", "Action complete!", Vector2(100, 200))
```

---

## Extending the System
- Add new signals as needed for new game or UI events, following the naming and documentation conventions.
- Remove unused signals to keep the file clean and relevant.
- Update documentation if new categories of events are introduced.

## Developer Notes
- Only signals for game logic should be placed in `EventBusGame`; UI-related signals should go in `EventBusUI`.
- Avoid adding logic or data storage to these files—keep them strictly for signals.
- Use descriptive names and document each signal's purpose and arguments.
- Use `@warning_ignore("unused_signal")` for signals that may not always be connected.

## Associated Files
- `globals/event_bus_game.gd` (autoload singleton)
- `globals/event_bus_ui.gd` (autoload singleton)

## Last Updated
2025-05-04 