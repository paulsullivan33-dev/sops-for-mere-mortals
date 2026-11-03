# The Neighbours

SOPS sits in a crowded field: other key
systems it can borrow, and other tools
that solve the same problem whole. The
neighbours *inside* SOPS are
characterised from the project's
documentation — the lab ran the age
backend only. The neighbouring *tools*
are characterised the same way; this
series' age guide is the one comparison
here that rests on a full lab of its
own.

## age, on its own

The nearest neighbour is the key tool
itself. age encrypts a whole file to a
list of recipients: one locked blob out,
no readable shape, no metadata block, no
editing flow, no notion of "some values"
— and, for exactly those reasons, the
better tool when the file has no
structure worth preserving: archives,
private keys, a backup leaving the
house. SOPS *uses* age keys but is not
age; reach for SOPS when the document's
shape is part of its usefulness and the
file will be edited by several people
over time, and for age when it will not.
The age guide in this series is the deep
treatment of the keys both tools share.

## The other master keys: PGP and the clouds

SOPS's data key can be wrapped by
several other kinds of master key, all
described here from documentation:

- **PGP keys.** The veteran option: teams
  with existing GPG keyrings can seal to
  fingerprints they already trust. In
  exchange you inherit GPG's whole
  machinery and its learning curve.
- **Cloud key services** — AWS KMS,
  Google Cloud KMS, Azure Key Vault,
  and their kin. The data key is wrapped
  by a key that never leaves the cloud
  provider; who may unwrap it is governed
  by the cloud account's own permissions,
  which gives an organisation audit logs
  and central revocation — and gives the
  file a hard dependency on that account,
  that network, and that bill being paid.
- **HashiCorp Vault's transit engine.**
  The same idea self-hosted: Vault holds
  the wrapping key and unwraps on
  request for authorised callers.

These backends compose — one file may
name an age key *and* a KMS key — and
they are why SOPS turns up in so much
infrastructure tooling: the file format
stays the same while the trust moves to
wherever the team already keeps it. For
one person or a small team holding their
own keys, age remains the backend with
the fewest moving parts, which is why
this guide spends itself there.

## git-crypt

The closest whole-tool neighbour:
git-crypt also makes secrets safe inside
a git repository, by filtering whole
*files* (chosen by pattern) through GPG
or a shared symmetric key, transparently,
on commit and checkout. The trade is
shape: git-crypt's files are entirely
sealed or entirely plain — no readable
keys, no per-value choices, no metadata
block — and its checkout model means
plain text rests in your working tree
whenever you have the key, which is
convenient and is also the exposure
SOPS's edit-in-memory flow avoids. If
your secrets live only in git and whole
files are the unit you think in,
git-crypt is a serious option; for
documents you review and edit as
documents, SOPS is the finer instrument.

## Ansible Vault

If your secrets live inside Ansible,
its built-in Vault encrypts files or
individual variables with a shared
password, decrypted at playbook run
time. It is the natural choice *inside*
that ecosystem — and it is a shared
password, with a password's whole
lifecycle: everyone who runs the
playbook knows the one secret, and
changing it is an event. SOPS's
per-person keys are the usual reason
teams graduate from it; the Ansible
guide in this series treats its own
ground.

## The password managers and the dotenv tools

KeePassXC and its kin (this series has a
guide) hold a *person's* credentials in
a database with a friendly face; SOPS
holds *files'* credentials in the files
themselves. They meet more often than
they compete — the age secret key itself
has to live somewhere, and a password
manager is a respectable home for its
backup. Smaller dotenv managers and
secret-injection CLIs solve slices of
chapter 11's problem — usually by asking
a cloud service to hold the secrets,
which trades this guide's whole bargain
(your keys, your files, no service) for
convenience. Read their key story before
believing their file story.
