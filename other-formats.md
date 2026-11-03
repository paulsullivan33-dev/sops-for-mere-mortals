# Other Formats

By the end of this chapter SOPS has
sealed a JSON document and kept it JSON,
sealed a dotenv file ready for
environment variables, and you know the
honest difference between the YAML and
JSON round trips. The transcripts are
t04 (JSON) and t08 (dotenv).

## JSON stays JSON

SOPS reads the format from the file
extension — `.yaml`, `.json` — and
writes the same format back. Sealing the
lab's `config.json`:

```bash
sops encrypt --age age1svvqr... \
    --output config.enc.json config.json
```

The result is still valid JSON (the lab
parses it with Python to prove it, t04):
the same nesting, strings sealed,
numbers and booleans sealed as typed
values, arrays sealed item by item, and
the metadata riding along as one more
top-level key named `sops`.

One honest difference from YAML,
measured in the lab: **the JSON round
trip is not byte-for-byte.** SOPS
re-serializes JSON in its own layout —
tabs for indentation, keys sorted — so
the decrypted file *differs on disk*
from the original while being **equal as
data**: parsed and compared in Python,
the two structures are identical (t04).
For YAML the round trip is exact. If a
tool downstream hashes your JSON file,
seal YAML-shaped configs with SOPS or
hash the *data*, not the bytes.

Files with no telling extension can be
steered with `--input-type` and
`--output-type`, which is also how the
dotenv mode below is switched on.

## dotenv: secrets as environment

A dotenv file is the flat cousin —
`NAME=value` lines, the shape shells and
many programs read as environment
variables:

```text
DB_PASSWORD=env-fixture-password-3141
API_TOKEN=env-fixture-token-2718
PLAIN_NOTE=this value was never secret
```

Seal it by naming the type on both
sides:

```bash
sops encrypt --age age1svvqr... \
    --input-type dotenv --output-type dotenv \
    --output secrets.enc.env secrets.env
```

Every value is sealed, including the
one whose name insists it was never
secret — SOPS does not grade values, it
seals them; chapter 8's tools are how
you seal *some* of a document. The point
of a sealed dotenv file is chapter 11:
`sops exec-env` runs a command with
these values in its environment and
nothing decrypted on disk.

## Whole files: binary mode

Any file at all — a private key, a
photo, an archive — can be sealed whole
with `--input-type binary`. The output
is a JSON document whose single value is
the entire file, encrypted as one blob.
There is no readable shape to preserve,
because there was none; decryption
returns the exact bytes. This mode is
*described* here from the documentation
rather than run in the lab: for sealing
whole files as a habit, the age tool
itself — one file in, one locked file
out, nothing else promised — is usually
the better-shaped tool, and its guide in
this series is the deeper treatment.
SOPS earns its keep on documents whose
structure you still need to see.
