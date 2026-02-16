## ADDED Requirements

### Requirement: Buffer overflow hotspot triage in src/
All buffer overflow security hotspots in `src/` SHALL be reviewed and either fixed (if genuine risk) or marked Safe in SonarCloud (if false positive with documented reasoning).

#### Scenario: Genuine buffer overflow risk identified
- **WHEN** a hotspot represents an actual unbounded buffer write
- **THEN** the code SHALL be fixed to use bounded operations (e.g., `snprintf` instead of `sprintf`, explicit length checks)

#### Scenario: False positive from PostgreSQL memory management
- **WHEN** a hotspot is triggered by `palloc`/`repalloc` managed memory that is bounds-checked by PostgreSQL
- **THEN** the hotspot SHALL be marked Safe in SonarCloud with category "Used safely"

### Requirement: Buffer overflow hotspot triage in arrow-tools/
All buffer overflow security hotspots in `arrow-tools/` SHALL be reviewed and either fixed or marked Safe.

#### Scenario: Arrow library buffer handling flagged
- **WHEN** a hotspot is triggered by Apache Arrow C++ library managed buffers
- **THEN** the hotspot SHALL be marked Safe with documentation that Arrow manages the buffer lifecycle

#### Scenario: Raw buffer operations in tool code
- **WHEN** a hotspot flags raw `memcpy`/`memmove`/string operations in tool code
- **THEN** the code SHALL be reviewed and fixed with explicit bounds checking if the size is user-controlled

### Requirement: Weak cryptography hotspot review
All weak cryptography hotspots SHALL be reviewed for actual cryptographic usage.

#### Scenario: Non-cryptographic hash usage flagged
- **WHEN** a hotspot flags a hash function used for data distribution (not security)
- **THEN** the hotspot SHALL be marked Safe with reasoning that it is not used for cryptographic purposes

#### Scenario: Actual weak cryptographic usage found
- **WHEN** a hotspot identifies genuine use of weak cryptography for security purposes
- **THEN** the code SHALL be updated to use a stronger algorithm

### Requirement: Permission hotspot review
All permission-related hotspots SHALL be reviewed for proper file/resource access patterns.

#### Scenario: PostgreSQL-managed file access
- **WHEN** a hotspot flags file access that is managed by PostgreSQL's permission model
- **THEN** the hotspot SHALL be marked Safe with reference to PostgreSQL's security model
