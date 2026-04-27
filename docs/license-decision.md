# License decision tree

Picking a license for a new repo is a one-time decision with permanent consequences (relicensing later is hard). This decision tree gives you a defensible default in 30 seconds.

## Quick decision

```
Is this RISE-direct research output (you're paid by RISE to produce it,
RISE owns the IP, no specific sub-project ownership)?
  → CC0-1.0    [matches imintengine]

Is this part of a named RISE sub-project / customer-facing product
(Digital Earth Sweden, a specific Vinnova project, an ESA-funded thread)?
  → Apache-2.0    [matches des-chatbot, swedish-space-ecosystem-viz]

Is this personal work outside RISE (your hobbies, your portfolio, side
projects you'd take with you if you left)?
  → MIT or Apache-2.0    [you decide; MIT is shorter, Apache is safer with
                          patents]

Are you not sure who owns the IP?
  → Don't pick yet. Keep it private. Talk to RISE legal.
```

## The longer version

### CC0-1.0 — public domain dedication

**What it says:** "I waive all copyright. Use freely, no attribution required, no warranty."

**When RISE picks it:** for outputs they want adopted with maximum friction-reduction. ImintEngine is CC0 — if a startup wants to fork the engine and ship a product, RISE wants that to happen with zero legal overhead.

**Trade-off:** you can't enforce attribution. If someone takes the work and sells it without credit, you have no recourse. RISE accepts this trade-off for research outputs because the goal is impact, not ownership.

**GitHub note:** GitHub's licensee detector classifies CC0 as "Other" because it's a CC license, not an OSI-approved software license. That's correct — it's just not what GitHub puts on the sidebar. Don't fight it.

### Apache-2.0 — permissive with patent grant

**What it says:** "Use, modify, distribute. Just keep my copyright notice and the LICENSE file. I grant you a patent license for what I contributed. If you sue me over patents, your patent license terminates."

**When to pick it:** sub-project / customer-facing work where you want explicit patent protection and a NOTICE-attribution path. The DES-stack picks Apache-2.0: chatbot, viz. Reason: a customer building on des-chatbot benefits from the patent grant; RISE benefits from NOTICE-attribution if a fork goes commercial.

**Trade-off:** more text to keep around (LICENSE + NOTICE). Slightly more legalese for users to read.

**GitHub note:** GitHub detects Apache-2.0 reliably *if* you use the canonical boilerplate. RISE-flavored preambles (like the imintengine pattern) confuse the detector — split into LICENSE (pure boilerplate) + NOTICE (the RISE attribution) per Apache convention §4(d).

### MIT — permissive, minimal

**What it says:** "Do whatever, just keep my copyright notice."

**When to pick it:** small utilities, libraries with negligible patent surface, work where you want maximum adoption with minimum legal text. `des-contracts` is MIT — it's a 23-class schema definition; there's no patent angle.

**Trade-off:** no patent grant. If your work uses techniques covered by patents you might own, an MIT license doesn't protect downstream users from a future patent claim by you. For most code this is irrelevant; for ML models or signal-processing patents, prefer Apache.

### Proprietary (no LICENSE file)

**What it means:** all rights reserved by default. No one outside the copyright holder may use, copy, or modify.

**When this is the right answer:** the repo is private, no consumers exist outside RISE, and you genuinely don't want anyone using it without a separate agreement. This is fine — it's a deliberate choice.

**When this is wrong:** the repo is public. *Public + no license is strictly worse than private* — anyone discovering it has no idea what they're allowed to do, and you've signaled "I don't care enough to think about this," which isn't the impression RISE wants to project. The 2026-04-26 audit caught two repos in exactly this state (`des-chatbot`, `swedish-space-ecosystem-viz`) and fixed them.

## Real examples from the RISE / DES portfolio

| Repo | License | Why |
|---|---|---|
| `imintengine` | CC0-1.0 | RISE-direct research output. Maximum-friction-reduction goal. |
| `swedish-space-ecosystem-viz` | Apache-2.0 | DES sub-project, customer-facing visualization. Patent grant + NOTICE attribution for forks. |
| `des-chatbot` | Apache-2.0 | DES sub-project, customer-facing service. Same reasoning as viz. |
| `des-contracts` | MIT | Small library, negligible patent surface. (Could have been Apache-2.0; choice is defensible either way.) |
| `agentic_workflow` | None (private) | Personal retrospective + tooling. Stays private, license decision deferred. |
| `omni-rag` | None (private) | Tooling. Renamed from des-agent. Private. License pending RISE IP confirmation. |
| `rise-repo-bootstrap` | Apache-2.0 | This kit. Public, meant to be forked, RISE-attributed. |

## What NOT to do

- **Don't mix licenses across files in one repo** unless you have a very specific reason and document it in `THIRD_PARTY_LICENSES.md` (see imintengine for the pattern).
- **Don't relicense without coordination.** If a contributor exists, you need their agreement. For solo repos, you can technically relicense as the sole copyright holder, but bump the version number to make the cut clean.
- **Don't pick AGPL** for work you might want a commercial customer to use. AGPL's network-use clause forces them to release any modifications, which most enterprises won't accept.
- **Don't add a custom license.** Use one of the OSI-approved standards. Custom licenses make every legal review more expensive for everyone.

## When in doubt

Ask. RISE has IP/legal capacity. The 2026-04-26 audit specifically blocked further license work pending RISE consultation for repos where ownership wasn't crystal clear (private repos, des-contracts retroactively). That blocking is a feature, not a bug — the wrong license choice is hard to undo.

## Programmatic guidance for the CLI

The `bash scripts/new-repo.sh` flow asks classification questions in this order:

1. *Is this for RISE, sub-project, or personal?*
2. *Public or private?*

The combination determines the default license suggestion:

| Classification | Visibility | Default license suggestion |
|---|---|---|
| RISE-direct | Public | CC0-1.0 |
| RISE-direct | Private | CC0-1.0 (in the LICENSE file when later flipped public) |
| Sub-project | Public | Apache-2.0 |
| Sub-project | Private | Apache-2.0 |
| Personal | Public | MIT |
| Personal | Private | (none — proprietary) |

You can always override.
