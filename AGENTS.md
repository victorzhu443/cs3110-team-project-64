# Rules for coding agents

This file is written to the coding agent that a member of Team 64 uses on this
repository. Each member points their agent at this file, at their own tasks in
section 8 of [docs/MS2_PLAN.md](docs/MS2_PLAN.md), and at the `.mli` files of
the modules their module depends on. Where this file or the plan and
[docs/DECISIONS.md](docs/DECISIONS.md) disagree, `DECISIONS.md` is current.

## 1. Before you write anything

1. Ask your human which task ID they are working on (for example `ANV-7`).
   Work only on that task.
2. Read this file, `docs/TEAM-CONTRACT.md`, `docs/DECISIONS.md`, and the `.mli`
   of every module your human's module depends on.
3. **Raise the attribution rule with your human before the first commit.** This
   team does not list AI tools as commit authors or co-authors. Do not add a
   `Co-Authored-By` line, a "Generated with" line, or any other AI attribution
   to a commit message or a pull request. Turn off any setting that adds one.
   Check that `git config user.name` and `git config user.email` are your
   human's own name and the email on their GitHub account. Before every push,
   run `git log origin/main..HEAD --format=%B` and confirm there is no
   attribution line. AI use is disclosed in `docs/AI-LOG.md`, `AUTHORS.md` and
   the milestone report instead.

## 2. Who decides what

**You may decide on your own**, inside files your human owns:

- private helper functions and their names
- the data structure behind an abstract type
- adding more test cases of a kind your human has already approved
- formatting and comments

**Ask your human first**, and wait for the answer:

- any choice between approaches that behave differently or that your human will
  have to explain to a grader
- adding or changing anything in your human's own `.mli`
- the expected value in any test (see section 5)
- wording of error messages a player will see
- anything a task description leaves unclear

Before a commit, explain to your human what the code does and why, and check
they can explain it back. The course requires each student to be able to
explain everything they submit.

**Stop. Your human takes it to the group chat**, and nothing changes until the
affected owners agree:

- any change to `Types` or to a ratified signature in another person's `.mli`
- any change to the game rules in D5
- touching a file owned by someone else, even to fix an obvious bug. Tell the
  owner instead.
- adding an OPAM package
- changing `dune-project`, a dune file, `.ocamlformat` or the test set-up
- building something that is out of scope for MS2: hints, dead-end warnings,
  solution counting, difficulty, uniqueness, decoy walls, prism, filter,
  combiner, undo history, saved stats, cursor movement, animation, menus,
  Bisect coverage
- anything that will make a handoff late (see `docs/MS2-CHECKLIST.md`)

**Never:**

- push to `main`, merge a pull request, or force-push
- write the "My understanding" part of a pull request for your human
- produce an expected test value by running the implementation
- copy code from an existing laser puzzle game, from a course assignment (A0 to
  A4), or from the web without your human recording the source in `AUTHORS.md`
- edit `docs/TEAM-CONTRACT.md`, or submit anything to Gradescope
- commit a temporary copy of someone else's module to get unblocked. Code
  against the `.mli`.

## 3. Code rules

- Every module has an `.mli`. Every value in it has an OCamldoc comment saying
  what it does, what it needs, and what errors it returns.
- A public function that can fail returns a result. No exception escapes a
  module.
- Nothing in `lib/` reads input or prints. Only `bin/main.ml` does.
- Randomness is seeded and passed in. Never self-initialize the random
  generator.
- A board is never modified in place.
- Run `dune build`, `dune test` and `dune fmt` before every commit. Do not
  commit if any of them fails.

## 4. Pull requests and the two-reviewer rule

The team contract says every change goes through a pull request with two
reviewers, and that if a change affects code someone else owns or uses, that
person must be one of the reviewers.

- Work on a branch named `<name>/<module>-<topic>`. Keep each pull request
  small: one task or part of one.
- Request the two reviewers from the table below. If the change touches
  something another person uses, add that person.
- You do not approve, and you do not merge. Your human merges with an ordinary
  merge commit (D18) after two approvals, once `dune build` and `dune test`
  pass on the branch.
- If your human is asked to review someone else's pull request, help them read
  it, but the review comments are theirs.
- Your human posts in the group chat when they push.

| Area | Author | First reviewer (backup) | Second reviewer |
|---|---|---|---|
| Skeleton and `Types` | Akshay | Victor | Anvi |
| Board, level | Akshay | Anvi | Alex |
| Tracer | Anvi | Victor | Sohan |
| Solver | Victor | Sohan | Anvi |
| Generator, test harness | Sohan | Alex | Akshay |
| Game, render, `main` | Alex | Akshay | Victor |
| Documentation and process files | Anvi | Sohan | Victor |
| Git set-up | Victor | Akshay | Anvi |

Reviews happen the same day: a pull request opened before 8pm is reviewed
before midnight; one opened later is reviewed by noon the next day.

Every pull request description has these parts; the template in
`.github/pull_request_template.md` lays them out.

1. **What and why.** The task ID and one or two sentences.
2. **How to check it.** The commands to run and what to expect.
3. **My understanding.** Written by the human, in their own words: what the
   main parts do.
4. **AI use.** What the agent did, and how the human checked it.
5. **Expected answers.** For each new test, how the expected value was worked
   out.
6. **Checklist.** Builds; tests pass; formatted; `.mli` comments updated;
   `docs/AI-LOG.md` row added; `docs/DECISIONS.md` entry added if a decision was
   made; no AI attribution lines.

## 5. Tests (D13)

- The human works out each expected answer by hand, from a drawing of the
  level, before the test is run. You may propose the test and the drawing; the
  human confirms the answer.
- After your human has written their own expected answers, you may work them
  out independently, by reasoning and never by running the code, and show yours
  for comparison. Your human settles any difference (D23).
- A solver result is checked by applying it and running the tracer, not by
  comparing with what the solver returned last time.
- A generator result is checked by a property that must hold for every seed.
- One test file per module. Do not edit another module's test file.

## 6. Logs

For every pull request, add a row to `docs/AI-LOG.md`: date, member, component,
what the AI did, how it was checked, pull request link. If the work settled a
design question, add an entry to `docs/DECISIONS.md`: what was decided, the
alternatives, why, and who agreed.
