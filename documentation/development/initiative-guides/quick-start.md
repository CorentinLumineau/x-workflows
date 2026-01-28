# Quick Start Guide

**For**: Creating a new initiative in under 5 minutes

---

## Step 1: Create Initiative Directory (1 min)

```bash
cd documentation/milestones
mkdir my-initiative
```

---

## Step 2: Copy Template (1 min)

```bash
cp ../playbooks/templates/initiative-template.md my-initiative/README.md
```

---

## Step 3: Edit Placeholders (2 min)

Replace in `my-initiative/README.md`:
- `[Initiative Name]` → Your initiative name
- `YYYY-MM-DD` → Today's date
- `[Milestone Name]` → Your milestone names
- `X weeks / Y hours` → Your estimates

---

## Step 4: Create Milestone Files (1 min)

```bash
cd my-initiative
cp ../../playbooks/templates/milestone-template.md milestone-1.md
cp ../../playbooks/templates/milestone-template.md milestone-2.md
# Or use phase-template.md for phased initiatives
```

---

## Step 5: Register Initiative (30 sec)

Add to `milestones/README.md` under "Active Initiatives":

```markdown
### X. My Initiative

**Location**: `my-initiative/`
**Status**: 🟢 Ready to Start
**Timeline**: X weeks
**Impact**: High/Medium/Low - Brief description

**Quick Links**:
- [Initiative Overview](my-initiative/README.md)
```

---

## Done!

You now have a fully structured initiative ready to track.

**Next Steps**:
- Fill in milestone details
- Start implementation
- Update progress as you go

**Need More Details?** See [playbooks/README.md](../README.md)
