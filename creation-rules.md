# Creation Rules

By the end of this chapter a single
`.sops.yaml` file at the top of a tree
decides, per folder, whose keys seal a
new file — no `--age` flag to remember,
no wrong key pasted at midnight. The
transcript is t03; the rules file ships
as `sops-lab/creation-rules.yaml`.

## The problem rules solve

Chapter 4 named the recipient on the
command line. That works for one person
and one file. It frays quickly: a
project with `prod/` and `dev/` folders
wants different keyholders for each, and
every sealing becomes a chance to name
the wrong set — sealing a production
secret to a key the whole team holds, or
to nobody who is on call.

Creation rules move the decision into a
file that can be reviewed, committed,
and shared.

## The rules file

SOPS looks for `.sops.yaml` in the
directory of the file being sealed, then
in each parent directory up to the top.
The lab's (with the lab's keys):

```yaml
creation_rules:
    - path_regex: prod/
      age: "age1svvqr...(operator),age18n58...(teammate)"
    - path_regex: dev/
      age: "age1svvqr...(operator)"
```

Each rule has a **path_regex** — a
regular expression matched against the
file's path — and the keys (and, in
later chapters, the sealing choices) for
files that match. Rules are tried in
order; the first match wins. A rule with
no `path_regex` matches everything and
makes a good last rule.

## Sealing under rules

Inside the tree, the flag disappears:

```bash
sops encrypt -i prod/settings.yaml
sops encrypt -i dev/settings.yaml
```

(`-i` seals the file in place: the plain
file is replaced by its sealed self.)

The proof is in each file's metadata:
`prod/settings.yaml` names **two**
recipients, `dev/settings.yaml` names
one. And the difference is real, not
cosmetic — the transcript decrypts the
prod file with the teammate's key
successfully, and the dev file with the
same key fails with SOPS's full refusal
message and exit code 128 (t03).

## When no rule answers

Step outside the tree, where no
`.sops.yaml` exists, and seal without
naming a key:

```text
$ sops encrypt -i orphan.yaml
config file not found, or has no creation rules, and no keys
provided through command line options
```

Exit code 1, nothing written. SOPS will
not invent a keyholder for you, and that
refusal is a safety property: a sealed
file always names, in its own metadata,
exactly who can open it, and someone
chose that list — in a rules file a team
can read, or on a command line someone
typed on purpose.

## Habits that make rules work

- **Commit the rules file.** It holds
  only public keys; it is meant to be
  read. Reviewing a change to it *is*
  reviewing a change to who can open
  production secrets.
- **Most specific rules first.** First
  match wins, so order from the narrow
  paths to the general ones.
- **Rules govern creation, not
  membership.** A file keeps the
  keyholders it was sealed with until
  someone runs `updatekeys` (chapter 9).
  Editing `.sops.yaml` does not reach
  into existing files — a fact chapter 9
  leans on and the troubleshooting
  chapter repeats.
