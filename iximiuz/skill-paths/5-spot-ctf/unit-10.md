---
kind: unit

title: 'Simplified track — Docker provider (CAPD)'

name: capd

createdAt: 2026-06-19
updatedAt: 2026-06-19

# <!-- TODO(verify at publish): confirm units reference challenges via a
#      `challenges:` map (mirrors the sample's `tutorials:` map) and that the
#      `::card` `:content:` path is `challenges.<name>`. -->
challenges:
  5spot-ctf-capd: {}
---

::card
---
:content: challenges.5spot-ctf-capd
---
::

**Start here.** Learn the 5-Spot lifecycle fast on Cluster API's Docker provider —
"machines" are sibling containers, so there's zero cloud or SSH to wrangle. You'll
open a schedule window so a worker joins, keep a workload compliant on tainted spot
capacity, survive a graceful drain, and (bonus) reconcile the schedule from Git with
Flux.

Everything you learn here transfers directly to the real-infrastructure track in the
next unit — only the providers behind the bootstrap and infra specs change.
