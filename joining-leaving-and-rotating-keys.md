# Joining, Leaving, and Rotating Keys

By the end of this chapter the cast of a
file has changed three ways — a
keyholder added, a keyholder removed,
and the data key itself replaced — each
verified by who can and cannot open the
file afterwards. The transcript is t07.

## The two different operations

Chapter 2's moving parts pay off here.
A file's keyholders can change without
touching its values, because only the
*data key's wrapping* names them. And
the data key itself can be swapped,
which re-seals every value. SOPS gives
the two operations two commands:

- **`updatekeys`** — re-wrap the data
  key for the keyholder set the current
  creation rules describe.
- **`rotate`** — invent a fresh data key
  and re-encrypt every value with it,
  wrapped for the existing keyholders.

## Someone joins: updatekeys

The flow, from the lab:

1. Add the newcomer's public key to
   `.sops.yaml` (and commit that change —
   it is the reviewable record of who
   was let in).
2. Run `sops updatekeys file.yaml`,
   which prints the change it is about
   to make, group by group, with the new
   key marked `+++`. `-y` answers the
   confirmation in advance.
3. The file's metadata now lists both
   recipients — the lab counts them:
   1 before, 2 after — and the newcomer
   decrypts the file successfully (t07).

**The trap the lab fell into, recorded
in t07 so you do not have to:**
`updatekeys` must first *unwrap* the
data key, so it needs an existing
keyholder's secret key available. Run
without one, it refuses with the same
"Failed to get the data key" message as
a failed decryption. Set
`SOPS_AGE_KEY_FILE` to a current holder's
key file before running it. (Adding a
keyholder does not need *their* secret —
only their public key and one existing
holder's secret.)

Note what did not happen: the values
were not re-encrypted. Someone who kept
an old copy of the sealed file and later
obtains the data key from elsewhere has
the old values — which is one reason the
next operation exists.

## Someone leaves: updatekeys, then rotate

Removing a keyholder is the same flow
backwards: take their key out of the
rules, run `updatekeys`. Afterwards the
lab's removed keyholder fails to decrypt
(t07 shows the refusal) and the
remaining holder succeeds.

But be precise about what removal
means. The departed keyholder could read
the file yesterday; anything they copied
in plain text is still theirs, and the
file's *data key* has not changed — if
they ever wrote it down, every copy of
the file, past and future, is open to
them. For a friendly departure from a
low-stakes file, `updatekeys` is enough.
For a real departure, follow it with:

```bash
sops rotate -i file.yaml
```

## Rotation: a new data key

`rotate` decrypts the document with the
old data key, invents a new one, and
re-seals every value. The lab verifies
the two things that must both be true:

- The file's `mac` — the fingerprint of
  its sealed contents — is different
  after rotation (the transcript prints
  both).
- The decrypted document is bit-for-bit
  what it was: its SHA-256 hash is the
  same before and after (t07).

Rotation is also the answer to "this
file has been sealed for years" hygiene:
the keyholders stay the same, the data
key does not grow old. What rotation
does *not* do is change who the
keyholders are — run `updatekeys` first
if the cast changed, then rotate if the
departure warrants it. And if a *secret
key itself* is lost or leaked, no
rotation of files helps the files that
key already opened; that keyholder needs
a new key pair, the files need
`updatekeys` to the new public key plus
rotation, and the leaked-key chapter of
your incident is the secrets themselves,
which may need changing at their source.
Chapter 14 says this plainly again.
