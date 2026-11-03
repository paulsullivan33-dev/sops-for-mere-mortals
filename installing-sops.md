# Installing SOPS

By the end of this chapter SOPS and the
age tools are installed from their
official releases, and two version
numbers prove both run. Everything after
this chapter assumes these checks pass.

## What you are installing

Two programs:

- **sops** itself — one self-contained
  binary from the Getsops project,
  published at
  `github.com/getsops/sops/releases`.
  It has no installer and no daemon; it
  is a file you put on your path.
- **age** and **age-keygen** — from the
  age project,
  `github.com/FiloSottile/age/releases`.
  SOPS does not strictly need them (it
  can use age keys it is handed), but
  making the keys in the first place is
  age-keygen's job, and this guide's
  flow uses both.

Package managers also carry both tools
on many systems, and for daily use that
route is fine. The lab used the official
release files so that the versions in
the transcripts are exactly the versions
the projects published: **SOPS 3.13.3**
and **age 1.3.2**. The SOPS release page
provides a checksums file; the lab
verified the download against it before
running anything (`sha256sum -c`
reported OK), and the transcript keeps
the hashes of both binaries.

## The install, in outline

Download the archive or binary for your
machine from the release page, verify
the checksum where one is offered, make
the binary executable, and put it
somewhere on your `PATH` — `~/bin` or
`/usr/local/bin` are the usual shelves.
The age release is a small tarball
containing `age` and `age-keygen`; it
unpacks to a folder of the same name.

No configuration follows. SOPS finds its
rules and keys per file, at run time,
from the places chapters 4 and 5
describe.

## The checks

```bash
sops --version
age --version
age-keygen --version
```

The lab's transcript (t00) records:

```text
sops 3.13.3 (latest)
v1.3.2
v1.3.2
```

`sops --version` also prints a warning
paragraph about a future change to how
it checks for newer versions. It is
noise for our purposes — the version
number is the check — and the warning
appears in the transcript exactly as
printed, so you can recognise it rather
than be surprised by it.

A second useful check costs nothing and
previews the whole tool:

```bash
sops --help | head
```

The help text opens by listing the key
systems SOPS can wrap a data key with —
the cloud services, Vault, age and PGP.
That list is chapter 13's territory;
this guide's road is the age one.
