# MS2 checklist

MS2 is due on Gradescope **Mon Nov 23, 9:00 pm**. Team target: the slice works
end to end by Sat Nov 21. Tasks behind each handoff are in section 8 of
[the MS2 plan](MS2_PLAN.md).

A handoff is the moment one person's work becomes something another person
builds on. "Merged" means on `main` after two approvals. "End of day" means
11:59 pm. If a handoff will be late, its owner says so in the group chat before
the due time, with a new time. Day-to-day task status lives on the team's shared
tracker (link in the group chat); Anvi ticks the boxes here in batches.

## Tue Nov 17
- [x] **H0** · Anvi → everyone · Ratified shared contract; answers to O1 and O3.
  *Done when* all five said yes in the group chat (D13, D17, D19).
- [ ] **H0b** · Victor → everyone · `main` protected, pull request template,
  how-to in the chat. *Done when* a direct push to `main` is refused and a test
  pull request shows the template.

## Wed Nov 18
- [ ] **H1a** (3pm; pull request open by noon) · Akshay → everyone · Project
  skeleton with `Types`. *Done when* a fresh clone passes `dune build` and
  `dune test`; merged.
- [ ] **H1b** (end of day) · each owner → their users · `.mli` with doc
  comments, a stub, and a test file. *Done when* `main` still builds and every
  module has an interface.

## Thu Nov 19
- [ ] **H1c** (noon) · each user → each owner · Comments on the interfaces they
  depend on. *Done when* every owner has a yes or a requested change from each
  person who relies on them.
- [ ] **H2a** (3pm) · Akshay → Anvi, Alex, Victor, Sohan · Working board.
  *Done when* board tests pass on `main`.
- [ ] **H2b** (end of day) · Akshay → Anvi, Alex, Victor · Level loader and
  `levels/tutorial01.lvl` with its known solution. *Done when* the level loads in
  a test and malformed files return errors.

## Fri Nov 20
- [ ] **H3a** (3pm) · Anvi → Victor, Sohan, Alex · Tracer for source, wall,
  target, mirror. *Done when* tracer tests with hand-worked answers pass on
  `main`.
- [ ] **H3b** (end of day) · Anvi → Victor, Sohan, Alex · Splitter and loop
  detection. *Done when* the tutorial level's known solution traces as solved.

## Sat Nov 21
- [ ] **H4a** (3pm) · Alex → everyone · Playable level from `dune exec`.
  *Done when* Akshay plays `tutorial01` to a win following written steps.
- [ ] **H4b** (3pm) · Victor → Anvi, Sohan · Solver test green and timing
  table. *Done when* `docs/investigations/solver-timing.md` is merged.
- [ ] **H4c** (3pm) · Sohan → Anvi, Alex · Generator test over many seeds.
  *Done when* it passes on `main`.
- [ ] **H5** (end of day) · everyone → Anvi, Sohan · Report input. *Done when*
  five inputs are in the shared report document.

## Sun Nov 22
- [ ] **H6** (6pm) · Anvi, Sohan → everyone · Full report draft and the ZIP
  built from a clean clone. *Done when* everyone has read the draft and the
  unzipped folder passes `dune build` and `dune test`.

## Mon Nov 23
- [ ] **H7** (9:00 pm) · Anvi → Gradescope · `MS2Report.pdf` and the ZIP, all
  teammates added. *Done when* Gradescope shows five members.

## Wed Nov 25
- [ ] **H8** · everyone · Peer evaluation forms. *Done when* Anvi has a yes from
  all five.
