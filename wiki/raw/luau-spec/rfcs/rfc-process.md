---
title: Luau RFC Process
type: raw-source
source_url: https://github.com/luau-lang/rfcs
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, process, governance]
---

# Luau RFC Process

## Categories

The Luau RFC process addresses three main areas:

1. **Syntax Changes** — evaluated for backwards compatibility, parseability, grammar ambiguities, stylistic coherence, and editor integration
2. **Semantic Changes** — assessed for understandability, performance, sandboxing, and static analysis compatibility
3. **Standard Library Additions** — judged on usefulness, performance benefits, generality, and type-checking amenability

## Process Organization

**Submission:** Contributors create a Markdown file in the `docs/` folder following a template, using descriptive lowercase filenames (e.g., `syntax-generic-functions.md`).

**Review Period:** Each RFC remains open for "at least two calendar weeks" to allow sufficient community feedback, with discussion documented in PR comments.

**Decision & Merging:** The Luau team decides whether to merge based on consensus that the change is important and workable. Any syntax/semantic revisions must be incorporated before merging.

**Shepherd Assignment:** Each RFC receives a dedicated shepherd who guides feedback and ultimately accepts or rejects the proposal.

**Special Cases:** RFCs may include conditional compatibility clauses when non-backwards-compatible changes show minimal real-world impact, or be closed if consensus isn't reached.

**Implementation:** Merged RFCs can be implemented on flexible timelines, with status updates added upon implementation completion.

## Complete RFC List (as of 2026-04)

Below is the full list of RFCs in the repository. Those captured in this wiki are marked with `[captured]`.

1. abstract-module-paths-and-init-dot-luau.md
2. amended-require-resolution.md
3. behavior-eq-metamethod.md
4. behavior-stricter-utf8-library.md
5. change-global-version.md
6. config-luauconfig.md
7. **config-luaurc.md** `[captured]`
8. const-keyword.md
9. **deprecate-getfenv-setfenv.md** `[captured]`
10. **deprecate-table-getn-foreach.md** `[captured]`
11. disallow-proposals-leading-to-ambiguity-in-grammar.md
12. explicit-type-parameter-instantiation.md
13. function-bit32-byteswap.md
14. function-bit32-countlz-countrz.md
15. **function-buffer-bits.md** `[captured]`
16. function-coroutine-close.md
17. function-debug-info.md
18. **function-inlining.md** `[captured]`
19. **function-math-lerp.md** `[captured]`
20. **function-math-map.md** `[captured]`
21. function-string-pack-unpack.md
22. function-table-clear.md
23. **function-table-clone.md** `[captured]`
24. function-table-create-find.md
25. **function-table-freeze.md** `[captured]`
26. function-vector-lerp.md
27. **generalized-iteration.md** `[captured]`
28. generic-function-subtyping.md
29. **generic-functions.md** `[captured]`
30. **index-type-operator.md** `[captured]`
31. **keyof-type-operator.md** `[captured]`
32. len-metamethod-rawlen.md
33. **local-type-inference.md** `[captured]`
34. lower-bounds-calculation.md
35. **math-constants.md** `[captured]`
36. math-isnan-isfinite-isinf.md
37. metatable-type-functions.md
38. method-type-issubtypeof.md
39. negation-types.md
40. **never-and-unknown-types.md** `[captured]`
41. **new-nonstrict.md** `[captured]`
42. **new-require-by-string-semantics.md** `[captured]`
43. **property-readonly.md** `[captured]`
44. property-writeonly.md
45. rawget-type-operator.md
46. recursive-type-restriction.md
47. relax-recursive-type-restriction.md
48. require-by-string-aliases.md
49. reserve-dollar-sign.md
50. sealed-table-subtyping.md
51. shared-self-types.md
52. support-for-generic-function-types-in-user-defined-type-functions.md
53. support-for-thread-and-buffer-types-in-user-defined-type-functions.md
54. **syntax-array-like-table-types.md** `[captured]`
55. syntax-attribute-functions-deprecated.md
56. **syntax-attribute-functions-native.md** `[captured]`
57. syntax-attributes-functions-parameters.md
58. **syntax-attributes-functions.md** `[captured]`
59. **syntax-compound-assignment.md** `[captured]`
60. **syntax-continue-statement.md** `[captured]`
61. syntax-default-type-alias-type-parameters.md
62. syntax-floor-division-operator.md
63. **syntax-if-expression.md** `[captured]`
64. syntax-leading-bar-and-ampersand.md
65. syntax-named-function-type-args.md
66. **syntax-number-literals.md** `[captured]`
67. syntax-property-access-modifiers.md
68. **syntax-singleton-types.md** `[captured]`
69. **syntax-string-interpolation.md** `[captured]`
70. **syntax-type-alias-type-packs.md** `[captured]`
71. syntax-type-ascription-bidi.md
72. **syntax-type-ascription.md** `[captured]`
73. syntax-typed-variadics.md
74. type-ascription-by-inhabitance.md
75. **type-byte-buffer.md** `[captured]`
76. type-error-suppression.md
77. type-long-integer.md
78. types-library-optional.md
79. udtf-is-extern.md
80. unsealed-table-assign-optional-property.md
81. unsealed-table-literals.md
82. unsealed-table-subtyping-strips-optional-properties.md
83. **user-defined-type-functions.md** `[captured]`
84. vector-library-vector2-constructor.md
85. **vector-library.md** `[captured]`

## Source

- Original URL: https://github.com/luau-lang/rfcs
- Captured: 2026-04-16
