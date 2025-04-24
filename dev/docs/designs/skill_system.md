# Skill System Design

## Overview
The skill system introduces differentiated capabilities for people in the simulation. Each person can have various skills that determine their suitability for jobs and affect their performance. Skills are scored from 0.0 to 1.0 and categorized into competence levels.

## Core Concepts

### Skill Competence Levels
Skills are divided into four competence bands:
- **Incompetent** (0.0-0.25): No meaningful capability in the skill
- **Passable** (0.26-0.5): Basic understanding/capability
- **Competent** (0.51-0.75): Solid grasp and ability
- **Skilled** (0.76-1.0): Expert level capability

### Data Structures

#### DataSkill
Represents a skill definition:
- `id`: Unique identifier
- `display_name`: Name shown in UI
- `category`: Skill category (mental, physical, etc.)
- `description`: Detailed description of the skill

#### DataSkillDistribution
Tracks population-level skill distribution:
- Distribution counts for each competence level
- Total population tracking
- Percentage calculations for policy analysis

### Population Analysis
The system tracks skill distribution across the population:
- Monitors changes in skill levels
- Calculates percentages at each competence level
- Provides insights for policy decisions
- Emits signals when distributions change

## Technical Implementation

### Constants
Defined in `globals/constants.gd`:
- SkillCompetence enum
- Threshold values for each competence level

### Core Components

#### Library Integration
The Library singleton (`globals/library.gd`) manages:
- Loading skill definitions from JSON
- Providing access to skill data
- Skill competence calculations

#### Population Skills Analyzer
Located in `scripts/economic_analysis/population_skills_analyzer.gd`:
- Tracks population-wide skill distributions
- Updates tracking when skills change
- Provides analysis functions for policy decisions

### Data Storage
Skills are defined in `data/skills.json`:
```json
{
    "skill_id": {
        "id": "skill_id",
        "display_name": "Skill Name",
        "category": "category",
        "description": "Description"
    }
}
```

## Usage Examples

### Checking Skill Requirements
```gdscript
var skill_level = person.get_skill_level("literacy")
var competence = Library.get_skill_data("literacy").get_competence_level(skill_level)
if competence >= Constants.SkillCompetence.COMPETENT:
    # Person is competent or better at literacy
```

### Population Analysis
```gdscript
# Get percentage of population that is at least competent in crafting
var competent_crafters = analyzer.get_population_meeting_requirement(
    "craftsmanship", 
    Constants.SkillCompetence.COMPETENT
)
```

## Future Considerations
- Skill improvement through education buildings
- Skill transfer between people (teaching)
- Skill requirements for business ownership
- Policy effects on skill development
- Job performance modifiers based on skill levels 