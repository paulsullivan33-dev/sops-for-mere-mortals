# Sealing Only Some Values

By the end of this chapter you can seal
exactly the values that are secret in a
file whose other values are meant to be
read — endpoints, ports, feature flags —
using two tools that face opposite
directions. The transcript is t05.

## The case for partial files

Full sealing hides everything,
including things that were never secret
and are useful in the open: the public
URL a service answers on, the retry
count, the name of the thing. Keeping
those readable makes a sealed file
easier to operate — a colleague can
answer "what does this point at?"
without a key — and shrinks the set of
moments when someone decrypts the whole
document just to read one innocent
value.

The discipline matters more than the
mechanism: a value left in the clear is
*published*, to anyone who ever sees the
file, forever. Partial sealing is for
values that are public on purpose, not
for values that merely look harmless.

## encrypted-regex: name the secret keys

```bash
sops encrypt --age age1svvqr... \
    --encrypted-regex '^(db_password|api_token)$' \
    --output partial.enc.yaml partial.yaml
```

`--encrypted-regex` is matched against
each value's **key**. Only matching
values are sealed. The lab's file
(t05):

```yaml
service_name: fixture-web
public_url: https://www.example.com
db_password: ENC[AES256_GCM,...]
api_token: ENC[AES256_GCM,...]
retry_count: 3
```

Exactly two values sealed; the rest of
the document untouched. The same option
exists in creation rules
(`encrypted_regex:` in `.sops.yaml`), so
a whole tree can share one definition of
"which keys are secret" — the version of
this choice a team should prefer, since
it is reviewed once instead of typed per
file.

There is also a mirror flag,
`--unencrypted-regex`, for documents
that are secret except for a few named
keys. And nested keys are matched by
their own name at any depth, which cuts
both ways: a `password` key buried in an
unexpected section is caught by the
pattern — and so is an innocent one.

## The _unencrypted suffix: mark the value

The second tool works per value instead
of per pattern. In a fully sealed file,
any key ending in **`_unencrypted`**
keeps its value in the clear (chapter
2's metadata even records the suffix:
`unencrypted_suffix: _unencrypted`). The
lab:

```yaml
db_password: ENC[AES256_GCM,...]
db_password_hint_unencrypted: the fixture safe, third drawer
```

The hint is readable in the sealed file
— that is its job — and the password is
not (t05 verifies zero plaintext secrets
remain in either partially sealed file).

Use the suffix for facts *about* the
secret that operators need in the open:
where the real one is stored, who owns
it, when it was last rotated. Read
chapter 1's rule again before writing
one: a hint that narrows the secret down
("the usual password, but with a 4") is
not a hint, it is a leak with extra
steps.

## What partial sealing does not change

The metadata block is unaffected: the
same keyholders, the same MAC. And a
partially sealed file's clear values are
covered by the MAC too — edit one with a
text editor and decryption fails, as
chapter 15 shows for sealed values. What
you give up is only confidentiality for
the values you named, never integrity
for the document.
