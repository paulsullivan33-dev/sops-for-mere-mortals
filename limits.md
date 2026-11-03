# Limits

What SOPS cannot do, stated as plainly
as the rest of the guide. Every item
here was either observed in the lab or
is a property of the design described in
chapter 2.

## What a sealed file still shows

Encryption here covers **values only**.
The document's keys, its structure, its
size, its filename, and the metadata
block — keyholders' public keys, the
last-modified time, the SOPS version —
are readable by anyone who holds the
file. A key named
`ceo_misconduct_fund_password` is
protected in value and naked in name.
Partial sealing (chapter 8) widens what
is shown *by your choice*; the shape and
metadata are shown *by design*. Plan
names, comments and filenames as if they
were printed on the envelope, because
they are.

## The ends are unprotected

SOPS protects a secret at rest and in
the repository. It does nothing for the
secret in use: the program that decrypts
it holds it in memory in plain text; the
person who opens the file in an editor
sees it; a compromised keyholder machine
compromises everything that key opens.
The editor flow and `exec-file` also
place plain text in a private temp file
for the length of an edit or a command
(chapters 6 and 11) — bounded, and
removed after, but not nothing. Secrets
that must be usable are, at that moment,
readable; SOPS shortens the exposure, it
does not abolish it.

## Keys are the whole game

- **A lost secret key is final.** Files
  sealed only to it are sealed forever;
  there is no recovery service, no
  backdoor, no support desk. That is the
  design working, and it is why key
  backups — themselves guarded — matter
  as much as the files.
- **A leaked secret key opens
  everything it was ever a keyholder
  of**, including copies of files made
  before the leak. Removing the key with
  `updatekeys` and rotating (chapter 9)
  protects the future; the past needs the
  underlying secrets changed at their
  sources.
- **A departed keyholder keeps what
  they copied.** Removal is about the
  files' future, not their memory.
- **updatekeys needs a keyholder.**
  Changing the cast requires an existing
  holder's secret key at run time
  (chapter 9's trap). A file whose every
  keyholder has lost their key cannot
  even change its cast; it is a sealed
  letter to no one.

## Format edges the lab measured

- **JSON does not round-trip
  byte-for-byte.** SOPS re-serializes it
  (tabs, sorted keys); the data is exact,
  the bytes are its own (chapter 7). YAML
  round-trips exactly.
- **The rendering is SOPS's, not
  yours.** SOPS parses the document and
  writes it back in its own layout. YAML
  comments do survive the round trip —
  the lab checked, t11 — but an
  end-of-line comment comes back on its
  own line above the key it trailed, so
  the decrypted file *differs* from the
  original in layout while matching it
  in data and prose. Keep formatting
  opinions loosely; a sealed file is a
  working document, re-rendered at every
  touch.
- **Very large values and very many
  files** are each sealed value by
  value; SOPS is a document tool, not a
  bulk encryptor. Archives belong to age
  or to backup tools.

## What SOPS never claimed

It is not a key *distribution* system:
making keys and moving public halves
between people is your errand. It is not
an audit log: the metadata says when a
file last changed, not who changed it or
why — version control supplies that, if
you commit with discipline. And it is
not a sharing *policy*: who *should*
hold which key is chapter 1's rule and
your team's judgement. The tool enforces
the list it is given, exactly, and no
more wisely than the list deserves.
