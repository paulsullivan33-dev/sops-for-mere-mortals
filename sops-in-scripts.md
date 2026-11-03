# SOPS in Scripts

By the end of this chapter decrypted
secrets have reached a running command
three ways — in its environment, as a
temp file, and on a pipe — with nothing
plain left on disk afterwards, and you
know the exit codes a script can trust.
The transcript is t08, with the failure
codes from t09.

## The problem with the obvious way

A script that needs a password will
tempt you toward:

```bash
sops decrypt secrets.yaml > secrets.plain.yaml
./backup.sh --config secrets.plain.yaml
```

It works, and it leaves the plain file
behind when the script is interrupted,
copied when the folder is backed up,
and forgotten by everyone. SOPS's script
commands exist to give the secret a
shorter life than the script.

## exec-env: secrets as environment

```bash
sops exec-env secrets.enc.env 'printenv DB_PASSWORD'
```

`exec-env` decrypts a dotenv file (chapter
7) in memory and runs the command with
the values inserted into its
**environment**. The command is any
program that reads its configuration
from environment variables — the shape a
great many tools already use. The lab's
proof is two lines long: the command
inside `exec-env` prints the value; the
same `printenv` in the surrounding shell
prints nothing and exits 1 (t08). The
secret existed inside one process, for
its lifetime, and nowhere else.

Two cautions belong with the convenience.
A process's environment is readable by
its owner and by root on the machine —
fine on your machine, worth remembering
on shared ones. And a command that
*prints* its environment for debugging
will print the secrets too; that is your
program's choice, not SOPS leaking.

## exec-file: secrets as a temp file

Some programs insist on a config *file*.
`exec-file` decrypts to a temporary
file, runs your command with the file's
path substituted for `{}`, and removes
the temp file when the command ends:

```bash
sops exec-file app.enc.yaml 'grep host {}'
```

The lab greps the decrypted settings
through the placeholder and the temp
file is gone afterwards (t08). The file
lives in a private temp directory with
owner-only permissions; like the editor
flow of chapter 6, it is plain text on
disk for the length of one command —
the shortest life that shape allows.

## The plain pipe

For everything else, decryption to
standard output composes with the rest
of the Unix toolbox:

```bash
sops decrypt app.enc.yaml | grep -E 'host|port'
```

Nothing is written; the receiving
program gets the document on its
standard input. Chapter 4's JSON file
piped into a JSON parser is the same
pattern (t04).

## Exit codes: how scripts tell

All of the above is only scriptable
because failure is loud and coded. From
t09's measurements:

- **0** — success.
- **1** — usage errors: no keys named and
  no creation rules, decrypting a file
  with no SOPS metadata ("sops metadata
  not found"), re-sealing an
  already-sealed file.
- **128** — decryption failures: the
  key unwrapped nothing, or a value
  failed its authentication (the
  tampered file of chapter 15).

A script can rely on non-zero meaning
"stop", and on no partial plain output
being produced by a failed decryption:
SOPS verifies before it emits, which is
exactly the property the
decrypt-to-a-file habit above could not
offer.
