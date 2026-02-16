## ADDED Requirements

### Requirement: Evaluate macro type conversion rule (cpp:S5028)
The 294 cpp:S5028 occurrences SHALL be evaluated to determine if they represent PostgreSQL macro patterns or genuine type safety issues.

#### Scenario: PostgreSQL macro pattern confirmed
- **WHEN** a majority of S5028 hits are from standard PostgreSQL macros (DatumGetX, PG_GETARG_X, etc.)
- **THEN** the rule SHALL be disabled in the SonarCloud quality profile for this project

#### Scenario: Genuine type conversion issue found
- **WHEN** an S5028 hit represents an actual unsafe implicit conversion in project code
- **THEN** an explicit cast SHALL be added

### Requirement: Reduce deep nesting (c:S134)
Functions with nesting depth exceeding 5 levels SHALL be refactored by extracting helper functions.

#### Scenario: Nested switch within nested if
- **WHEN** a function contains switch/case inside 3+ levels of if/else
- **THEN** the inner logic SHALL be extracted into a named helper function

#### Scenario: Loop with deeply nested conditionals
- **WHEN** a loop body contains 4+ levels of conditional nesting
- **THEN** early-continue or extracted helper functions SHALL reduce nesting to <=4 levels

### Requirement: Reduce cognitive complexity (c:S3776)
Functions with cognitive complexity exceeding 30 SHALL be broken into smaller functions.

#### Scenario: Complex function decomposition
- **WHEN** a function has cognitive complexity >30
- **THEN** it SHALL be decomposed into helper functions each with complexity <=20

### Requirement: Remove redundant casts (c:S859)
Redundant type casts flagged by S859 SHALL be removed.

#### Scenario: Cast to same type
- **WHEN** a value is cast to its own type
- **THEN** the cast SHALL be removed

### Requirement: Fix declaration placement (cpp:S4962)
Variable declarations SHALL be moved to point of first use where flagged by S4962.

#### Scenario: Declaration far from usage
- **WHEN** a variable is declared at the top of a block but first used 20+ lines later
- **THEN** the declaration SHALL be moved to the point of first use

### Requirement: Fix multi-statement lines (c:S999)
Lines containing multiple statements SHALL be split into separate lines.

#### Scenario: Multiple assignments on one line
- **WHEN** a line contains two or more statements separated by semicolons
- **THEN** each statement SHALL be placed on its own line
