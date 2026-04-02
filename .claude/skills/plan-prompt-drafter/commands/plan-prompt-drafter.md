---
description: "Draft a structured plan-mode prompt from rough notes. Flags: --full, --help"
---

Follow these steps to transform rough draft input into a polished, structured
plan-mode prompt spec as a `.md` file.

## 1. Parse flags

Scan `$ARGUMENTS` for flags:

| Flag     | Effect                                                      |
| -------- | ----------------------------------------------------------- |
| `--full` | Present the full plan upfront instead of section-by-section |
| `--help` | List flags and stop                                         |

If `--help` is present, display this flag table and **stop**.

Everything after flags is the rough draft input. If no input is provided,
ask the user to paste or type their rough draft.

## 2. Load repo context

<!-- REPO-SPECIFIC: overrides-path -->
Read `.claude/skills/plan-prompt-drafter/repo-overrides.md` for
repo-specific context. Also read `CLAUDE.md` at the repo root.
<!-- END REPO-SPECIFIC -->

If the overrides file is missing, warn the user:

> "No `repo-overrides.md` found. Output quality depends on repo context.
> Want me to read `CLAUDE.md` and auto-generate one for your approval?"

If the user agrees, read `CLAUDE.md`, draft a `repo-overrides.md` following
the format of existing overrides files, and present it for approval before
proceeding. Do not proceed without repo context.

## 3. Analyse the rough draft

Read the rough draft input carefully. Identify:

- **Core intent** — what is the user trying to accomplish?
- **Tools and files mentioned** — map to known tools from repo context
- **Scattered ideas** — group related mentions that appear in different places
- **Ambiguous terms** — flag speech-to-text errors or unclear references
- **Missing considerations** — based on task type, note what's likely missing

Do not output anything yet.

## 4. Fix and deduplicate

Working from the analysis:

- **Fix typos and speech-to-text errors** — infer correct technical terms
  from context. If genuinely ambiguous, flag for the user in a brief note
  at the top of the output.
- **Deduplicate ruthlessly** — merge scattered mentions of the same idea
  into one clear statement in the right section.
- **Preserve specificity** — never dilute exact paths, tool names, versions,
  URLs, or config field names the user provided.

## 5. Structure the output

Organise into a `.md` file with bold headers. Use only sections that are
relevant to the prompt — do not include empty sections.

**Standard section order** (select what applies):

1. **Title** — short, imperative description of the task
2. **What We Are Building / What We Are Fixing** — 2-3 sentence summary
3. **Research Steps** — specific instructions: "read X, paying attention
   to Y"; include all URLs from the rough draft and add obvious missing
   ones; always include URLs for tool documentation when the prompt
   involves configuring a tool
4. **Design Requirements / Goals** — what the result must achieve
5. **Configuration Requirements** — for config-related prompts
6. **Commands, Flags & API** — for skill or CLI-related prompts
7. **Code Quality Standards** — conventions, formatting, naming
8. **Important Constraints** — hard rules; anything mentioned in passing
   that could break existing work gets promoted here as a bold top-level
   item
9. **Future Considerations** — out-of-scope items, explicitly deferred
10. **Process** — always last (see step 6)

**Structure rules:**
- Always break the task into implementation modules (lettered sections:
  A, B, C...) within the prompt body so Claude Code can work through
  them one at a time
- Each module should be independently surveyable and approvable

## 5a. Survey format

When the skill requires surveying the user (e.g., scoping decisions,
feature selection, out-of-scope triage), follow this interactive format:

- **One question at a time** — never present a batch of questions. Ask one,
  wait for the answer, then ask the next.
- **Checkbox style** — present options as a numbered or lettered list the
  user can select from. Include a freeform option at the end.

  Example:

  ```
  Which keybinding style do you want for window navigation?

  a. [ ] Vim-style (hjkl)
  b. [ ] Arrow keys
  c. [ ] Both with prefix differentiation
  d. [ ] Other — tell me what you have in mind
  ```

- **Confirm before moving on** — after each answer, briefly acknowledge
  the choice, then present the next question. Do not summarise all
  answers until the survey is complete.
- **Skip obvious questions** — if repo context or the rough draft already
  answers a question unambiguously, don't ask it. Note the inferred
  answer instead (e.g., "I'm assuming Catppuccin Mocha based on repo
  conventions — correct?").

## 6. Write the Process section

The Process section is always the final section. Its structure depends on
the `--full` flag:

**Default (no `--full`):**

```markdown
## Process

1. Complete all research steps above
2. Work through sections **A -> N** one at a time:
   - Present findings / proposed structure
   - Survey me interactively (one question at a time, checkbox format — see step 5a)
   - Wait for explicit approval before drafting
3. After all sections approved, present a consolidated file plan for
   final sign-off
4. Write files **one at a time**, each presented for approval
5. **Do not create or modify any files until I have given sign-off on
   each section**
```

**With `--full`:**

```markdown
## Process

1. Complete all research steps above
2. Present a full implementation plan for approval
3. After approval, implement section by section, presenting diffs at
   each step
4. **Do not create or modify any files until I have given sign-off**
```

## 7. Apply repo-specific additions

Using the loaded repo context (step 2), enhance the output:

- Add any repo-specific structural preferences as specified in the
  overrides file (e.g., before/after tables, version verification steps,
  reload commands).
- Ensure skill pointers from the overrides are referenced where relevant
  (e.g., "use `/commit` for git workflow" rather than restating conventions).
- Apply CLAUDE.md pointers: if the prompt touches areas flagged in the
  overrides, add corresponding research steps or constraints.

## 8. Elevate critical constraints

Review the entire draft output. Anything that:

- Could break existing work if missed
- Is a hard invariant the user mentioned even casually
- Is a repo-wide convention that applies to this task

Gets promoted to a top-level bold item in **Important Constraints**,
even if it was already mentioned elsewhere.

## 9. Add likely-missed considerations

Based on the task type, proactively add items the user probably didn't
mention but should:

- **Config changes**: migration path, backwards compat, reload steps
- **New features**: edge cases, conflict with existing features, cleanup
  of superseded code
- **Refactors**: what breaks, what needs updating, test coverage
- **Bug fixes**: root cause vs. symptom, regression prevention
- **Skills/commands**: sync compatibility, flag conventions, help text
- **All tasks**: git hygiene (branch naming, commit scope), idempotency

Add these as sub-items in the appropriate sections — do not create a
separate "suggestions" section.

## 10. Present draft v1 for review

This is version 1 (v1) of the draft. Present it to the user with a
**changes summary** explaining what was done to the rough input:

```markdown
### Changes from rough draft (v1)

- **Typos / speech-to-text fixes**: list specific corrections made
- **Deduplication**: list ideas that were merged and where they landed
- **Structure**: describe how content was reorganised into sections
- **Elevated constraints**: list items promoted to Important Constraints
- **Added considerations**: list proactively added items (from step 9)
- **Ambiguous terms**: flag anything that needs user clarification
```

Present the full draft prompt after the changes summary. Do **not** write
it to a file yet — show it inline for review.

## 11. Revision loop

After presenting a draft, ask the user for feedback. Three possible
outcomes:

**A. User requests changes:**
- Apply the requested changes.
- Increment the version number (v2, v3, ...).
- Present the revised draft with a **diff summary** explaining what
  changed from the previous version:

  ```markdown
  ### Changes v(N-1) -> vN

  - **Added**: new content or sections added
  - **Removed**: content or sections removed
  - **Modified**: specific changes to existing content
  - **Moved**: content relocated between sections
  ```

- Return to the start of step 11 (loop until approved).

**B. User approves:**
- Proceed to step 12.

**C. User asks a clarifying question:**
- Answer the question, then re-present the current draft version.

## 12. Finalize and output

Once the user approves a version:

1. **Write the file** to `/tmp/plan-prompt-<slugified-title>.md`.
   Slugify the title: lowercase, replace spaces with hyphens, remove
   special characters. Example: "Add Ghostty Config" becomes
   `/tmp/plan-prompt-add-ghostty-config.md`.

2. **Announce**:
   ```
   Final prompt (v<N>) written to: /tmp/plan-prompt-<slug>.md

   To use it, copy the contents into a new Claude Code conversation
   and enter plan mode, or paste it as your opening prompt.
   ```

3. **Final check** (silent — do not show to user, just verify before
   writing):
   - Every URL from the rough draft is preserved
   - Every specific path, tool name, or version is preserved
   - The Process section has explicit approval gates
   - Important Constraints captures all hard rules
   - Sections are ordered logically, not in rough-draft order
   - Task is broken into lettered implementation modules

**What NOT to do (all steps):**

- Do not add a preamble before the prompt content
- Do not over-explain things Claude Code already knows
- Do not add unnecessary caveats or hedges
- Do not restate the user's ideas beyond recognition
