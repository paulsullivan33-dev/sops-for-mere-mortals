# What SOPS Is

You have a settings file — a database
password, an API token, the credentials
a backup script needs — and the file has
to *live* somewhere: in the project, in
git, on the machines that use it. In
plain text it can live anywhere and be
read by anyone who wanders past, today
or in five years when the repository is
copied somewhere new. Sealed as one
opaque blob, it is safe but useless to
work with: nobody can see what settings
it holds, review a change to it, or
update one value without unsealing the
whole thing.

**SOPS is the middle path: a file editor
that encrypts the values in a structured
file and leaves everything else
readable.** The keys of a YAML or JSON
document stay in plain sight, so the
file's shape — which settings exist,
where they nest — can be read, diffed
and reviewed like any other file. Each
value is replaced by a sealed packet of
ciphertext. At the end of the file sits
a small **metadata block** naming the
keyholders who may open it. Commit it,
mail it, back it up: the file travels
safely, and a named keyholder can open
it, edit it in an ordinary editor, and
close it again without the plain text
ever resting on disk.

SOPS began at Mozilla (its name is short
for *Secrets OPerationS*) and is now
maintained by the Getsops project. It is
a single program with one job — the
editing and re-sealing of
secret-bearing files — and it borrows
its keys from systems that already exist
to hold them. This guide uses **age**
keys throughout, because an age key is a
small file you hold yourself; chapter 13
describes the other keyholders SOPS
trusts — cloud key services, HashiCorp
Vault, PGP — and why a team might choose
them instead.

## A first taste

After installing (chapter 3) and making
an age key (chapter 4), sealing is one
line:

```bash
sops encrypt --age age1svvqr... app.yaml > app.enc.yaml
```

and the result keeps the document's
shape while sealing every value:

```yaml
database:
    host: ENC[AES256_GCM,data:sR75...,type:str]
    password: <sealed>
```

Opening it is the same program the other
way, and chapter 4 proves — with hashes,
not hope — that what comes back is
byte-for-byte what went in.

## The rule that comes with the tool

SOPS decides who *can* open a file; it
cannot decide who *should*. So the
credential-care rule is part of this
guide from this page onward, and it is
short:

- **Encrypt only secrets you are entitled
  to handle.** Your own credentials, your
  team's shared ones with the team's
  agreement. Sealing a file does not
  launder it.
- **Keep your secret key like a house
  key.** Whoever holds it opens every
  file sealed to it. It does not go in
  the repository, in chat, or in the same
  backup as the files it opens.
- **Treat a sealed file's metadata as
  public, because it is.** The keyholders'
  public keys, the last-modified time,
  and the document's whole shape are
  readable by anyone. Never put a secret
  in a key name or a comment and call the
  file safe.

The lab obeyed the first of those
strictly: every secret in it is invented,
every key generated for the lab, on one
machine.

## What it is not

SOPS is not a password manager: it holds
secrets that belong to *files and
programs*, not a person's daily logins —
the KeePassXC guide in this series
covers that shelf. It is not a vault
service: there is no server, no account,
no one to phone; the files and keys are
yours to store and lose. It does not
distribute keys — making a key pair and
getting the public half to a teammate is
your errand (chapter 4 shows the age
tools for it). And it does not protect a
secret *after* it is opened: once a
program or a person decrypts a value, it
is plain text in their hands, and
chapter 14 is honest about where that
leaves the edges.

## Who it is for

The developer whose project settings
belong in git next to the code. The
small team that shares a handful of
service credentials and is tired of a
spreadsheet. The home-lab keeper whose
backup script needs a password at 3 a.m.
and would rather the password were not
sitting in the script. The common thread
is a file that must travel and rest in
unsafe places, and a short list of
people who may open it.
