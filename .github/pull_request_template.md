<!--
Fill in every part. Name two reviewers from the table in docs/MS2_PLAN.md section 8.6.
If this change touches code someone else owns or uses, that person must be one of them.
Branch name: <name>/<module>-<topic>. Post in the group chat when you push.
-->

## What and why

Task ID: <!-- e.g. ANV-3 -->

<!-- One or two sentences: what this pull request changes and why. -->

## How to check it

<!-- The commands to run and what you should see. For example: -->

```
dune build
dune test
```

## My understanding

<!--
Written by you, the human, in your own words. Not by an AI agent.
What do the main parts do, and how do they fit together?
-->

## AI use

<!--
What the AI agent did (or "None"), and how you checked its work.
Add the same information as a row in docs/AI-LOG.md.
-->

## Expected answers

<!--
For each new test: how the expected value was worked out (for example, by hand
from a drawing of the level). Never by running the implementation.
Write "No new tests" if there are none.
-->

## Checklist

- [ ] `dune build` succeeds
- [ ] `dune test` passes
- [ ] `dune fmt` leaves no changes
- [ ] `.mli` comments updated for anything I added or changed
- [ ] Row added to `docs/AI-LOG.md`
- [ ] Entry added to `docs/DECISIONS.md` (only if a decision was made)
- [ ] No AI attribution lines in any commit or in this description (no `Co-Authored-By` AI line, no "Generated with" footer)
