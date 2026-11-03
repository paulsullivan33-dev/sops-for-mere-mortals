# SOPS for Mere Mortals

Every project accumulates secrets: a
database password in a settings file, an
API token in a config, a private key a
script needs at 3 a.m. The usual places
those secrets end up — committed to git
in plain text, pasted into a wiki, mailed
around — are all places they can leak
from later, quietly and permanently.
**SOPS** is a file editor with a
different answer. It encrypts the
*values* inside a structured file —
YAML, JSON, or a plain list of
environment variables — while leaving
the keys, the shape of the document, and
a small block of metadata readable. The
sealed file is safe to commit, safe to
share, and safe to forget about, and the
people named in it can open it, edit it
in place, and hand it to scripts without
the plain text ever resting on disk.

This guide explains how SOPS seals a
file, how to make the age key it will
use in these chapters, how to encrypt
your first settings file and prove the
round trip, how a small rules file can
choose the right keys for each path by
itself, and how the cast of keyholders
changes over time — people joining,
people leaving, keys rotating, and files
that need two keyholders present before
they will open. The credential-care rule
that governs all of it is stated in
chapter 1 and repeated wherever it
bites: **encrypt only secrets you are
entitled to handle, keep your secret key
like a house key, and treat a sealed
file's metadata as public, because
anyone can read it.**

The lab behind this guide ran the real
thing: **SOPS 3.13.3**, the official
release binary, with **age 1.3.2** as
its key tool, on a small Linux machine.
Against them the lab generated age keys
for four invented people, sealed YAML
and JSON settings files and a dotenv
file, proved the YAML round trip
byte-for-byte and the JSON round trip
equal as data (SOPS rewrites JSON in its
own layout), let a `.sops.yaml` rules
file pick different keys for two
folders, sealed only the values whose
keys matched a pattern, edited a sealed
file through a stand-in editor and with
single-value commands, added and removed
keyholders with `updatekeys`, rotated
the data key itself, built a file that
needs one key from each of two groups
before it opens, fed decrypted values to
commands through `exec-env` and
`exec-file`, checked that YAML comments
survive sealing (they do, with one
end-of-line comment moved), and recorded the exact
failures — a stranger's key, no key at
all, a tampered value, a file that was
never sealed. Every key and every secret
in the lab is invented and worthless;
the keys are printed in full in the
transcripts, which is exactly what you
must never do with a real one.

What the lab could not do, it did not
fake. SOPS also speaks to cloud key
services (AWS, Google, Azure and
others), to HashiCorp Vault, and to PGP;
the lab had no cloud account, no Vault,
and no need to borrow anyone's, so those
backends are described from the
project's documentation and labelled as
such wherever they appear.
`criteria.md` keeps the full ledger of
what was run and what was only read.

## What this guide covers

- [**What SOPS is**](what-sops-is.md) —
  the mental model: a document whose
  values are sealed but whose shape
  stays readable, and the credential
  rules that are part of the tool
- [**The moving parts**](the-moving-parts.md) —
  the random data key inside every file,
  the master keys that wrap it, the
  metadata block, and the message
  authentication code that notices edits
- [**Installing SOPS**](installing-sops.md) —
  the official release binary, the age
  tools beside it, and the version
  checks that prove both run
- [**Your first encrypted file**](your-first-encrypted-file.md) —
  one age key, one settings file sealed,
  and the round trip proved with hashes
- [**Creation rules**](creation-rules.md) —
  a `.sops.yaml` file that chooses keys
  by path, so the right people are
  sealed in without flags to remember
- [**Editing in place**](editing-in-place.md) —
  opening a sealed file in your editor,
  and the set, unset and extract
  commands for single values
- [**Other formats**](other-formats.md) —
  JSON kept as JSON, dotenv files for
  environment variables, and whole-file
  binary mode
- [**Sealing only some values**](sealing-only-some-values.md) —
  encrypted-regex for the keys that are
  secret, and the `_unencrypted` suffix
  for the ones that are not
- [**Joining, leaving, and rotating keys**](joining-leaving-and-rotating-keys.md) —
  updatekeys when the cast changes, and
  rotate when the data key itself should
  be replaced
- [**Key groups**](key-groups.md) — the
  data key split across groups, so a
  file needs two keyholders present
  before it will open
- [**SOPS in scripts**](sops-in-scripts.md) —
  exec-env and exec-file, decrypted
  output on a pipe, and the exit codes
  scripts can rely on
- [**Recipes**](recipes.md) — a settings
  file that lives in git, a token handed
  to one command, a teammate joining and
  leaving, and a scheduled job that
  reads its secret without storing it
- [**The neighbours**](the-neighbours.md) —
  age alone, git-crypt, Ansible Vault,
  the cloud key services and PGP:
  what each does that SOPS doesn't, and
  vice versa
- [**Limits**](limits.md) — keys and
  metadata in plain sight, sizes and
  filenames unhidden, no protection
  once a keyholder's machine is
  compromised, and the rest, plainly
- [**Troubleshooting**](troubleshooting.md) —
  "no identity matched", the missing
  metadata, the tampered value, and
  the traps this guide's lab fell into
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Keeping other people's secrets, opening
files you are not a keyholder of (no
chapter can; that is the point of the
tool), and running a key-management
service for an organisation are not in
this book. The cloud key services and
Vault are characterised in chapter 13
and pointed at, not taught — this guide
stays with one person or a small team,
their files, and keys they hold
themselves.

## How to use this guide

Read chapter 1 for the model and the
rules, and chapter 2 before sealing
anything you care about — knowing which
part holds what turns later confusion
into a named problem. Chapters 3 and 4
install the tools and seal a first file
in the same sitting; use invented
practice secrets until the round trip
feels boring. Chapter 5 is the chapter
that makes teams possible, and chapter 9
is the one to read before anyone joins
or leaves a real project. The lab's
transcripts live in `sops-lab/transcripts/`;
its fixture files are `sops-lab/app.yaml`,
`sops-lab/config.json`,
`sops-lab/partial.yaml` and
`sops-lab/secrets.env`, and its two
rules files are
`sops-lab/creation-rules.yaml` and
`sops-lab/key-groups-rules.yaml`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [age for Mere Mortals](https://paulsullivan33-dev.github.io/age-for-mere-mortals/)
- [Git for Mere Mortals](https://paulsullivan33-dev.github.io/git-for-mere-mortals/)
- [Chezmoi for Mere Mortals](https://paulsullivan33-dev.github.io/chezmoi-for-mere-mortals/)
- [Ansible for Mere Mortals](https://paulsullivan33-dev.github.io/ansible-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/sops-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/sops-for-mere-mortals/blob/main/LICENSE-CODE).
