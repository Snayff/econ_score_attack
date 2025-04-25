# Log Viewer Design Document

## Overview
The Log Viewer is an in-game tool designed to make debugging and monitoring more accessible by providing a user-friendly interface for viewing, filtering, and searching log files. This document outlines the complete design of the system.

## Problem Statement
The current logging system outputs content that is becoming difficult to parse due to volume, and managing multiple log files adds complexity to debugging and monitoring tasks.

## Core Requirements
1. Log file selection and loading from "/logs/" directory
2. Filter functionality by log type (DEBUG, INFO, WARNING, ERROR)
3. Text search within logs
4. Header summarising number of log statements by type
5. Scrollable log content
6. Real-time log updates

## Additional Features
1. Colour coding for different log levels
2. Export filtered/searched results
3. Timestamp-based filtering
4. Source-based filtering
5. Auto-refresh toggle
6. Clear log view option
7. Copy selected log entries
8. Collapsible sections

## Technical Architecture

### File Structure
```
scenes/ui/
  log_viewer/
    log_viewer.tscn
    log_viewer.gd
    components/
      log_header.tscn
      log_header.gd
      log_content.tscn
      log_content.gd
      log_filters.tscn
      log_filters.gd
      log_file_selector.tscn
      log_file_selector.gd
```

### Component Breakdown

#### LogViewer (Main Control)
- Coordinates all sub-components
- Manages state and data flow
- Handles auto-refresh functionality

#### LogHeader
- Displays statistics about current log entries
- Updates in real-time as filters change
- Shows counts by log level

#### LogContent
- Implements virtual scrolling for performance
- Manages entry visibility
- Handles entry selection and context menu

#### LogFilters
- Provides UI for all filter types
- Implements debounced search
- Manages filter state

#### LogFileSelector
- Handles file list management
- Provides file selection UI
- Manages file refresh functionality

### Data Structures

#### LogEntry Format
```gdscript
var LogEntry := {
    "timestamp": "",  # ISO format
    "level": Logger.Level,
    "source": "",
    "message": "",
    "raw_text": ""  # Original log line
}
```

#### Filter State
```gdscript
var FilterState := {
    "levels": [],  # Array of Level enums
    "source": "",  # Source filter text
    "timestamp_from": "",  # ISO timestamp
    "timestamp_to": "",  # ISO timestamp
    "search_text": ""  # Search string
}
```

## UI Layout
```
LogViewer (Control)
├── VBoxContainer
│   ├── LogHeader (PanelContainer)
│   │   └── Statistics labels
│   ├── LogFilters (PanelContainer)
│   │   ├── Level checkboxes
│   │   ├── Source filter
│   │   ├── Date range
│   │   └── Search box
│   ├── LogFileSelector (HBoxContainer)
│   │   ├── File dropdown
│   │   └── Refresh button
│   └── LogContent (ScrollContainer)
│       └── VBoxContainer for entries
└── ContextMenu (PopupMenu)
    ├── Copy
    ├── Export
    └── Clear
```

## Performance Considerations

### Virtual Scrolling
- Only render visible items plus buffer
- Recycle entry nodes when scrolling
- Maintain scroll position during updates

### Memory Management
- Lazy loading of log files
- Batch processing of entries
- Efficient filtering algorithms
- Cache filtered results

### Real-time Updates
- Debounced filter updates
- Incremental content updates
- Optimised refresh cycles

## Error Handling
- Graceful handling of missing log files
- Recovery from parsing errors
- Clear error messaging to user
- Automatic retry mechanisms

## Future Considerations
1. Support for log aggregation across multiple files
2. Advanced search with regex support
3. Custom filter presets
4. Log analysis tools
5. Export functionality for filtered logs
6. Integration with external logging tools

## Testing Strategy
1. Unit tests for filter logic
2. Integration tests for component interaction
3. Performance tests for large log files
4. UI/UX testing for usability
5. Error handling verification 