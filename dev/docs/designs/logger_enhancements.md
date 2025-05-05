# Logger Enhancements Design Document

## Overview
This document outlines the design for enhancing the logger system to improve performance, reliability, and maintainability while aligning with project architectural principles.

## Core Requirements
- Write logs to file only on game exit
- Remove timestamp filtering
- Add header row to log entries
- Restrict search to log messages only
- Improve performance and reliability
- Remove auto-refresh functionality

## Architecture

### Component Structure
```plaintext
dev_tool/logger/
├── components/
│   ├── log_entry_component.gd
│   ├── log_storage_component.gd
│   └── log_writer_component.gd
├── ui/
│   └── components/
│       ├── log_viewer_component.gd
│       └── log_search_component.gd
├── data/
│   ├── config.json
│   └── log_levels.json
└── logger.gd
```

### Data Classes
- `DataLogConfig`: Configuration data structure
- `DataLogEntry`: Log entry data structure
- `DataLogLevel`: Log level definitions

### Components

#### LogEntryComponent
- Manages individual log entry data
- Handles formatting and validation
- Provides consistent interface for log data

#### LogStorageComponent
- Manages in-memory storage of log entries
- Handles entry limits and cleanup
- Provides efficient access to stored entries

#### LogWriterComponent
- Handles file I/O operations
- Manages single write on game exit
- Implements basic error handling

#### LogViewerComponent
- Displays log entries with headers
- Handles UI updates and rendering
- Manages view filtering and sorting

#### LogSearchComponent
- Implements message-only search
- Provides search highlighting
- Manages search state and results

### Signal Architecture

#### EventBusGame Signals
- `log_entry_added`
- `log_level_changed`
- `log_cleared`

#### EventBusUI Signals
- `log_view_requested`
- `log_search_performed`
- `log_display_updated`

## Data Management

### Configuration
Configuration stored in external JSON files:

```json
{
    "max_entries": 10000,
    "file_path": "user://game_log.txt",
    "show_headers": true,
    "case_sensitive_search": false
}
```

### Log Levels
Log levels and their properties stored in JSON:

```json
{
    "DEBUG": {
        "color": "#808080",
        "priority": 0
    },
    "INFO": {
        "color": "#FFFFFF",
        "priority": 1
    },
    "WARNING": {
        "color": "#FFD700",
        "priority": 2
    },
    "ERROR": {
        "color": "#FF0000",
        "priority": 3
    }
}
```

## Performance Considerations

### Memory Management
- Fixed-size entry buffer
- Oldest entry removal when limit reached
- Efficient string storage

### Search Optimization
- Message-only search implementation
- Simple string matching
- Search on visible entries only

### File I/O
- Single write operation at game exit
- Synchronous write to ensure completion
- Basic error handling

## Error Handling
- Clear error messages
- Assertions for critical dependencies
- Graceful degradation on failures

## Documentation Requirements
- Comprehensive class docstrings
- Usage examples in documentation
- Clear function documentation
- Signal documentation

## Code Organization
- Consistent region structure
- Clear separation of concerns
- Proper static typing
- Signal-based communication 