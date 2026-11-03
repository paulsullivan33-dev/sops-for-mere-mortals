# Your First Encrypted File

By the end of this chapter you have made
an age key pair, sealed a settings file
with it, and proved — by hash, not by
eye — that decryption returns the
original file byte for byte. The
transcript is t02, with the keys made in
t01.

## Make a key pair

```bash
age-keygen -o operator.txt
```

`age-keygen` prints the **public key**
and writes a small file:

```text
# created: 2026-11-03T00:56:24Z
# public key: age1svvqr3y4rhe0dsypnrm5qa8fwlauav7f9ze5hlgm08kysczr450qmg4zht
AGE-SECRET-KEY-14CZCZ0R8ZM9QTX2MV6LRFDJAC07AERD0VGDRAT0XLV4FKHHHFRMQAJX62K
```

Three facts to hold about this file:

- The public key (the `age1...` line,
  also printed on its own) is a *name*.
  Share it freely; SOPS seals files to
  it.
- The `AGE-SECRET-KEY-...` line is the
  *house key*. The file gets owner-only
  permissions (`chmod 600`) and lives
  outside any repository. Losing it
  loses every file sealed to it;
  leaking it opens them all. The age
  guide in this series gives key care a
  full chapter; the short form is
  chapter 1's rule.
- `age-keygen -y operator.txt` prints
  the public key back from the secret
  file — handy when someone asks for
  your public half and all you have is
  the file.

The lab made four key pairs — operator,
teammate, newcomer, stranger — all
invented people with invented keys,
printed in full in t01 precisely because
they are worthless outside the lab.

## The file to seal

The lab's fixture is an ordinary
settings file with invented secrets
(`sops-lab/app.yaml`): a database block
with a password, an API block with a
token, feature flags holding a boolean
and a number, and one plain sentence as
a value. Hash it first, so the proof
later has something to bite on:

```bash
sha256sum app.yaml
```

## Seal it

```bash
sops encrypt --age age1svvqr... \
    --output app.enc.yaml app.yaml
```

`encrypt` reads the plain file and
writes the sealed one; the original is
untouched. Open the result. Every value
is an `ENC[...]` packet — strings,
`5432` the integer, `true` the boolean,
each carrying its `type:` — every key is
untouched, and the `sops:` block at the
end names the one recipient and carries
the wrapped data key and the MAC,
exactly as chapter 2 described.

## Open it, and prove the round trip

SOPS finds age identities through the
environment variable `SOPS_AGE_KEY_FILE`
(one of several places it looks;
chapter 15 lists them all from an error
message that names them):

```bash
export SOPS_AGE_KEY_FILE=~/keys/operator.txt
sops decrypt --output app.roundtrip.yaml app.enc.yaml
sha256sum app.yaml app.roundtrip.yaml
```

The lab's two hashes are identical, and
`cmp` agrees: the decrypted file is the
original, byte for byte (t02). That is
the check to run on your own first file,
with your own practice secret, before
any real credential is sealed: seal,
open, compare. If those hashes ever
disagree, stop and find out why before
trusting the arrangement.

Decrypting without `--output` writes the
plain document to standard output —
nothing lands on disk — which is the
shape chapters 11 builds on.

## One warning worth its own paragraph

The *plain* file is still sitting there.
SOPS never deletes or overwrites your
original unless you tell it to (the `-i`
flag edits a file in place, sealing or
editing the file itself; chapter 5 uses
it). Sealing a copy and then committing
both files to git is the classic own
goal of this tool: the repository now
holds the secret *and* its sealed twin.
Seal in place, or seal to a new name and
remove the plain one — and when in
doubt, `sops filestatus file.yaml`
(t09) reports `{"encrypted":true}` or
`false` without needing a key at all.
