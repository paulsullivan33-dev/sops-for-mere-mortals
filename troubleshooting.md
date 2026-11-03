# Troubleshooting

The failures below are the ones this
guide's lab actually produced, quoted
from the transcripts (t03, t07, t09), so
the words on your screen can be matched
against the words here. SOPS's errors
are verbose by design: the long message
usually names the exact problem, and the
last paragraph is the part to read first.

## "Failed to get the data key required to decrypt the SOPS file"

The umbrella failure of decryption.
Under it, SOPS reports each key group
and each recipient it tried, and why.
The common causes, in the order the lab
met them:

- **Your key is not a recipient.**
  The message says "no identity matched
  any of the recipients" (the stranger
  key of t09; the teammate reaching for
  the dev file in t03). No retry will
  help: the file was never sealed to
  you. Ask a keyholder to add your
  public key with `updatekeys`
  (chapter 9).
- **No key was found at all.** The
  message lists the places SOPS looked —
  `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY`,
  SSH key locations and others. Set
  `SOPS_AGE_KEY_FILE` to your key file
  and try again; if you do not have a
  key file, you are in the previous
  bullet's world.
- **The key file is the wrong half.**
  A file holding only a public key can
  never decrypt; SOPS needs the
  `AGE-SECRET-KEY-...` line. `age-keygen -y`
  on your file should print your public
  key — if the file does not contain a
  secret line at all, it is a public-key
  file, fit for sharing, not opening.
- **A key group is short a share.**
  With groups and a threshold
  (chapter 10), one key alone fails with
  this same umbrella message; the group
  report underneath shows one group
  satisfied and the other not. Bring
  the other keyholder.

Exit code for all of these is **128**.

## "sops metadata not found"

You asked SOPS to decrypt (or edit, or
rotate) a file that has no `sops:`
metadata block — usually because it was
never encrypted (t09), occasionally
because someone edited the block out by
hand. `sops filestatus file` settles it:
`{"encrypted":false}` means seal it
first; the command itself exits 1.

## "The file you have provided contains a top-level entry called 'sops'..."

Encrypting an already-encrypted file.
SOPS refuses rather than seal a sealed
file (double-sealing would bury the
metadata where decryption cannot find
it). You almost certainly meant `sops
edit`, or to decrypt first. Exit 1.

## "config file not found, or has no creation rules..."

Encrypting without naming keys, in a
tree with no `.sops.yaml` above the file
(t03) — or with one whose `path_regex`
does not match this file. Name the keys
on the command line, fix the regex, or
add a match-everything rule last.
Remember first match wins. Exit 1.

## "Could not decrypt with AES_GCM: cipher: message authentication failed"

The tamper alarm (t09). One character
of one sealed value was changed, and the
value's authentication tag refused it.
This is the MAC system working, not a
broken file to be repaired: get a clean
copy (version control is the usual
source), and if the change was made by a
person or a process that should not have
been able to, treat the *how* as the
real problem.

## updatekeys reports changes but fails underneath

`updatekeys` printed the group changes
(`+++`/`---` lines) and then the
data-key failure: it could not unwrap
the data key because no current
keyholder's secret was available
(chapter 9, t07). Export
`SOPS_AGE_KEY_FILE` pointing at an
*existing* keyholder's key — not the
newcomer's — and rerun. The file is
unchanged by the failed attempt; the
changes it printed were a plan, not a
deed.

## The file decrypts, but the values are wrong shapes

A JSON round trip that "changed the
file" is usually chapter 7's measured
behaviour — reserialization, data equal.
Compare parsed data, not bytes. In YAML,
a value that comes back as text
(`"5432"`) instead of a number was
probably *set* as text: `sops set`
takes JSON values, and a quoted number
is a string (chapter 6). Set it again
unquoted.

## The edit that silently did nothing

`set` with a path that does not match
creates the key you asked for — possibly
a new, wrong one beside the right one,
if a bracket or name was misspelled.
Decrypt and grep for the key after a
`set`, the way t06 does, until the
shapes are habit. In an editor session,
exiting without saving leaves the file
untouched by design; SOPS only re-seals
when the temp file changed.
