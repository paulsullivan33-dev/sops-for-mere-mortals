# The Moving Parts

By the end of this chapter you can look
at a sealed file and name every part of
it: the sealed values, the wrapped data
key, the metadata block, and the check
value that notices tampering. That
naming is what turns later confusion —
a file that will not open, a key that
stopped working — into a named problem.

## The document

SOPS works on structured documents:
**YAML**, **JSON**, and flat **dotenv**
lists of `NAME=value` lines. (A fourth
mode seals a whole file of any kind as
one blob; chapter 7 describes it.) The
document keeps its shape through
sealing. Keys, nesting and list order
are untouched, which is why a sealed
file can still be reviewed in a diff:
you can see that `database.password`
exists and *changed*, without seeing
what it changed from or to.

## The values

Each value — string, number, boolean,
each item in a list — is encrypted on
its own with **AES-256-GCM**, a standard
cipher that also authenticates: change
one character of the ciphertext and the
value will refuse to decrypt, rather
than decrypt to something wrong. In the
file a sealed value looks like this
(shortened here):

```text
ENC[AES256_GCM,data:sR75sMZL...,iv:P2jk...,tag:OxOz...,type:str]
```

The `type:` field records what the value
was — `str`, `int`, `bool` — so a number
comes back as a number, not as text that
looks like one. Chapter 4 shows a real
file with strings, an integer and a
boolean sealed side by side.

## The data key

Encrypting every value directly with
each keyholder's key would make the file
unwieldy and its keyholders hard to
change. Instead, SOPS invents one random
**data key** per file. The values are
sealed with the data key; the data key
itself is then **wrapped** — encrypted
separately for each keyholder — and the
wrapped copies are stored in the file.
That one decision explains most of
SOPS's behaviour:

- Opening a file means *your* key
  unwraps the data key, and the data key
  opens the values.
- Adding or removing a keyholder
  (chapter 9) only re-wraps the data
  key. The values are not touched, which
  is why it is fast.
- Rotating the data key (also chapter 9)
  is the heavier operation: a new data
  key, and every value re-sealed.

## The master keys

The keys that wrap the data key are
called **master keys**. SOPS accepts
several kinds: age keys, PGP keys, and
keys held by cloud key services (AWS
KMS, Google Cloud KMS, Azure Key Vault
and others) or by HashiCorp Vault's
transit engine. A file may name several
master keys of several kinds at once.

This guide uses age keys, one per
person. An age key pair is two halves of
one fact: a **public key** (starts
`age1...`) that anyone may know and that
SOPS seals the data key *to*, and a
**secret key** (starts
`AGE-SECRET-KEY-...`) that lives in a
small file and never travels. The age
guide in this series treats the key pair
itself in depth; here they are simply
the keyholders' names and house keys.

## The metadata block

At the end of a sealed YAML file sits a
mapping named `sops:` (in JSON it is one
more top-level key of the same name). A
real one, from chapter 4's lab:

```yaml
sops:
    age:
        - enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            ...
            -----END AGE ENCRYPTED FILE-----
          recipient: age1svvqr3y...
    lastmodified: "2026-11-03T00:56:33Z"
    mac: ENC[AES256_GCM,data:ztZ8...,type:str]
    unencrypted_suffix: _unencrypted
    version: 3.13.3
```

It holds, per master key, the wrapped
data key (`enc`) and the public
`recipient` it was wrapped for; the time
of the last change; the SOPS version
that wrote the file; and the **MAC** —
a message authentication code over the
whole document, itself sealed with the
data key. The MAC is the file's memory
of its own contents: edit a sealed file
with an ordinary editor — even just
reordering nothing but changing one
digit of a value by hand — and
decryption fails on the MAC, loudly,
instead of handing back altered values.
Chapter 15 shows that failure word for
word.

The metadata is **not** encrypted. Who
the keyholders are, when the file last
changed, and which SOPS version wrote it
are visible to anyone holding the file.
That is deliberate — it is what lets
tools check a file's status without a
key — and it is why chapter 1's rule
says to treat the metadata as public.

## The rules file

One optional part lives outside the
documents: `.sops.yaml`, the **creation
rules** file. It answers, per path, the
question "when a new file is sealed
here, whose keys wrap its data key, and
which values get sealed?" Teams keep it
at the top of a repository so the answer
is the same for everyone, with no flags
to remember. Chapter 5 builds one and
lets it choose.
