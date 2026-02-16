#!/usr/bin/env bash
#
# sync-remotes.sh — Push tags and release notes from origin to all other remotes
#
# Usage:
#   sync-remotes.sh [OPTIONS] [REPO_PATH...]
#
# Options:
#   --tag TAG       Sync a specific tag (default: latest tag)
#   --dry-run       Show what would be done without executing
#   --tags-only     Push tags without creating releases
#   --help          Show this help
#
# If no REPO_PATH is given, scans current directory and known sibling repos.
#
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
ORIGIN_OWNER="CorentinLumineau"
KNOWN_REPOS=()  # Populated by discovery or arguments
TAG=""
DRY_RUN=false
TAGS_ONLY=false

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}→${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
err()   { echo -e "${RED}✗${NC} $*" >&2; }

# ── Helpers ───────────────────────────────────────────────────────────────────

# Extract owner/repo from a git remote URL
# Handles: https://github.com/Owner/repo.git, git@host:Owner/repo.git
parse_remote_url() {
    local url="$1"
    local result

    # Strip .git suffix
    result="${url%.git}"

    if [[ "$result" == git@* ]]; then
        # git@host:Owner/repo → Owner/repo
        result="${result#*:}"
    elif [[ "$result" == https://* ]] || [[ "$result" == http://* ]]; then
        # https://host/Owner/repo → Owner/repo
        result="${result#*://}"
        result="${result#*/}"  # Remove host
    fi

    echo "$result"
}

# Extract hostname from a git remote URL
parse_remote_host() {
    local url="$1"

    if [[ "$url" == git@* ]]; then
        # git@host:path → host
        local hostpart="${url#git@}"
        echo "${hostpart%%:*}"
    elif [[ "$url" == https://* ]] || [[ "$url" == http://* ]]; then
        # https://host/path → host
        local stripped="${url#*://}"
        echo "${stripped%%/*}"
    fi
}

# Determine forge type from remote URL
detect_forge() {
    local host
    host=$(parse_remote_host "$1")

    if [[ "$host" == *"github.com"* ]]; then
        echo "github"
    else
        echo "gitea"
    fi
}

# Find tea login name for a given host
# tea login list columns: | NAME | URL | SSHHOST | USER | DEFAULT |
find_tea_login() {
    local target_host="$1"
    local result=""
    while IFS='|' read -r _ name url sshhost _; do
        name=$(echo "$name" | xargs)
        url=$(echo "$url" | xargs)
        sshhost=$(echo "$sshhost" | xargs)
        if [[ -z "$name" ]]; then
            continue
        fi
        # Match against both URL host and SSHHOST
        local url_host
        url_host=$(parse_remote_host "$url")
        if [[ "$url_host" == "$target_host" ]] || [[ "$sshhost" == "$target_host" ]]; then
            result="$name"
            break
        fi
    done < <(tea login list 2>/dev/null | grep -v '^+' | grep -v 'NAME')
    echo "$result"
}

# Get release notes from GitHub origin
get_origin_release_notes() {
    local repo_path="$1"
    local tag="$2"

    pushd "$repo_path" > /dev/null
    local origin_url
    origin_url=$(git remote get-url origin 2>/dev/null)
    local origin_repo
    origin_repo=$(parse_remote_url "$origin_url")
    popd > /dev/null

    # Try to get release body from GitHub
    gh release view "$tag" --repo "$origin_repo" --json body -q '.body' 2>/dev/null || echo ""
}

# Create release on GitHub remote
create_github_release() {
    local repo_slug="$1"
    local tag="$2"
    local title="$3"
    local notes="$4"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would create GitHub release $tag on $repo_slug"
        return 0
    fi

    # Check if release already exists
    if gh release view "$tag" --repo "$repo_slug" &>/dev/null; then
        warn "Release $tag already exists on $repo_slug — skipping"
        return 0
    fi

    if [[ -n "$notes" ]]; then
        gh release create "$tag" --repo "$repo_slug" --title "$title" --notes "$notes"
    else
        gh release create "$tag" --repo "$repo_slug" --title "$title" --notes "Release $tag"
    fi
}

# Create release on Gitea remote
create_gitea_release() {
    local login="$1"
    local repo_slug="$2"
    local tag="$3"
    local title="$4"
    local notes="$5"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would create Gitea release $tag on $repo_slug (login: $login)"
        return 0
    fi

    # Check if release already exists
    if tea release list --login "$login" --repo "$repo_slug" 2>/dev/null | grep -q "$tag"; then
        warn "Release $tag already exists on $repo_slug (Gitea) — skipping"
        return 0
    fi

    if [[ -n "$notes" ]]; then
        tea release create --login "$login" --repo "$repo_slug" --tag "$tag" --title "$title" --note "$notes"
    else
        tea release create --login "$login" --repo "$repo_slug" --tag "$tag" --title "$title" --note "Release $tag"
    fi
}

# ── Core Logic ────────────────────────────────────────────────────────────────

# Sync a single repository to all its non-origin remotes
sync_repo() {
    local repo_path="$1"
    local repo_name
    repo_name=$(basename "$repo_path")

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    info "Syncing: $repo_name ($repo_path)"
    echo "═══════════════════════════════════════════════════════════════"

    pushd "$repo_path" > /dev/null

    # Verify it's a git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        err "$repo_path is not a git repository"
        popd > /dev/null
        return 1
    fi

    # Verify origin is CorentinLumineau
    local origin_url
    origin_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -z "$origin_url" ]]; then
        err "No origin remote found"
        popd > /dev/null
        return 1
    fi

    if [[ "$origin_url" != *"$ORIGIN_OWNER"* ]]; then
        warn "Origin is not $ORIGIN_OWNER — skipping ($origin_url)"
        popd > /dev/null
        return 0
    fi

    # Determine tag to sync
    local sync_tag="$TAG"
    if [[ -z "$sync_tag" ]]; then
        sync_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -z "$sync_tag" ]]; then
            warn "No tags found in $repo_name — skipping"
            popd > /dev/null
            return 0
        fi
    fi
    info "Tag to sync: $sync_tag"

    # Collect non-origin remotes
    local remotes=()
    while IFS= read -r line; do
        local remote_name
        remote_name=$(echo "$line" | awk '{print $1}')
        if [[ "$remote_name" != "origin" ]]; then
            remotes+=("$remote_name")
        fi
    done < <(git remote -v | grep "(push)" | sort -u)

    if [[ ${#remotes[@]} -eq 0 ]]; then
        warn "No non-origin remotes found — skipping"
        popd > /dev/null
        return 0
    fi

    info "Non-origin remotes: ${remotes[*]}"

    # Get release notes from origin
    local notes=""
    if [[ "$TAGS_ONLY" != true ]]; then
        notes=$(get_origin_release_notes "$repo_path" "$sync_tag")
        if [[ -n "$notes" ]]; then
            ok "Fetched release notes from origin ($sync_tag)"
        else
            warn "No release notes found on origin for $sync_tag"
        fi
    fi

    # Process each remote
    for remote in "${remotes[@]}"; do
        echo ""
        info "Processing remote: $remote"

        local remote_url
        remote_url=$(git remote get-url "$remote" 2>/dev/null)
        local forge
        forge=$(detect_forge "$remote_url")
        local repo_slug
        repo_slug=$(parse_remote_url "$remote_url")
        local host
        host=$(parse_remote_host "$remote_url")

        info "  Forge: $forge | Repo: $repo_slug | Host: $host"

        # Step 1: Push branch commits
        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
        if [[ "$DRY_RUN" == true ]]; then
            info "  [DRY-RUN] Would push $current_branch to $remote"
        else
            info "  Pushing $current_branch to $remote..."
            if git push "$remote" "$current_branch" 2>&1; then
                ok "  Branch $current_branch pushed to $remote"
            else
                err "  Failed to push $current_branch to $remote"
                continue
            fi
        fi

        # Step 2: Push tags
        if [[ "$DRY_RUN" == true ]]; then
            info "  [DRY-RUN] Would push tags to $remote"
        else
            info "  Pushing tags to $remote..."
            if git push "$remote" --tags 2>&1; then
                ok "  Tags pushed to $remote"
            else
                err "  Failed to push tags to $remote"
                continue
            fi
        fi

        # Step 3: Create release (unless --tags-only)
        if [[ "$TAGS_ONLY" == true ]]; then
            info "  Skipping release creation (--tags-only)"
            continue
        fi

        info "  Creating release $sync_tag on $remote ($forge)..."

        if [[ "$forge" == "github" ]]; then
            if create_github_release "$repo_slug" "$sync_tag" "$sync_tag" "$notes"; then
                ok "  Release $sync_tag created on $remote (GitHub)"
            else
                err "  Failed to create release on $remote"
            fi
        elif [[ "$forge" == "gitea" ]]; then
            local tea_login
            tea_login=$(find_tea_login "$host")
            if [[ -z "$tea_login" ]]; then
                err "  No tea login found for host $host — run: tea login add"
                continue
            fi
            info "  Using tea login: $tea_login"
            if create_gitea_release "$tea_login" "$repo_slug" "$sync_tag" "$sync_tag" "$notes"; then
                ok "  Release $sync_tag created on $remote (Gitea)"
            else
                err "  Failed to create release on $remote"
            fi
        fi
    done

    popd > /dev/null
    ok "$repo_name sync complete"
}

# ── Repo Discovery ────────────────────────────────────────────────────────────

discover_repos() {
    local base_dir
    base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)

    # Current repo (ccsetup)
    if [[ -d "$base_dir/.git" ]]; then
        KNOWN_REPOS+=("$base_dir")
    fi

    # Known sibling repos
    local parent_dir
    parent_dir=$(dirname "$base_dir")
    for sibling in x-workflows x-devsecops; do
        if [[ -d "$parent_dir/$sibling/.git" ]]; then
            KNOWN_REPOS+=("$parent_dir/$sibling")
        fi
    done
}

# ── Argument Parsing ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --tags-only)
            TAGS_ONLY=true
            shift
            ;;
        --help)
            head -20 "$0" | grep "^#" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            KNOWN_REPOS+=("$1")
            shift
            ;;
    esac
done

# ── Main ──────────────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════════"
echo "  Sync Remotes — Push tags & releases from origin to mirrors"
echo "═══════════════════════════════════════════════════════════════"

if [[ "$DRY_RUN" == true ]]; then
    warn "DRY-RUN mode — no changes will be made"
fi

# Discover repos if none provided
if [[ ${#KNOWN_REPOS[@]} -eq 0 ]]; then
    discover_repos
fi

if [[ ${#KNOWN_REPOS[@]} -eq 0 ]]; then
    err "No repositories found to sync"
    exit 1
fi

info "Repos to sync: ${KNOWN_REPOS[*]}"

SYNC_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

for repo in "${KNOWN_REPOS[@]}"; do
    if sync_repo "$repo"; then
        SYNC_COUNT=$((SYNC_COUNT + 1))
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
ok "Sync complete: $SYNC_COUNT repos processed, $FAIL_COUNT failures"
echo "═══════════════════════════════════════════════════════════════"
