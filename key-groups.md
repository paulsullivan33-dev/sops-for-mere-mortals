# Key Groups

By the end of this chapter a file exists
that *neither* of its two keyholders can
open alone — it opens only when one key
from each of two groups is present. The
transcript is t10; the rules ship as
`sops-lab/key-groups-rules.yaml`.

## Why one key is sometimes not enough

Every file so far opens for any single
keyholder. That is the right shape for
settings a whole team uses. Some files
want the opposite shape: the root
credential, the recovery codes, the key
to the kingdom — things that should
require two people in the room, so that
one lost laptop or one bad day cannot
open them, and so that opening them is
an event two people remember.

SOPS builds that shape from **key
groups** plus a **Shamir threshold**.

## How it works

Instead of one list of master keys, the
creation rules define groups:

```yaml
creation_rules:
    - path_regex: shared[.]yaml$
      key_groups:
        - age:
            - "age1svvqr...(operator)"
        - age:
            - "age18n58...(teammate)"
      shamir_threshold: 2
```

At sealing time the data key is split
with **Shamir's secret sharing** — a
well-known scheme that cuts a secret
into shares such that any *threshold*
number of shares rebuild it and fewer
reveal nothing. Each group's wrapped
copy of the data key carries one share.
`shamir_threshold: 2` with two groups
means: one successful unwrap from each
group, or the file stays shut.

(With three groups and a threshold of
2, any two groups suffice — the pattern
generalises from "both of these people"
to "any two of these three teams". The
lab ran the two-group case; larger
arrangements follow the same rule and
are described, not run.)

## The lab's proof

The file `shared.yaml`, sealed under
those rules, records
`shamir_threshold: 2` in its metadata
and both recipients in their groups.
Then, in t10:

- The operator's key alone:
  **refused** — "Failed to get the data
  key required to decrypt the SOPS file."
- The teammate's key alone: **refused**,
  identically.
- Both key files together:
  the file opens.

That third line hides a small useful
fact — one key *file* may hold several
identities. The lab concatenated the two
lab key files into `both-keys.txt` and
pointed `SOPS_AGE_KEY_FILE` at it,
standing in for two people who have,
in real life, each brought their own
machine or their own key to the same
command.

## When to reach for groups — and when not

Groups buy real protection against a
single compromised or coerced keyholder,
at real cost: opening the file becomes
a coordinated act, and if a group's only
key is *lost*, the file is sealed
forever — no threshold arithmetic
reconstructs a share that no longer
exists. Keep groups for the few files
whose opening should be an occasion,
keep more than one key in any group
whose loss you cannot afford, and let
ordinary settings stay ordinary: one
list of keyholders, any one of whom can
open the file, as in every chapter
before this one.
