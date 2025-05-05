# Economic Actor Decision-Making System

## Overview
This document outlines the design for a robust, modular system enabling economic actors (people) to make realistic, dynamic decisions about spending, saving, and adapting to market conditions in a closed-loop economy. The system is grounded in economic theory, supports diverse and emergent behaviours, and is designed for performance, extensibility, and testability.

## Warning
This design touches on aspects of other not-yet-implemented designs. We should build in a way that is in line with those designs, wherever possible. Known overlapping designs:
- dev/docs/designs/ancestry_system_design.md
- dev/docs/designs/market_system_design.md

---

## Core Components

### 1. Utility Function
- **Personalised Utility:** Each actor has a utility function, parameterised by their needs (e.g., hunger, comfort, entertainment), weighted by their current state.
- **Marginal Utility:** Utility for a good decreases as the actor's need is satisfied (diminishing returns).
- **Randomness/Noise:** A small random factor is added to simulate irrationality and diversity.
- **Cultural/Ancestral Influence:** At creation, an actor's base preferences (utility weights) are set according to their culture and ancestry, loaded from external data (e.g., JSON). This allows for distinct market behaviours across populations.

**Example Calculation:**
```
utility = (base_weight_culture * need_level * marginal_factor + random_noise) * price_sensitivity
```

---

### 2. Budget Constraint & Savings Propensity
- **Budget Constraint:** Actors can only purchase goods/services they can afford.
- **Savings Propensity:** Each actor has a "savings rate" (possibly influenced by culture, age, or recent events) that determines what portion of their income is reserved and not spent immediately.
- **Disposable Income:** Only income not allocated to savings is available for purchases.
- **Optional Credit:** (Future extension) Some actors may take loans, introducing debt and risk.

**Example Calculation:**
```
disposable_income = total_money * (1 - savings_rate)
```

---

### 3. Event-Driven Triggers & Performance: Batch Processing
- **Needs-Driven Triggers:** Actors only evaluate purchases when a need crosses a threshold (e.g., hunger > 80%).
- **Market-Driven Triggers:** Actors re-evaluate if a relevant market event occurs (e.g., price drop, new product).
- **Batch Processing:** For large populations, actors are processed in batches per frame/tick, smoothing CPU load and preventing spikes.
- **Lazy Evaluation:** Actors do not re-evaluate every frame, only when triggered.

---

### 4. Economic Shocks & Adaptation
- **Shock Events:** Random or scripted events (e.g., disasters, supply shortages, booms) affect market conditions.
- **Adaptive Behaviour:** Actors respond by adjusting utility weights, savings rates, or even their decision profiles (e.g., become more risk-averse after a crisis).
- **Cultural Response:** Different cultures may adapt differently to shocks (e.g., some may hoard, others may share).

---

### 5. Debugging & Visualisation
- **Decision Logging:** Each actor logs their decision process (needs, evaluated goods, chosen purchases, savings) for developer review.
- **Visualisation Tools:**
  - **Market Heatmap:** Shows demand and supply for goods across the demesne.
  - **Actor Inspector:** UI panel to select an actor and view their needs, preferences, current utility calculations, and recent decisions.
  - **Event Timeline:** Visualises economic shocks and their impact on actor behaviour.
- **Debug Overlays:** In-game overlays to highlight actors making decisions, their current state, and market activity.
- **Toggleable Tools:** All debugging and visualisation tools are toggleable and only active in development builds.

---

## Data-Driven Design
- **Culture/Ancestry Data:** Preferences, savings rates, and shock responses are defined in external JSON files, loaded at runtime.
- **Actor Data Class:** Each actor instance holds references to their culture, ancestry, needs, and financial state.

---

## High-Level Flow (Pseudocode)
```
For each actor (when triggered by need or event):
    1. Update needs (e.g., hunger, comfort).
    2. Calculate utility for each available good:
        a. Base weight from culture/ancestry
        b. Adjust for current need level (marginal utility)
        c. Add randomness
        d. Adjust for price sensitivity
    3. Filter goods by affordability (disposable income)
    4. Select goods to purchase (using decision profile: greedy, knapsack, etc.)
    5. Make purchases, update inventory and needs
    6. Save remaining money according to savings propensity
    7. Log decision for debugging/visualisation
```

---

## Example Data Structure

**Culture JSON:**
```json
{
  "culture_id": "northern",
  "base_preferences": {
    "food": 1.2,
    "entertainment": 0.8,
    "luxury": 0.5
  },
  "savings_rate": 0.25,
  "shock_response": "hoard"
}
```

**Actor Data Class (GDScript):**
```gdscript
class_name DataActor
var id: int
var culture_id: String
var ancestry_id: String
var needs: Dictionary
var savings_rate: float
var disposable_income: float
var decision_profile: String
# etc.
```

---

## Summary Table

| Feature                | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| Utility Function       | Personalised, marginal, randomised, culture/ancestry-based                  |
| Budget Constraint      | Disposable income, savings propensity, optional credit                      |
| Event-Driven Triggers  | Needs/market-driven, batch processed                                        |
| Economic Shocks        | Random/scripted events, adaptive and culture-specific responses             |
| Debug/Visualisation    | Logging, heatmaps, actor inspector, event timeline, overlays                |

---

## Testability & Alignment
- **Component-based, modular design:** All logic in components, not monolithic classes.
- **Data-driven, external configs:** All static data in JSON, loaded via `global/library.gd`.
- **Signals for decoupling:** All cross-component communication via signals/event bus.
- **Static typing, clear naming, code regions:** All code follows GDScript 2.0 conventions and project naming/region rules.
- **Error handling, assertions, logging:** No silent failures, all errors are logged and asserted.
- **Documentation:** All classes and functions are fully documented.
- **Unique IDs:** Every actor, good, and culture has a unique ID, never relying on names for identification.
- **Pure Functions:** Core decision logic is pure, with no side effects, making it easy to test with different inputs.
- **Mock Market:** Provide a mock market interface for tests, so actor decisions can be tested in isolation.
- **Debug/Visualisation Hooks:** Expose hooks for logging and visualisation that can be enabled/disabled for tests. 