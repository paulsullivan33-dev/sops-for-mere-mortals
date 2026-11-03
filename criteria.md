# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's secrets are invented fixture strings, its hosts
   are example.com hosts, and its four keyholders are invented
   people with keys generated for the lab.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 14 names what the tool
   cannot do: only values are encrypted — keys, structure,
   size, filename and the whole metadata block stay readable;
   a lost secret key seals its files forever and a leaked one
   opens everything it ever held; a removed keyholder keeps
   whatever they copied; updatekeys itself needs a current
   keyholder's key; JSON round-trips equal as data but not
   byte-for-byte; sealed files are re-rendered in SOPS's own
   layout; and nothing protects a secret at the moment it is
   legitimately opened.
8. **The ethics rule is in the text, early.** SOPS is a
   credential tool, so its line is credential care, stated in
   the README and chapter 1 before any procedure depends on
   it: encrypt only secrets you are entitled to handle, keep
   your secret key like a house key — never in the repository,
   in chat, or in the same backup as the files it opens — and
   treat every sealed file's metadata as public, because
   anyone can read it. The lab obeyed the rule literally:
   every secret in it is invented, and the keys printed in
   full in the transcripts are lab-only and worthless.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is a 2-CPU, 7.7 GB Ubuntu 24.04 sandbox,
shared with other work while the lab ran. SOPS **3.13.3** was
installed from the official release binary
`sops-v3.13.3.linux.amd64`, verified against the release's
own checksums file (`sha256sum -c` reported OK), and age
**1.3.2** from the official `age-v1.3.2-linux-amd64.tar.gz`.
No server, container or network service was involved: every
operation is a local file operation. All transcripts live in
`sops-lab/transcripts/` (t00–t11); the fixtures are
`sops-lab/app.yaml`, `sops-lab/config.json`,
`sops-lab/partial.yaml`, `sops-lab/secrets.env`,
`sops-lab/editor.sh`, `sops-lab/creation-rules.yaml` and
`sops-lab/key-groups-rules.yaml`.

Run for real, with transcripts as evidence:

- Versions of all three binaries, the binaries' SHA-256
  hashes, and the first screen of `sops --help` (t00).
- Four age key pairs generated (operator, teammate, newcomer,
  stranger), the public key recovered from a secret file with
  `age-keygen -y`, key files set owner-only (t01).
- YAML round trip: a settings fixture sealed for one age key;
  keys and structure readable, values sealed with their types
  (`str`, `int`, `bool`); decryption byte-for-byte identical
  to the original by SHA-256 and `cmp`; decryption to stdout
  (t02).
- Creation rules: one `.sops.yaml` choosing two recipients
  for `prod/` and one for `dev/`; the metadata of each file
  naming its own set; the teammate opening the prod file and
  being refused the dev file (exit 128, message quoted);
  encryption with no rules and no keys refused with exit 1
  (t03).
- JSON: sealed keeping the format (output parsed as JSON to
  prove validity); the round trip shown to differ in bytes —
  SOPS reserializes with tabs and sorted keys — and to be
  equal as data by parsed comparison; decrypted JSON piped
  into a Python one-liner to lift one field (t04).
- Partial encryption: `--encrypted-regex` sealing exactly
  the two named keys' values and no others (verified by
  counting sealed packets and by the absence of the plaintext
  fixture secrets in the output); a `_unencrypted`-suffixed
  key keeping its value in the clear inside a fully sealed
  file (t05).
- Editing: a stand-in editor script changing one value
  through the real `sops edit` temp-file flow; `sops set`
  changing a number and a string; `sops unset` removing a
  key; `sops decrypt --extract` printing one value — each
  step verified by decrypting afterwards (t06).
- updatekeys: recipient count 1 → 2 on a teammate joining
  and 2 → 1 on the operator's key being removed, the removed
  keyholder then refused, the remaining one succeeding; the
  genuine failure of `updatekeys` without a current
  keyholder's key in the environment, recorded as it
  happened, then the same command succeeding with it; and
  `rotate` changing the file's MAC while the decrypted
  document's SHA-256 stayed identical (t07).
- Scripts: a dotenv fixture sealed with the type flags;
  `exec-env` supplying a value to a command that the
  surrounding shell provably does not have (its own
  `printenv` exits 1); `exec-file` exposing a decrypted
  document to a command through the `{}` placeholder;
  decryption piped to `grep` (t08).
- Failures, with exact messages and exit codes: filestatus
  on sealed and plain files; decryption with a non-recipient
  key and with no key found; decrypting an unencrypted file
  ("sops metadata not found"); encrypting an
  already-encrypted file (refused); a one-character tamper
  of a sealed value producing the AES-GCM authentication
  failure; decryption failure exit code 128 (t09).
- Key groups: a file sealed under two age key groups with
  `shamir_threshold: 2`; neither key alone able to decrypt
  (both refusals recorded); both identities in one key file
  decrypting it (t10).
- Comments: a commented YAML fixture sealed and reopened —
  comments survive; an end-of-line comment returns on its
  own line above its key, so the file differs in layout and
  matches in data (t11).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- The non-age master-key backends: PGP, AWS KMS, Google
  Cloud KMS, Azure Key Vault and the other cloud services,
  and HashiCorp Vault's transit engine (chapter 13). The lab
  had no cloud account and no Vault, and borrowed neither.
- Binary (whole-file) mode, pointed at the age tool as the
  better-shaped default for that job (chapter 7).
- Key-group arrangements beyond two groups and threshold 2
  (chapter 10 states the general rule the lab's case
  instantiates).
- The neighbour tools of chapter 13 (git-crypt, Ansible
  Vault, password managers) — characterised, not run or
  benchmarked.
- The scheduled-backup recipe of chapter 12 composes two
  verified operations (dotenv sealing, exec-env) around a
  backup command the lab did not run, and says so.
- SOPS's `publish` and `keyservice` commands, and its use
  inside other tooling (Kubernetes operators, chezmoi's
  SOPS support), which are named where relevant, not taught.

Fixtures are this guide's own and deliberately generic:
invented service names on example.com hosts, fixture secrets
that are obviously fixture secrets, and four key pairs made
for the lab and printed in full in the transcripts because
they are worthless anywhere else. No real credential, host,
person or organisation appears anywhere in the guide or the
lab.
