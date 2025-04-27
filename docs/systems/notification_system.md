# Notification System

## Overview
The Notification System provides a modular, centralised way to display notifications and visual feedback to the player. It is designed to be triggered from anywhere in the game via signals, and is fully decoupled from game logic. Notifications can be informational, success, warning, or error messages, and visual feedback can be shown at arbitrary positions in the UI.

## Usage
- **Show a notification:**
  ```gdscript
  EventBusUI.show_notification.emit("Message", "info")
  ```
- **Show visual feedback at a position:**
  ```gdscript
  EventBusUI.show_visual_feedback.emit("Feedback!", Vector2(100, 200))
  ```

## API

### Signals (on EventBusUI)
- `show_notification(message: String, type: String)`
- `show_visual_feedback(message: String, position: Vector2)`

### Public Functions (NotificationSystem)
- `show_notification(message: String, type: String = "info")`
- `show_visual_feedback(message: String, position: Vector2)`

## Integration
- The Notification System is instanced as a child of `MainUI` in `main_ui.tscn`.
- Signals are connected in `notification_system.gd`'s `_ready()` function.
- Handles display, animation, and removal of messages automatically.

## Example
A notification is shown on game start in `scripts/ui/main_ui.gd`:
```gdscript
EventBusUI.show_notification.emit("Welcome to your demesne!", "info")
```

## Extending
- Add new notification types by extending the `NOTIFICATION_TYPES` constant in `notification_system.gd`.
- Customise appearance by editing `_create_notification` and `_create_feedback` in `notification_system.gd`.

## Related Files
- `scenes/ui/notification_system.tscn`
- `scripts/ui/notification_system.gd`
- `scripts/ui/main_ui.gd`
- `globals/event_bus_ui.gd` 