# UI/UX Guidelines

## Core Design Principles

### 1. Input Method Flexibility
- **Universal Control Scheme**
  - All functions accessible via keyboard, controller, or mouse
  - No text input requirements
  - Context-sensitive button mapping
  - Consistent control patterns across systems
  - Quick-select radial menus for common actions

- **Control Mapping**
  - D-pad/Arrow keys for menu navigation
  - Face buttons/Enter for confirmation
  - Shoulder buttons/Tab for system switching
  - Triggers/Shift for modifier actions
  - Analog stick/Mouse for cursor control

### 2. Arcade-Style Information Display
- **Simplified Statistics**
  - Percentage-based indicators (0-100%)
  - Color-coded status indicators (Red/Yellow/Green)
  - Simple trend arrows (↑↓→)
  - Progress bars for continuous values
  - Star ratings for complex metrics (★★★☆☆)

- **Visual Feedback**
  - Immediate action confirmation
  - Clear success/failure indicators
  - Animated transitions
  - Sound effect feedback
  - Haptic feedback support

### 3. Progressive UI Revelation
- **Tutorial Integration**
  - Core systems available from start
  - Advanced features unlock progressively
  - Context-sensitive help system
  - Interactive tutorials
  - Guided first-time-use

- **Technology-Based UI Evolution**
  - Basic displays initially
  - Advanced analytics unlock with research
  - Automation tools as rewards
  - Enhanced visualization options
  - Advanced prediction capabilities

## Interface Standards

### 1. Navigation Structure
- **Three-Level Hierarchy**
  - Main systems (6 core areas)
  - Subsystems (2-3 per main system)
  - Detail views (specific tools/actions)

- **Quick Access**
  - Radial menu for system switching
  - Hot-key support for common actions
  - Recent actions history
  - Favorite tools marking
  - Emergency action shortcuts

### 2. Visual Language
- **Color Coding**
  - Economic: Gold/Yellow
  - Population: Blue
  - Production: Orange
  - Governance: Purple
  - Environmental: Green
  - Technology: Cyan

- **Status Indicators**
  - Critical: Red pulse
  - Warning: Yellow glow
  - Positive: Green shimmer
  - Neutral: White
  - Inactive: Gray

### 3. Common Elements
- **Information Cards**
  - Title
  - Key statistics (max 3)
  - Trend indicator
  - Action buttons (max 4)
  - Status indicator

- **Control Panels**
  - Slider bars for adjustments
  - Toggle switches for binary choices
  - Radial selectors for options
  - Progress bars for tracking
  - Quick action buttons

## Core Interface Layout

### Main Game View
```
+------------------------------------------+
|              Top Status Bar              |
|  [Time] [Speed] [Wealth] [Alert Count]   |
+------------------+---------------------+--+
|                  |                     |
|                  |                     |
|    Main View     |   System Panel     |
|     (Game        |    (Context-       |
|     World)       |    Sensitive)      |
|                  |                     |
|                  |                     |
+------------------+---------------------+
|           Bottom Action Bar            |
|   [Quick Actions] [System Selector]    |
+------------------------------------------+
```

### System Selection Menu
```
         [Production]
            /|\
[Population] | [Economic]
    \       |      /
     \      |     /
      \     |    /
[Environment]-[Tech]
      /     |    \
     /      |     \
    /       |      \
[Social]    |  [Governance]
           \|/
        [Options]
```

## Standard UI Elements

### 1. Progress Indicators
```
[Empty]     [#----]  20%
[Half]      [###--]  60%
[Full]      [#####] 100%
[Critical]  [!!!!!] ALERT
```

### 2. Status Symbols
```
↑ - Increasing/Positive
→ - Stable/Neutral
↓ - Decreasing/Negative
★ - Quality/Importance Level
! - Alert/Warning
```

### 3. Action Buttons
```
+---------------+
|    Icon       |
| Action Name   |
| Hotkey [X]    |
+---------------+
```

### 4. Information Cards
```
+------------------+
| Title           |
|-----------------|
| Key Stat: Value |
| Trend: ↑        |
| Status: ★★★☆☆   |
|-----------------|
| [Action Button] |
+------------------+
```

## Control Scheme
```
+------------------------------------------+
|    Keyboard         Controller    Mouse   |
| [W,A,S,D] Move   [L-Stick] Move  LMB     |
| [Q,E] Rotate     [R-Stick] Rotate RMB    |
| [Space] Select   [A] Select     Wheel    |
| [Tab] Menu       [Start] Menu   MMB      |
+------------------------------------------+
```

## Technical Requirements

### Display Standards
1. 16:9 aspect ratio maintenance
2. Resolution-independent scaling
3. Minimum text size: 16pt
4. Touch targets: 44x44 pixels minimum
5. Consistent padding (16px standard)

### Accessibility Requirements
1. Color-blind friendly palette
2. High contrast mode support
3. Screen reader compatibility
4. Alternative control schemes
5. Adjustable timing settings

### Navigation Rules
1. Maximum 3 levels of depth
2. Quick access to emergency controls
3. Context-sensitive help
4. Consistent back functionality
5. Clear visual hierarchy

## Interaction Patterns

### 1. Selection and Control
- **Primary Actions**
  - A/Left-click: Select/Confirm
  - B/Right-click: Cancel/Back
  - X/Middle-click: Alternative action
  - Y/Shift-click: Context menu

- **Navigation**
  - D-pad/Arrows: Menu movement
  - L1/R1: Tab switching
  - L2/R2: Category switching
  - Start: System menu
  - Select: Quick help

### 2. Common Workflows
- **Resource Management**
  1. Select resource type
  2. Choose action from radial menu
  3. Adjust values with slider
  4. Confirm with single button

- **Policy Implementation**
  1. Select policy category
  2. Choose policy from grid
  3. Review effects card
  4. Confirm implementation

### 3. Emergency Actions
- **Crisis Response**
  1. Alert notification
  2. Quick-select response options
  3. Single-button confirmation
  4. Immediate feedback

## Progressive Features

### 1. Basic Systems (Available from Start)
- Simple resource management
- Basic population overview
- Essential production controls
- Core governance tools
- Basic environmental monitoring
- Initial technology options

### 2. Intermediate Features (Unlock via Progress)
- Advanced analytics
- Detailed tracking systems
- Enhanced visualization
- Prediction tools
- Automation options

### 3. Advanced Systems (Technology/Law Dependent)
- Complex modeling
- AI assistance
- Advanced forecasting
- Multi-system integration
- Optimization tools

## Accessibility Considerations

### 1. Visual Accessibility
- High contrast mode
- Adjustable text size
- Colorblind-friendly palette
- Clear icon designs
- Screen reader support

### 2. Control Accessibility
- Remappable controls
- Alternative control schemes
- Adjustable timing settings
- Hold vs. Toggle options
- Simple mode option

## Implementation Guidelines
- Use consistent button mapping across all systems
- Maintain uniform color coding
- Ensure all actions possible with any input method
- Keep information density appropriate
- Provide clear feedback for all actions
- Progressive complexity in tutorial flow
- Regular playtesting for intuitive use 