# Team Project NN — PROJECT NAME

CS 3110, Cornell University, Fall 2026.

> **Placeholders to replace.** The heading above must become your real Canvas
> team name, which keeps the `Team Project NN` prefix, plus your project name.
> Rename the repository to match once the team agrees on it.

## What this is

One or two sentences describing what the project does, written so a reader who
has never seen it can picture someone using it. Replace this once the team has
settled on the idea in MS1.

## Team members

Each member adds **their own row** in **their own commit**. See the instructions
below.

| Name | NetID | GitHub |
|---|---|---|

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
git clone https://github.com/victorzhu443/cs3110-team-project.git
cd cs3110-team-project
# edit README.md: add one row to the Team members table
git add README.md
git commit -m "Add <Your Name> (<netid>) to team members"
git push
```

Finally, confirm your commit shows your name and avatar at
https://github.com/victorzhu443/cs3110-team-project/commits/main

If two people edit the table at once, git will report a conflict in README.md.
Keep both rows, then `git add README.md` and `git commit`.

## Repository layout

Nothing is built yet. MS1 is a plan, not a prototype. The OCaml project will be
created for MS2.

## Documents

- [Team contract](docs/TEAM-CONTRACT.md) — how we work together.

## Course requirements this repository satisfies

- Public on github.com, so course staff can read it without individual invitations.
- A README naming the team and its members.
- One separate, correctly attributed commit per member.
