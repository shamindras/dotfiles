# How the overhaul was run: a graph of nodes, each closed by a loop

This folder records how the profile-driven bootstrap was built, so the method can be reused. Two graphs are kept apart:

- **The work graph** (what happened): [`graph.yaml`](graph.yaml) declares the nodes; git history records each kept try
  as a commit with a `Node:` trailer; [`trials.jsonl`](trials.jsonl) logs every try, kept or not.
- **The knowledge graph** (what is in force): [`../decisions/`](../decisions/README.md) holds small notes, one fact
  each: decisions (`adr`), invariants, patterns and vocabulary. Notes are never edited; a newer note `supersedes` an
  older one.

Bridges between them: a node or commit `Honors:` a note, and a node `mints` one.

## The nodes

```mermaid
flowchart LR
  N1[N1 harness] --> N2[N2 resolver] --> N3[N3 seed + home parity]
  N3 --> N4[N4 paths]
  N3 --> N7[N7 git auth]
  N3 --> N8[N8 doctor]
  N3 --> N5[N5 bootstrap + install]
  N4 --> N5
  N5 --> N6[N6 work profile]
  N6 --> N9[N9 app registry]
  N6 --> N10[N10 Dropbox + notes]
  N6 --> N11[N11 brew-update + settings]
  N9 --> N12[N12 cleanup]
  N10 --> N12
  N11 --> N12
  N12 --> N13[N13 weekly job] --> N14[N14 docs] --> N15[N15 CI green]
  N15 --> N16[N16 home Mac, human]
  N15 --> N17[N17 work Mac, human]
```

Each node in `graph.yaml` states its objective, what it may read and write (`promise`), its `verify` commands, the
floors every node must keep (home parity, an idempotent second run), what happens when the try budget runs out, and its
human gate.

## The loop inside each node

```mermaid
flowchart TD
  G[Human gate: proposal approved] --> P[Propose one change]
  P --> A[Apply, only inside promise.writes]
  A --> V{Verify + floors}
  V -- green --> K[Commit with Node: trailer]
  V -- red --> R[git reset to the last kept commit]
  R --> L[Log the try in trials.jsonl]
  K --> L
  L --> B{Green, or budget spent?}
  B -- green --> D[Next node]
  B -- try again --> P
  B -- budget spent --> E[Escalate the spec to a human]
```

The rules ([`program.md`](program.md)): a verify command is never weakened to pass; a check that belongs to a later node
reports **XFAIL** with that node's id and becomes a **FAIL** once a commit with that `Node:` trailer exists; a check
that passes early is **XPASS**, reported and then promoted. Nothing is skipped silently.

## What made it work

- **Write the harness first (N1).** Later nodes loop against tests that already exist, so "done" is a command, not an
  opinion.
- **Parity before deletion.** `scripts/test/check-parity` proved the generated home install equals the old one (minus
  agreed changes, listed in [`home-parity.json`](home-parity.json)) before any old file was removed.
- **Values, not branches.** Home and work differ only in values in `manifest.json`; no script asks which profile it is.
- **Reality wins over the plan.** Each node re-read the files and tools it touched first; every difference is in the
  trial log and the commit message.

## Files

| File                                       | Purpose                                            |
| ------------------------------------------ | -------------------------------------------------- |
| [`graph.yaml`](graph.yaml)                 | Nodes, dependencies, promises, verify, human gates |
| [`program.md`](program.md)                 | The control file: loop, rules, budgets, trial log  |
| [`trials.jsonl`](trials.jsonl)             | One line per try                                   |
| [`home-parity.json`](home-parity.json)     | Baseline commit and the agreed changes from it     |
| [`mise-scoreboard.md`](mise-scoreboard.md) | Weekly mise results for the work profile           |
