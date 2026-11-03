# Editing in Place

By the end of this chapter you can
change a sealed file three ways: in your
editor, one value at a time from the
command line, and by lifting a single
value out — all without a plain-text
copy ever resting on disk. The
transcript is t06.

## The editor flow

The command is the file's name given to
`sops edit` (or simply `sops file.yaml`):

```bash
sops edit app.enc.yaml
```

What happens, in order:

1. SOPS unwraps the data key with your
   identity and decrypts the document to
   a temporary file.
2. Your editor opens that plain file.
   The editor is chosen from `SOPS_EDITOR`,
   then `EDITOR`, then a default.
3. You edit — values, keys, whole
   sections; it is an ordinary document
   while you work.
4. On save-and-exit, SOPS re-seals the
   document: values encrypted, MAC
   recomputed, `lastmodified` updated.
   If nothing changed, the file is left
   alone.

The plain text exists only in that temp
file, in a private temp directory, for
the length of the edit.

The lab's transcript cannot open an
interactive editor, so a four-line shell
script played the part (`sops-lab/editor.sh`):
it receives the temp file's path and
uses `sed` to change one number,
`max_items: 25` to `max_items: 30`. The
result is the real flow, minus the
typing: after the "editor" exits, the
file on disk is still sealed (ten
`ENC[...]` packets, counted in t06) and
decrypting it shows the new number.

## One value at a time: set and unset

For a single change — the case scripts
and tired humans both meet most — an
editor is heavier than the job:

```bash
sops set app.enc.yaml '["features"]["max_items"]' '31'
sops set app.enc.yaml '["greeting"]' '"edited without an editor"'
```

The first argument after the file is a
**path** into the document, written as
JSON-style brackets. The value is **JSON**:
numbers and booleans bare, strings
arrive double-quoted inside the shell's
single quotes. `set` creates the final
key if it is missing, and re-seals the
file around the change.

Removing is the mirror:

```bash
sops unset app.enc.yaml '["greeting"]'
```

t06 runs both and decrypts after each
step, so the transcript shows the value
change, then vanish, verified rather
than asserted.

## Lifting one value out: extract

Sometimes the file should not be opened
whole at all — a script needs one
password, not the document:

```bash
sops decrypt --extract '["database"]["username"]' app.enc.yaml
```

This prints just that value
(`workshop_app` in the lab) to standard
output. Nothing else is decrypted
*outward* — though be clear-eyed: your
key still unwraps the whole data key on
your machine; extract limits what is
printed and stored, not what your own
computer momentarily holds. Chapter 11
builds on this for scripts.

## A note on the temp file

The editor flow's one soft spot is
inherent: for the length of an edit,
plain text exists in a file. SOPS uses a
private directory and removes the file
when done, and on a machine that is
yours alone this is a fair trade — it is
the same exposure as decrypting to look.
On a shared machine, prefer `set`,
`unset` and `extract`, which never write
plain text to disk at all; chapter 14
returns to this.
