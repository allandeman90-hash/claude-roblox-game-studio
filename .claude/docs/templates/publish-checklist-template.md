# Publish Checklist

**Release Version**: [vX.Y.Z]
**Target Publish Date**: YYYY-MM-DD
**Release Lead**: [user / release-manager]
**Status**: [Planning / Preparing / Ready / Released / Post-Release]

---

## 1. Code Quality

- [ ] All code reviewed (`/code-review` passed)
- [ ] No TODO/FIXME/HACK for this release
- [ ] No `print()` debug statements
- [ ] No test/debug features enabled
- [ ] No deprecated API usage (`wait()`, `spawn()`, `delay()`)
- [ ] `/luau-lint` passes

---

## 2. Data Safety

- [ ] DataStore schema changes backwards-compatible OR migration tested
- [ ] Session locking functioning
- [ ] BindToClose handler tested (simulate shutdown)
- [ ] No data loss possible during update rollout
- [ ] Backup procedure documented

---

## 3. Security

- [ ] `/exploit-check` passed with no Critical findings
- [ ] All remotes validated server-side
- [ ] No sensitive logic exposed to client
- [ ] Purchase processing idempotent (ProcessReceipt)

---

## 4. Performance

- [ ] Server heartbeat stable (< 33ms per frame)
- [ ] Client FPS acceptable on low-end mobile (> 30 FPS)
- [ ] Memory usage within budget (< 2GB server, < 800MB client mobile)
- [ ] No memory leaks (30-min session test)
- [ ] `/perf-profile` run on new features

---

## 5. Content Policy

- [ ] No Roblox ToS violations
- [ ] All text is chat-filter safe
- [ ] Age-appropriate content
- [ ] Accessibility review passed

---

## 6. Experience Configuration

- [ ] Game icon updated (512×512)
- [ ] Thumbnails updated (1920×1080, up to 10)
- [ ] Description updated
- [ ] Social links configured
- [ ] Max players set correctly
- [ ] Genre tags appropriate
- [ ] Privacy setting correct (Public / Friends / Private)

---

## 7. Rollback Plan

- [ ] Previous version identified (Roblox version history)
- [ ] DataStore rollback procedure documented (if schema changed)
- [ ] Team aware of monitoring procedures post-publish

---

## 8. Analytics & Monitoring

- [ ] Analytics events added for new features
- [ ] Dashboards ready to watch post-publish metrics
- [ ] Alert thresholds configured (crash rate, error rate, concurrency)
- [ ] First-24-hour monitoring plan in place

---

## 9. Patch Notes & Communication

- [ ] Patch notes written (`/patch-notes`)
- [ ] Patch notes reviewed and approved
- [ ] Discord announcement drafted
- [ ] Twitter/X post drafted
- [ ] Content creator notifications drafted
- [ ] In-game MOTD prepared

---

## 10. Testing

- [ ] QA test plan executed
- [ ] Regression tests passed
- [ ] Device coverage verified (mobile, PC, console if applicable)
- [ ] Multiplayer test (min players, typical, max)
- [ ] External playtest (if significant update)

---

## Go / No-Go Decision

**Status**: [✅ GO / ⏸️ HOLD / ❌ NO-GO]

**Reasoning**: [Brief explanation]

**Blockers** (if hold/no-go):
1. [Blocker with owner and ETA]
2. ...

---

## Sign-offs

- [ ] qa-lead: Quality verified
- [ ] exploit-security-specialist: Security verified
- [ ] performance-analyst: Performance verified
- [ ] release-manager: Publishing ready
- [ ] producer: Scope and communication ready
- [ ] **user: Final approval**

---

## Post-Publish Monitoring

- [ ] Watch crash rate (target < 1%)
- [ ] Watch error rate
- [ ] Watch CCU trends
- [ ] Watch DataStore errors
- [ ] Monitor player feedback (Discord, reviews)
- [ ] First check-in: 1 hour post-publish
- [ ] Second check-in: 4 hours post-publish
- [ ] Post-publish retro: 24-48 hours later
