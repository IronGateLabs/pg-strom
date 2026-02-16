## ADDED Requirements

### Requirement: Fix out-of-bounds access bugs (S3519)
All S3519 bugs in `src/` and `src/dpu/` SHALL be fixed to prevent out-of-bounds memory access.

#### Scenario: Array index validation
- **WHEN** code accesses an array element using a computed index
- **THEN** the index SHALL be validated against array bounds before access

#### Scenario: Buffer copy size validation
- **WHEN** `memcpy` or `memset` operates on a destination buffer
- **THEN** the copy size SHALL NOT exceed the destination buffer capacity

### Requirement: Fix uninitialized variable bugs (S836)
All S836/cpp:S836 bugs SHALL be triaged — genuine uninitialized reads SHALL be fixed, false positives SHALL be documented.

#### Scenario: Variable used before assignment
- **WHEN** a variable is read before any assignment on a reachable code path
- **THEN** the variable SHALL be initialized at declaration or assigned before first use

#### Scenario: Conditional initialization covering all paths
- **WHEN** a variable is initialized in all branches of a conditional
- **THEN** the bug SHALL be verified as a false positive and documented

### Requirement: Fix null pointer dereference bugs (S2259)
All S2259/cpp:S2259 null dereference bugs SHALL be fixed with proper null checks.

#### Scenario: Pointer dereference after nullable return
- **WHEN** a function may return NULL and the result is dereferenced
- **THEN** a NULL check SHALL be added before dereference, with appropriate error handling

### Requirement: Fix struct comparison bugs (S5000)
The 2 struct padding comparison bugs in `arrow_fdw.c` SHALL be fixed.

#### Scenario: FdwRoutine struct comparison
- **WHEN** two `FdwRoutine` structs are compared for equality
- **THEN** comparison SHALL use member-by-member comparison instead of `memcmp`

### Requirement: Review lock ordering bugs (S5489/S5486)
The lock ordering issues in `pg_utils.h` SHALL be reviewed and fixed or documented as safe.

#### Scenario: Lock ordering violation
- **WHEN** multiple locks are acquired
- **THEN** they SHALL be acquired in a consistent, documented order

#### Scenario: Double unlock false positive
- **WHEN** the analyzer flags a double-unlock that is actually a macro-expanded pattern
- **THEN** the issue SHALL be documented as a false positive with reasoning

### Requirement: Fix out-of-scope variable access (S6655)
The 2 out-of-scope variable access bugs in `src/dpu/xpu_postgis.cc` SHALL be fixed.

#### Scenario: Temporary variable used after scope exit
- **WHEN** a variable defined in an inner scope is accessed after that scope ends
- **THEN** the variable SHALL be moved to the appropriate outer scope
