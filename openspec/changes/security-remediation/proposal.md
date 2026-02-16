## Why

After SonarCloud exclusions are applied (see `sonarcloud-config` change), the project will still have ~111 security hotspots in `src/` and ~62 in `arrow-tools/`. These include buffer overflow risks (591 total, ~100+ in active code), weak cryptography usage (14), permission issues (10), and 3 CodeQL high-severity TOCTOU alerts (in deadcode, resolved by exclusions). The security rating is D. Addressing the hotspots in active code is needed to establish a secure baseline and improve the security rating.

## What Changes

- Triage and review all ~111 security hotspots in `src/` — mark safe patterns as "Safe" in SonarCloud, fix genuine risks
- Triage and review all ~62 security hotspots in `arrow-tools/` — same approach
- Address buffer overflow hotspots: validate buffer sizes, use bounded string operations where flagged
- Review weak cryptography hotspots (14 total) and permission issues (10 total)
- Document security patterns/decisions for future contributors

## Non-goals

- Fixing hotspots in `deadcode/` (310), `docs/` (224), or `test/` (140) — excluded by sonarcloud-config
- Adding new security features (authentication, encryption at rest, etc.)
- Modifying upstream heterodb code patterns beyond what's needed for security fixes
- Achieving A security rating in a single pass — focus on high/critical items first

## Capabilities

### New Capabilities
- `security-hotspot-triage`: Systematic review and remediation of SonarCloud security hotspots in active source code, covering buffer overflow (c:S5782, c:S3519), weak cryptography, and permission categories

### Modified Capabilities
<!-- None — no existing specs -->

## Impact

- Files affected: primarily `src/arrow_fdw.c`, `src/gpu_service.c`, `arrow-tools/arrow_meta.cpp`, `arrow-tools/pg2arrow.cpp`, and other files with hotspots
- Security rating improvement from D toward B/A
- No functional behavior changes expected — fixes are defensive hardening
- CodeQL alerts (3 high) will be resolved by deadcode exclusion in sonarcloud-config
