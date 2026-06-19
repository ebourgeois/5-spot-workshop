# iximiuz Labs Setup — host the workshop as a skill path

[iximiuz Labs](https://labs.iximiuz.com) runs interactive content on real,
multi-node VM **playgrounds** (more headroom than browser-only sandboxes) with an
automated **task engine** that checks a learner's progress — a natural fit for our
CTF flag mechanic. This guide publishes the 5-Spot workshop there.

Unlike Killercoda (which watches a public repo), iximiuz content is pushed from your
machine with the **`labctl`** CLI against your **author account**.

## 1. Account & CLI

1. Sign in / request authoring at https://labs.iximiuz.com (authoring may require an
   author plan — confirm on your account).
2. Install the CLI and authenticate:
   ```bash
   curl -sf https://labs.iximiuz.com/cli/install.sh | sh   # or: brew install iximiuz/labctl/labctl
   labctl auth login
   ```
   <!-- TODO(verify at publish): confirm the exact install command / tap name from
        https://labs.iximiuz.com (docs course "labs-docs"). -->

## 2. What's in this repo

The content source lives under `iximiuz/`, laid out the way `labctl` expects
(`<kind>s/<name>/`):

```
iximiuz/
  skill-paths/5-spot-ctf/        # the course wrapper
    index.md                     #   kind: skill-path (intro)
    unit-10.md                   #   kind: unit → card to the CAPD challenge
    unit-20.md                   #   kind: unit → card to the k0smotron challenge
  challenges/
    5spot-ctf-capd/index.md      # 🟢 Docker provider — 4 flags
    5spot-ctf-k0smotron/index.md # 🔵 k0s + k0smotron — 5 flags
```

**How it maps to the Killercoda scenarios** (single source of truth — we do *not*
duplicate the bring-up or verifier bash):

| Killercoda | iximiuz Labs |
|---|---|
| `setup-background.sh` pre-bake | a challenge **`init: true`** task that `git clone`s this repo and runs the *same* `workshop/.../setup-background.sh` |
| step `verify.sh` (flag) | a **regular task** that shells out to the *same* `workshop/.../verify.sh`; the header shows flags-complete = scoring |
| one multi-step scenario | one **multi-task challenge** (so all flags share one pre-baked cluster) |
| two scenarios | a **skill path** with two units, one card per challenge |

Because the init task clones `github.com/firestoned/5-spot-workshop` at runtime, the
published challenges always run the latest committed pre-bake/verifiers — **push the
repo public first**, then publish the content.

## 3. Choosing the playground

| Challenge | Base playground | Resources | Notes |
|-----------|-----------------|-----------|-------|
| CAPD (🟢) | `docker` | 4 CPU / **10 GiB**, single node | Comfortable for kind + CAPD's ~4 sibling containers. |
| k0smotron (🔵) | MiniLAN (Ubuntu, Docker) | ~2 CPU / **4 GiB per node**, 4 nodes | Needs a 2nd node as the `RemoteMachine` SSH target. Heavier — **best-effort** (same caveat the README gives Killercoda). |

List exact base names/machines with `labctl playground list` and reconcile them with
the `playground.name` / per-task `machine:` values in the two `index.md` files.

## 4. ⚠️ Resolve the TODOs before publishing

The content carries `<!-- TODO(verify at publish): ... -->` markers where a value
couldn't be confirmed offline:

- the base-playground **name** strings (esp. `minilan-ubuntu-docker`) and **machine
  hostnames** (the k0smotron tasks pin to `node-01`);
- whether skill-path units reference challenges via a **`challenges:`** map and the
  `::card` `:content:` path;
- the **k0smotron pre-bake** (`workshop/5spot-ctf-k0smotron/setup-background.sh`) was
  written for Killercoda's `node01`/`node02` + `REMOTE_NODE_HOST` and must be adapted
  to MiniLAN's hostnames/IPs so the SSH target is wired correctly.

Grep them: `grep -rn "TODO(verify at publish)" iximiuz/`.

## 5. Publish

Create each content item once (registers it server-side and scaffolds metadata),
then push the local source:

```bash
cd iximiuz

# first time only — create on the server
labctl content create challenge  5spot-ctf-capd       --dir challenges/5spot-ctf-capd
labctl content create challenge  5spot-ctf-k0smotron  --dir challenges/5spot-ctf-k0smotron
labctl content create skill-path 5-spot-ctf           --dir skill-paths/5-spot-ctf

# every update — push local → remote
labctl content push challenge  5spot-ctf-capd       --dir challenges/5spot-ctf-capd       --force
labctl content push challenge  5spot-ctf-k0smotron  --dir challenges/5spot-ctf-k0smotron  --force
labctl content push skill-path 5-spot-ctf           --dir skill-paths/5-spot-ctf          --force
```

> `labctl content create` may scaffold its own `index.md`/`__static__/` — keep our
> files (don't let it overwrite). The CLI can hot-reload on save while authoring.

## 6. Verify & share

Resulting URLs (under your author profile):

- Skill path: `https://labs.iximiuz.com/skill-paths/5-spot-ctf`
- Challenges: `https://labs.iximiuz.com/challenges/5spot-ctf-capd` ·
  `https://labs.iximiuz.com/challenges/5spot-ctf-k0smotron`

Start a challenge yourself, let the init task finish (the playground shows a loading
screen until the pre-bake completes), and confirm each flag flips to complete as you
work the steps. The same flagboard scoreboard works here — the verifiers self-post.

---

Need help with the 5-Spot side of any step?
[Quick Start](https://5spot.finos.org/installation/quickstart/) ·
[ScheduledMachine](https://5spot.finos.org/concepts/scheduled-machine/) ·
[Troubleshooting](https://5spot.finos.org/operations/troubleshooting/)
