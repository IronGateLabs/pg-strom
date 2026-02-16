## ADDED Requirements

### Requirement: Project properties configuration
The repository SHALL contain a `sonar-project.properties` file at the repository root that configures the SonarCloud project key (`IronGateLabs_pg-strom`), organization (`irongatelabs`), and source paths.

#### Scenario: Properties file defines project identity
- **WHEN** SonarCloud scanner runs
- **THEN** it SHALL use project key `IronGateLabs_pg-strom` and organization `irongatelabs`

#### Scenario: Source directories are specified
- **WHEN** SonarCloud scanner determines analysis scope
- **THEN** it SHALL include `src/`, `arrow-tools/` as source directories

### Requirement: Noise exclusion from analysis
The `sonar-project.properties` SHALL exclude directories containing deprecated code, generated documentation, vendored libraries, and test fixtures from analysis.

#### Scenario: Deadcode is excluded
- **WHEN** SonarCloud analyzes the project
- **THEN** files under `deadcode/` SHALL NOT be analyzed

#### Scenario: Generated docs are excluded
- **WHEN** SonarCloud analyzes the project
- **THEN** files under `docs/` SHALL NOT be analyzed

#### Scenario: Vendored flatbuffers are excluded
- **WHEN** SonarCloud analyzes the project
- **THEN** files under `src/flatbuffers/` SHALL NOT be analyzed

#### Scenario: Test fixtures are excluded from source analysis
- **WHEN** SonarCloud analyzes the project
- **THEN** files under `test/`, `fluentd/`, and `man/` SHALL NOT be analyzed as source code

### Requirement: CUDA file language mapping
The configuration SHALL map `.cu` file extensions to the C++ language analyzer so that CUDA kernel code is analyzed.

#### Scenario: CUDA files analyzed as C++
- **WHEN** SonarCloud encounters a `.cu` file in `src/`
- **THEN** it SHALL analyze the file using the C++ language rules

### Requirement: Coverage report path pre-configuration
The configuration SHALL specify the expected path for coverage reports so that future test coverage integration works without modifying `sonar-project.properties`.

#### Scenario: Coverage path is configured
- **WHEN** a coverage report exists at the configured path
- **THEN** SonarCloud SHALL ingest it during analysis

### Requirement: GitHub Actions CI workflow
The repository SHALL contain a GitHub Actions workflow at `.github/workflows/sonarcloud.yml` that runs SonarCloud analysis automatically.

#### Scenario: Analysis runs on push to master
- **WHEN** a commit is pushed to the `master` branch
- **THEN** the workflow SHALL trigger a SonarCloud analysis

#### Scenario: Analysis runs on pull requests
- **WHEN** a pull request is opened or updated
- **THEN** the workflow SHALL trigger a SonarCloud analysis with PR decoration

#### Scenario: Workflow uses SONAR_TOKEN secret
- **WHEN** the workflow executes the SonarCloud scanner
- **THEN** it SHALL authenticate using the `SONAR_TOKEN` GitHub secret
