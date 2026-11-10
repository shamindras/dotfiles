# Program: how each node runs

The control file for the overhaul. `graph.yaml` says _what_ each node must achieve; this file says _how_ every node is
run. The decision notes in [`../decisions/`](../decisions/README.md) say what is in force.

## Branch and checkpoints

- All work happens on `refactor/profile-driven-bootstrap`, one branch for the whole overhaul.
- Every kept try is a checkpoint commit on that branch. Its message follows the repo's conventional-commit style and
  ends with trailers:

  ```text
  Node: N3
  Honors: inv-home-parity
  Mints: pattern-ratchet-loop
  ```

  `Node:` is required. `Honors:` and `Mints:` are optional and name notes in `docs/decisions/`.

- The baseline is the local tag `pre-overhaul` on `main`. Nothing is pushed and no PR is opened without Shamindra's say.

## The loop (ratchet)

For each node, in the dependency order of `graph.yaml`:

1. **Gate.** Present the node's proposal. Do not write until Shamindra approves it (`human_gate`).
2. **Propose.** State one hypothesis: the change and why it should pass `verify`.
3. **Apply.** Edit only files inside `promise.writes`.
4. **Verify.** Run every `verify` command for the node, plus the floors.
5. **Keep or revert.** All green: commit (checkpoint). Anything red: `git reset --hard` to the last kept commit.
6. **Log.** Append one line to `trials.jsonl` for the try, kept or not.
7. **Repeat** until green or `budget.max_tries` (default 4) is spent.

## Rules

| Rule              | What it means                                                                                      |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| Mutable files     | Only `promise.writes` of the current node. `git diff --name-only` is checked against it.           |
| Protected files   | `docs/decisions/*` once accepted (supersede instead), `.git/`, secrets, anything outside the repo. |
| Verify rule       | A verify command is never weakened, skipped or deleted to make a node pass.                        |
| Expected failures | Checks for later nodes report XFAIL with the node id (see `vocab-expected-fail`).                  |
| Budget            | `budget.max_tries` per node. Exhausted: stop, log, escalate the spec to Shamindra.                 |
| Crash handling    | An interrupted try is reverted to the last kept commit and logged with outcome `crashed`.          |
| Evaluator         | Returns a decision and what is missing, never a bare score.                                        |
| Human only        | The objective, promoting a claim to an adr or invariant, superseding a decision.                   |
| System state      | No `./bootstrap`, `./install`, `brew install`/`upgrade`/`cleanup` on the live Mac before N16.      |

## Trial log

`trials.jsonl` holds one JSON object per line:

```json
{
  "node": "N1",
  "try": 1,
  "date": "2026-11-11",
  "hypothesis": "...",
  "diffstat": "...",
  "verify": "...",
  "outcome": "kept"
}
```

`outcome` is one of `kept`, `reverted`, `crashed`. The log is append-only.

## Tests

| Recipe              | Runs                                                              |
| ------------------- | ----------------------------------------------------------------- |
| `just test_static`  | shellcheck on the tests, harness self-test, docs lint, invariants |
| `just test_sandbox` | config-load test and the throwaway-HOME install test              |
| `just test`         | both                                                              |

CI (`.github/workflows/ci.yml`) runs `test_static` on Linux and `test` on macOS, and writes every PASS, FAIL, XFAIL,
XPASS and SKIP line to the run summary.
