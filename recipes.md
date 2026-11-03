# Recipes

Each recipe is a small complete job,
built from operations the earlier
chapters ran and verified. Where a step
generalises a lab run rather than
repeating it, the recipe says so.

## A settings file that lives in git

The founding recipe, and the reason the
tool exists:

1. Agree the keyholders and write them
   into `.sops.yaml` at the repository
   root (chapter 5), committed like any
   other code.
2. Seal the settings file in place:
   `sops encrypt -i config/app.yaml`.
3. Commit the *sealed* file and the
   rules. Never the plain original — if
   it was ever committed in plain text,
   it is in the history forever, and the
   secret itself must be changed at its
   source; sealing the file now does not
   unpublish it.
4. Teammates clone, set
   `SOPS_AGE_KEY_FILE` to their own key,
   and edit with `sops edit` (chapter 6).

Check, before every push:
`sops filestatus config/app.yaml` says
`{"encrypted":true}` (t09).

## One token, handed to one command

A deployment script needs an API token
and nothing else from the file:

```bash
TOKEN=$(sops decrypt --extract '["api"]["token"]' app.enc.yaml)
```

(run in the lab, t06, on the username;
the pattern is the same for any path).
The token lives in one shell variable,
in one process. Prefer `exec-env`
(chapter 11) when the program reads the
environment, so the value never appears
in your script's text at all.

## A teammate joins; a teammate leaves

Joining (chapter 9, t07): public key
into `.sops.yaml`, commit, then for each
existing file
`SOPS_AGE_KEY_FILE=<a current holder's key> sops updatekeys -y file`.

Leaving: key out of the rules, commit,
`updatekeys` everywhere — and if the
departure is not friendly, or the files
are precious, `sops rotate -i` each file
afterwards and change, at their sources,
any secrets the departed person could
have copied. Rotation without changing
the underlying passwords is tidiness;
rotation plus new passwords is security.

## A scheduled job that stores nothing

A nightly backup needs its repository
password. Store the password in a sealed
dotenv file (chapter 7) and let the job
run inside `exec-env`:

```bash
sops exec-env backup.enc.env 'restic-backup --repo "$BACKUP_REPO"'
```

The scheduled job's own configuration —
the part other people can read — holds
no secret at all. The key file the job
uses is the one guarded item: owner-only
permissions, on that machine only, and
chapter 1's rule applies to it in full.
(This recipe composes two verified lab
operations — dotenv sealing and
exec-env, t08 — around a backup command
the lab did not itself run.)

## The two-person file

Recovery codes for the things everything
else depends on (chapter 10, t10):
seal them under key groups with a
threshold of 2, one group per keeper.
Opening them becomes a small ceremony,
which is the point. Write down, next to
the file, who the groups' keepers are —
metadata names public keys, not people,
and future-you deserves the footnote.
