# Authors

**Lumen** · Team 64 LaserTracer · CS 3110, Cornell University, Fall 2026

## Contributing authors

| Name | NetID |
|---|---|
| Victor Zhu | vlz3 |
| Sohan Madishetty | skm254 |
| Alex Fisher | aif39 |
| Anvi Savant | as3568 |
| Akshay Joshi | amj222 |

*Each teammate adds their own row, in their own commit, alongside the row they
add to the README.*

## Sources and acknowledgements

The project handout requires us to acknowledge adapted examples and other
sources here, and to respect the licenses of any code or assets we use. Record
anything that came from outside the team as we go, rather than reconstructing it
before a milestone.

### Libraries

OPAM packages beyond the standard library, and why we chose each one.

| Package | Used for | License |
|---|---|---|
| `ounit2` | The automated test suite run by `dune test`. The course uses OUnit, and the team agreed on OUnit only (decision D12). | MIT |

### Adapted code and examples

Anything taken or adapted from a tutorial, textbook, lecture demo, Stack
Overflow answer, or library documentation. Give the source and say what was
adapted.

- *(none yet)*

### Assets

Images, sounds, fonts, or data files that the team did not create, with their
source and license.

- *(none yet)*

### AI assistance

The course permits AI assistance and asks us to describe our use of it in the
milestone reports. Each of us remains responsible for the correctness of what we
submit and must be able to explain how it works. Our team contract records how
we disclose assisted work and who reviews it.

Summarize AI use per component here, from your rows in
[docs/AI-LOG.md](docs/AI-LOG.md). **Fill in your own rows before Sat Nov 21.**
Write "none" if you did not use AI for that component. "Who reviewed it" names
the two pull-request reviewers.

| Component | Member | How AI was used | Who reviewed it |
|---|---|---|---|
| Board and level files | Akshay Joshi |  |  |
| Beam tracer | Anvi Savant | Claude Code drafted the tracer changes for color mixing and edge-on stops, the write-up and pictures of the 17 hand-worked boards, and the tests built from them. Anvi decided every rule and worked every answer by hand first; the agent then worked them by reasoning, not by running code, and all 17 matched. Rows for #6, #8 and #12 in the AI log | Sohan Madishetty, Victor Zhu |
| Solver | Victor Zhu | Claude Code drafted `apply`, `solve`, their interface comments and eight level tests, and proposed the expected answers by reasoning from the drawings; Victor checked all eight against the drawings before the tests were run. It also drafted the timing harness and write-up, which Victor read, checking the four-mirror argument against the drawings. Rows for #16 and #17 in the AI log | Sohan Madishetty, Anvi Savant |
| Generator and test harness | Sohan Madishetty | Claude Code wrote the generator, its seed tests and the shared test helpers, and drafted the pull request descriptions. Sohan read the code and ran `dune test`; the tests check properties from `generator.mli` over seeds 1 to 200 (D13). Rows for #3 and #9 in the AI log | Alex Fisher, Akshay Joshi |
| Game state and terminal UI | Alex Fisher | Codex drafted the game and render interfaces, the game state and command parser, the renderer, the terminal loop, their tests and the README instructions, and worked out the tests' expected results from the level drawing. Alex chose the command syntax, error wording, display glyphs and exit behavior. Rows for #10, #18, #19 and #21 in the AI log | Sohan Madishetty, Anvi Savant |
| Project documents and planning | Anvi Savant | Claude drafted the MS2 plan, the pull-request template, the decision record, the agent rules, the MS2 checklist and the AI log's introduction from decisions already made. Anvi made each decision and reviewed and edited every file before it was committed. Rows for the plan, #2, #7 and #11 in the AI log | Sohan Madishetty, Victor Zhu |
| Repository and MS1 set-up | Victor Zhu | Claude drafted the README, team contract, `AUTHORS.md`, MS1 checklist and their commit messages in eight commits (Nov 2–4). Rows in the AI log | none (before the pull-request rule) |
