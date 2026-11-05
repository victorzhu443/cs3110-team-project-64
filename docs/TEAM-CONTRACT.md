# Team contract

**Team 64 LaserTracer** · CS 3110, Fall 2026

This is the contract the team agreed and submitted in the MS1 report on
**2026-11-04**. The headings are in the same order as the MS1 report template,
so the report and this file stay in step. We revisit it before each milestone —
see [Revisiting the contract](#revisiting-the-contract) — and any change is made
here, together, rather than only in a report.

## What we hope to get out of the project

- **Anvi Savant (as3568):** project-management experience — keeping the team on
  track and making sure every deliverable and requirement is met.
- **Alex Fisher (aif39):** better collaboration skills.
- **Akshay Joshi (amj222):** experience working like a developer, including
  learning git. Akshay brings a different perspective, coming from ILR.
- **Victor Zhu (vlz3):** to learn OCaml deeply, both by using AI and by reading
  the code himself.
- **Sohan Madishetty (skm254):** building a generator that guarantees every
  puzzle is solvable, and writing the tests that prove it.

## Communication and meetings

- **Channel:** our iMessage group chat, used like a team Slack.
- **Expected updates:** everyone posts at least once a week — what they did and
  where they are.
- **Meetings:** in person before major deliverables, scheduled with LettuceMeet.
- **If you cannot attend**, or you are short on time, say so in the group chat.

## Decisions

- **How we decide:** we talk through why we would do something, what we will do,
  and how, so everyone is heard.
- **If we are split:** majority vote. With five members there are no ties.
- We expect most conflicts to be about scheduling rather than direction, so
  everyone reports their availability and progress in the group chat.

## Commitments and problems

- **Where work is tracked:** the PM keeps the task tracker of who is doing what.
- **Visibility:** we announce in the group chat whenever we push to GitHub, and
  we use the commit history to check that work is spread fairly.
- **How to say you are stuck:** say so in the group chat early, explain your
  reasoning, and ask for help.
- **If a commitment is missed:** the person is expected to own it. If that does
  not resolve it, the rest of the team talks with them and agrees on next steps.
- **If it continues:** we ask the professor or TAs for help right away.

## Review and integration

- **Review process:** every change goes through a pull request with two
  reviewers. If the change affects code that someone else owns or uses, that
  person must be one of the reviewers; the second is whoever has time.
- **Backup owners** stay familiar with a component by reviewing its interface
  and tests.
- Victor, as git lead, keeps this workflow running.
- We aim for everyone to push and review a similar amount of code.

## AI use

The course permits AI while holding each student responsible for explaining and
justifying every part of what they submit. These agreements respect that.

- **How each of us expects to use it:** we all plan to use AI to augment our
  work, within the course's AI and academic-integrity rules.
- **How we disclose AI-assisted work:** everyone discloses it, and we keep a
  running log in the repository so everyone stays on the same page.
- **Who reviews it:** the author is responsible for reviewing the code they
  push. With every push, the author explains to the team their understanding of
  the code and what its main parts do.
- **If we disagree about its use:** it goes through our normal decision process.

Source acknowledgements required by course policy go in
[`AUTHORS.md`](../AUTHORS.md), which also carries the per-component AI table the
MS2 and MS3 reports draw on.

## Revisiting the contract

- **We review this before each milestone**, including an anonymous form so
  everyone can say whether it is working and propose specific changes.
- **To change it:** agree the change together, then edit this file.

## Initial responsibilities

As submitted at MS1. Every area has a primary owner who gets it built and
connected, and a different backup owner who knows it well enough to help or take
a handoff. Update this table at MS2 and MS3 with what was actually delivered —
both milestones grade it, and MS3 asks for a clear account of what every member
delivered.

| Area | Primary owner | Backup owner | What the owner will deliver |
|---|---|---|---|
| Board, pieces, and level files | Akshay | Anvi | Board and piece types; placing, rotating, and undo; a level file format with parser, writer, and validation; 5–8 hand-made tutorial levels; saving player progress and stats; the dune project setup. |
| Beam tracer | Anvi | Victor | Tracing beams for every piece type; color mixing; loop detection; an ordered list of beam segments for the UI to animate; unit tests for each piece's behavior. |
| Solver and hints | Victor | Sohan | Search with pruning to lit cells; solving and counting solutions; three levels of hints; dead-end detection; a timing benchmark across board sizes; tests that every returned solution lights all targets. |
| Generator, difficulty, and test harness | Sohan | Alex | Seeded generator using backwards construction; decoy walls; uniqueness and difficulty checks using the solver; difficulty settings; a property test across hundreds of seeds; the shared test harness and Bisect coverage. |
| Terminal UI and game shell | Alex | Akshay | Colored board, cursor movement, and piece placement; beam animation; menus (difficulty, seed entry, tutorial); hint and dead-end display; win screen and stats; README and install instructions; leads the MS3 video. |
| Project management | Anvi | Sohan | Tracks deliverables and requirements against the handouts and rubric; runs meetings; keeps the task tracker; assembles and checks each milestone report. |
| Git workflow | Victor | Akshay | Sets up the repository and the branch and pull-request workflow; makes sure every change is reviewed before merging; helps teammates with git. |

## Where we started

The first slice, as planned at MS1: **a playable single level** — load one
hand-written level file, draw it in the terminal, let the player place and rotate
pieces by typing commands, draw the resulting beams, and announce a win when
every target is lit. The solver solves the same level in an automated test. This
exercises the board, tracer, UI, and solver together and checks our shared types
early.

Two uncertainties we agreed to investigate first:

1. **Is the solver fast enough?** Time a brute-force solver on 6×6 and 8×8
   boards with two to four pieces to place. If it is too slow, cap the board size
   or add pruning before building the generator on top of it.
2. **Does the terminal library work for all five of us?** Check `notty` or
   `minttea` for color and cursor input with a tiny colored-grid and cursor demo
   that everyone runs on their own laptop.
