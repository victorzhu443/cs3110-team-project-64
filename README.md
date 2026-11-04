# Team Project 64 — PROJECT NAME

CS 3110, Cornell University, Fall 2026.

> **One placeholder left.** The team name is set: Team Project 64, matching
> Canvas. Replace `PROJECT NAME` in the heading above, in `AUTHORS.md`, and in
> `docs/TEAM-CONTRACT.md` once the team agrees on the project.

## What this is

One or two sentences describing what the project does, written so a reader who
has never seen it can picture someone using it. Replace this once the team has
settled on the idea in MS1.

## Team members

Each member adds **their own row** in **their own commit**. See the instructions
below.

| Name | NetID | GitHub |
|---|---|---|
| Victor Zhu | vlz3 | [@victorzhu443](https://github.com/victorzhu443) |
| Akshay Joshi | amj222 | [@akshay-joshi23](https://github.com/akshay-joshi23) |
| Anvi Savant | as3568 | [@anvisavant](https://github.com/anvisavant) |
| Sohan Madishetty | skm254 | [@SohanMads](https://github.com/SohanMads) |
| Alex Fisher | aif39 | [@alex-fishr](https://github.com/alex-fishr) |

## How to add yourself (every teammate does this once)

The MS1 handout requires a separate, correctly attributed commit from each
member, and course staff check the commit history. Do not let one person add
everybody.

First, make sure git will attribute the commit to you:

```
git config --global user.name  "Your Name"
git config --global user.email "the email on your GitHub account"
```

The email matters. If it is not an email GitHub knows about, the commit will not
be linked to your account and the attribution check can fail. You can add or
confirm addresses at https://github.com/settings/emails

Then add your row and push:

```
git clone https://github.com/victorzhu443/cs3110-team-project-64.git
cd cs3110-team-project-64
# edit README.md: add one row to the Team members table
git add README.md
git commit -m "Add <Your Name> (<netid>) to team members"
git push
```

Finally, confirm your commit shows your name and avatar at
https://github.com/victorzhu443/cs3110-team-project-64/commits/main

If two people edit the table at once, git will report a conflict in README.md.
Keep both rows, then `git add README.md` and `git commit`.

## Repository layout

Nothing is built yet. MS1 is a plan, not a prototype. The OCaml project will be
created for MS2.

## Documents

- [Team contract](docs/TEAM-CONTRACT.md) — how we work together, plus the
  responsibility table. The project handout asks us to keep that table shared
  and up to date, so it explains what each member actually delivered by the end.
- [MS1 checklist](docs/MS1-CHECKLIST.md) — what the report must contain, from
  the official template, and what is still outstanding.
- [AUTHORS.md](AUTHORS.md) — contributing authors, libraries, adapted sources,
  assets, and AI use. Required by the project handout and included in the MS2
  and MS3 submission ZIPs.

## Milestones

| Milestone | Due | Weight | Deliverable |
|---|---|---|---|
| MS1 Startup | Wed Nov 4, 9:00 pm | 2% | `MS1Report.pdf` on Gradescope, 3-4 pages |
| MS2 Work in Progress | see Canvas | 4% | `source.zip` + `MS2Report.pdf`, about 6 pages |
| MS3 Release | see Canvas | 8% | `source.zip` + `MS3Report.pdf` + `INSTALL.md` + video + `gallery.yaml` |

Peer evaluations are a further 4%. Each milestone also has a **required meeting
with a member of course staff**. Every report must begin with the team name,
members and NetIDs, project title, and a clickable URL for this repository.

MS2 and MS3 are graded from the uploaded ZIP rather than from this repository,
so the repo can keep moving while a milestone is under review. The ZIP must
leave out build output, local OPAM switches and git metadata, which is what the
`.gitignore` here is for.

## Requirements to keep in mind as we build

- A **new** OCaml project. Not a continuation of a course assignment, and not
  work submitted for another course.
- Target scope comparable to **A1 and A2 combined**, independent of team size.
- One application whose parts work together, requiring the team to agree on how
  the pieces fit. A menu over separate programs does not qualify.
- An `.mli` with OCamldoc specifications for every implementation module, except
  the main driver and test modules.
- An automated suite runnable with `dune test`, using OUnit and/or Cram.
- Important behavior testable separately from the interface.
- `AUTHORS.md` kept current.

## Course requirements this repository satisfies

- Public on github.com, so course staff can read it without individual
  invitations. MS2 and MS3 both say to keep the access arrangement set up for
  MS1, so this host is fixed for the whole project.
- A README naming the team and its members.
- One separate, correctly attributed commit per member.
- `AUTHORS.md` identifying contributing authors and acknowledging sources.
