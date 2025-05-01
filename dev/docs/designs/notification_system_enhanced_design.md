# Enhanced Notification System Design

## Overview
A comprehensive notification system that provides players with timely, accessible information through toast notifications and a historical record. The system supports different criticality levels, rich content, audio feedback, and a queuing mechanism for managing multiple notifications.

## Core Components

### 1. Notification Criticality Levels
- **Normal:** Standard information, auto-dismisses after short duration
- **Major:** Important updates, auto-dismisses after longer duration
- **Critical:** Urgent information, requires manual dismissal

### 2. Toast Notifications
#### Features
- Stacking display (newest at bottom)
- Animation (slide in/fade out)
- Queue management for overflow
- Hover-pause for auto-dismiss
- Rich text support (BBCode)
- Audio feedback per criticality level
- Action callbacks for interaction

#### Behaviour
- Maximum visible toasts enforced
- FIFO dismissal (skipping non-auto-dismiss)
- Queuing system for overflow
- Clear all functionality

### 3. History Panel
- Accessed via top bar icon
- Shows all notifications from current session
- Displays message, criticality, turn, and timestamp
- No persistence between sessions

## Data Structures

### NotificationConfig
```gdscript
enum NotificationCriticality {
    NORMAL,
    MAJOR,
    CRITICAL
}

class DataNotificationConfig:
    var criticality_settings := {
        NotificationCriticality.NORMAL: {
            "auto_dismiss": true,
            "duration": 3.0,
            "audio": AudioStream,
            "style": StyleBox
        },
        NotificationCriticality.MAJOR: {
            "auto_dismiss": true,
            "duration": 5.0,
            "audio": AudioStream,
            "style": StyleBox
        },
        NotificationCriticality.CRITICAL: {
            "auto_dismiss": false,
            "duration": -1.0,
            "audio": AudioStream,
            "style": StyleBox
        }
    }
    const MAX_VISIBLE_TOASTS := 5
```

### DataNotification
```gdscript
class DataNotification:
    var id: int
    var message: String  # Supports BBCode
    var criticality: NotificationCriticality
    var turn: int
    var action: Callable = null
    var icon: Texture2D = null
    var timestamp: int
```

## System Architecture

### Components
1. **NotificationSystem (Control)**
   - Manages active toasts and queue
   - Handles notification creation and dismissal
   - Maintains notification history

2. **NotificationToast (Control)**
   - Individual toast UI component
   - Handles animations and interactions
   - Manages auto-dismiss timing

3. **NotificationHistoryPanel (Control)**
   - Displays notification history
   - Provides filtering options
   - Manages history entries display

### Key Interactions
1. **Notification Creation**
   ```mermaid
   sequenceDiagram
       Game Logic->>NotificationSystem: Create notification
       NotificationSystem->>NotificationSystem: Add to history
       NotificationSystem->>NotificationSystem: Check active toasts
       alt Can show more toasts
           NotificationSystem->>NotificationToast: Create and show
       else At max toasts
           NotificationSystem->>NotificationSystem: Add to queue
       end
   ```

2. **Toast Dismissal**
   ```mermaid
   sequenceDiagram
       NotificationToast->>NotificationSystem: Dismiss signal
       NotificationSystem->>NotificationSystem: Remove from active
       NotificationSystem->>NotificationSystem: Check queue
       alt Queue not empty
           NotificationSystem->>NotificationToast: Show next toast
       end
   ```

## UI/UX Considerations

### Toast Layout
- Right-aligned, stacking vertically
- Newest notifications appear at bottom
- Smooth animations for entry/exit
- Clear visual hierarchy based on criticality

### History Panel
- Accessible via persistent UI element
- Chronological order (newest first)
- Visual indicators for criticality levels
- Compact but readable layout

### Accessibility
- Screen reader support
- Keyboard navigation
- Colour-blind friendly design
- Configurable audio feedback

## Performance Considerations

### Memory Management
- No session persistence required
- Queue management prevents overflow
- Efficient toast cleanup on dismissal

### Processing Efficiency
- Animation using Godot's Tween system
- Efficient queue processing
- Smart update cycle for active toasts

## Testing Strategy

### Unit Tests
- Notification creation and queuing
- Criticality behaviour validation
- Toast lifecycle management
- History recording accuracy

### Integration Tests
- UI interaction testing
- Animation sequence validation
- Audio feedback verification
- Queue management scenarios

### User Acceptance Criteria
- Notifications visible and readable
- Correct criticality behaviour
- Smooth animations
- Accurate history display
- Working audio feedback
- Proper queue management 