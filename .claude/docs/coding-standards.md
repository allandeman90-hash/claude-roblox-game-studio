# Coding Standards

Project-wide coding standards. These apply across all Luau files in `src/`.

## 1. Luau Style
See [`luau-style-guide.md`](./luau-style-guide.md) for detailed style rules.

Summary:
- PascalCase modules, camelCase locals, UPPER_SNAKE constants
- Type annotations on all public functions
- No deprecated APIs (wait, spawn, delay)
- pcall around external service calls
- Service caching at module top

## 2. Architecture Standards

### Server Authority
The server is authoritative for all game state. See `rules/server-scripts.md`.

### Client is Presentation
The client renders and collects input. It NEVER owns game state. See `rules/client-scripts.md`.

### Remotes are Validated
Every RemoteEvent handler validates every argument. See `rules/remotes.md`.

### DataStore is Protected
Session locking, schema versioning, retry logic, BindToClose. See `rules/datastores.md`.

## 3. Git Standards

### Commit Messages
Format: `type(scope): description`

- `feat(combat): add parry mechanic`
- `fix(datastore): resolve race condition`
- `refactor(ui): extract shared button component`

See `luau-style-guide.md` section 13.

### Branch Names
- `feature/<description>`
- `fix/<description>`
- `refactor/<description>`
- `prototype/<description>`
- `hotfix/<description>`

### Pull Requests
- Link to issue or design doc
- Describe what changed and why
- Include screenshots for UI changes
- List any manual testing performed
- Request review from appropriate specialist

## 4. Review Standards

### Review Mode: Full
Every change gets reviewed by the relevant specialist before merging.
- Code changes → lead-programmer + relevant specialist
- Design changes → game-designer + creative-director
- Security-sensitive → exploit-security-specialist
- Data changes → datastore-architect
- Remote changes → remotes-networking-specialist

### Review Mode: Lean
Critical changes reviewed; minor changes proceed with a single approval.
- S0/S1 bug fixes → single programmer approval
- Small refactors → single programmer approval
- New features → relevant specialist + one other

### Review Mode: Solo
Minimum review. Best for solo developers moving fast.
- User makes most decisions directly
- Agents still provide recommendations but not gates
- Critical security/data still gets flagged

Set the mode in `production/review-mode.txt` via `/start`.

## 5. Config-Driven Design

- All tuning values in config modules (`src/ReplicatedStorage/Shared/Config/*`)
- No magic numbers in gameplay code
- Designers edit configs, not code
- Config includes comments explaining each field

## 6. Error Handling

- Every external service call in pcall
- Retry logic for transient failures (exponential backoff)
- Fall back gracefully when DataStore is unavailable
- Never swallow errors silently — warn or log
- Structured logging, not raw `print()`

## 7. Performance Standards

### Server
- Heartbeat < 33ms (30 FPS minimum)
- Memory < 2GB typical
- Network < 50 KB/s per player

### Client
- FPS > 30 on mobile, > 60 on PC
- Memory < 800MB on mobile
- Load time < 10 seconds from join
- Input latency < 100ms

Benchmark changes before and after. Document perf-sensitive decisions in ADRs.

## 8. Testing Standards

- Unit tests for business logic (use TestEZ or Jest-Lua)
- Mock external services (DataStore, HttpService)
- Test edge cases, not just happy path
- Descriptive test names
- See `rules/tests.md`

## 9. Documentation Standards

- Public modules have header comments
- Complex algorithms have explanatory comments
- Architecture decisions recorded in ADRs (`docs/architecture/`)
- Design docs for every gameplay system (`design/gdd/`)
- Updates to code without doc updates = tech debt

## 10. Security Standards

- Server authority for all game state
- Remote validation (type, range, sanity)
- Rate limiting on client-triggered operations
- No secrets in client-visible locations
- Purchase processing via ProcessReceipt (idempotent)
- Regular `/exploit-check` runs

## 11. Tooling

Required:
- Git
- Claude Code

Recommended:
- Selene (linter)
- StyLua (formatter)
- Rojo or Argon (sync)
- Wally (packages)
- Aftman (tool manager)

Install via `aftman.toml`:

```toml
[tools]
rojo = "rojo-rbx/rojo@7.4.1"
selene = "Kampfkarren/selene@0.27.1"
stylua = "JohnnyMorganz/StyLua@0.20.0"
wally = "UpliftGames/wally@0.3.2"
```
