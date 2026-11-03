# Glossary

**Creation rules** — the entries in a
`.sops.yaml` file that decide, per path,
whose keys seal a new file and which
values get sealed. First match wins.

**Data key** — the random key invented
per file. Values are sealed with it;
master keys only ever wrap and unwrap
it.

**dotenv** — the flat `NAME=value` file
format shells and programs read as
environment variables. One of the
formats SOPS seals.

**Encrypted regex** — a pattern matched
against keys; only values whose keys
match are sealed. The partial-encryption
tool of chapter 8.

**exec-env / exec-file** — SOPS commands
that run another command with the
decrypted secrets present — in its
environment, or as a temporary file —
and remove them when it ends.

**Key group** — a named set of master
keys in a file's wrapping. With a
Shamir threshold, one successful unwrap
is required from each of a number of
groups.

**MAC** — message authentication code:
a check value over the whole document,
sealed with the data key, that makes
any later edit to the file fail
decryption instead of passing silently.

**Master key** — a key that wraps a
data key: an age key, a PGP key, or a
key held by a cloud key service or by
HashiCorp Vault.

**Metadata block** — the `sops:` section
at the end of a sealed file: wrapped
data keys, recipients, last-modified
time, MAC, version. Readable by anyone;
hold no secrets in it.

**Recipient** — a public key named in a
sealed file: someone whose secret key
can unwrap the data key. For age, the
`age1...` string.

**Rotate** — replacing a file's data
key and re-sealing every value under
the new one, for the same keyholders.

**Shamir threshold** — the number of
key groups that must each contribute a
successful unwrap before the data key
can be rebuilt. Named for Shamir's
secret sharing, the splitting scheme
underneath.

**SOPS_AGE_KEY_FILE** — the environment
variable naming the file that holds your
age secret key (or several). SOPS's
usual way of finding your identity.

**updatekeys** — the command that
re-wraps a file's data key to match the
keyholder set the current creation rules
describe, after people join or leave.

**Wrapped key** — a data key after
encryption to a master key: the `enc`
blob in the metadata, useless without
the matching secret half.
