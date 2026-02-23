# Tool Detection Protocol

Complete reference for detecting CLI tool availability and managing fallback strategies.

---

## Detection Workflow

```
1. Initialize detection session
2. For each tool in priority list:
   a. Check session cache
   b. If cached and fresh (< 24h) → use cached result
   c. If stale or missing → run detection
3. Store results in tool_availability map
```

---

## CLI Version Checking

### Git Forge CLIs

```bash
# GitHub CLI
gh --version
# Output: gh version 2.40.1 (2024-01-15)
# Parse: Extract "2.40.1"

# Gitea CLI (tea)
tea --version
# Output: tea version 0.9.2
# Parse: Extract "0.9.2"

# GitLab CLI
glab --version
# Output: glab version 1.36.0 (2024-01-10)
# Parse: Extract "1.36.0"

# Git
git --version
# Output: git version 2.43.0
# Parse: Extract "2.43.0"
```

### Package Managers

```bash
# npm
npm --version
# Output: 10.2.4
# Parse: Use directly

# Yarn
yarn --version
# Output: 1.22.19
# Parse: Use directly

# pnpm
pnpm --version
# Output: 8.14.1
# Parse: Use directly

# Bun
bun --version
# Output: 1.0.25
# Parse: Use directly
```

### Runtimes

```bash
# Node.js
node --version
# Output: v20.11.0
# Parse: Strip "v" prefix → "20.11.0"

# Python 3
python3 --version
# Output: Python 3.12.1
# Parse: Extract "3.12.1"

# Python (check if it's Python 2 or 3)
python --version
# Output: Python 3.12.1 OR Python 2.7.18
# Parse: Extract version, warn if 2.x

# Ruby
ruby --version
# Output: ruby 3.3.0 (2023-12-25 revision ...)
# Parse: Extract "3.3.0"
```

### Build Tools

```bash
# Make
make --version
# Output: GNU Make 4.3
# Parse: Extract "4.3"

# CMake
cmake --version
# Output: cmake version 3.28.1
# Parse: Extract "3.28.1"

# Gradle
gradle --version
# Output: Gradle 8.5 (multi-line)
# Parse: Extract "8.5" from first line

# Maven
mvn --version
# Output: Apache Maven 3.9.6 (multi-line)
# Parse: Extract "3.9.6" from first line
```

### Container Tools

```bash
# Docker
docker --version
# Output: Docker version 25.0.3, build 4debf41
# Parse: Extract "25.0.3"

# Podman
podman --version
# Output: podman version 4.9.0
# Parse: Extract "4.9.0"

# Kubectl
kubectl version --client --short
# Output: Client Version: v1.29.1
# Parse: Strip "v" → "1.29.1"
```

### CI Tools

```bash
# Act (GitHub Actions local runner)
act --version
# Output: act version 0.2.56
# Parse: Extract "0.2.56"

# CircleCI CLI
circleci version
# Output: 0.1.30093+632e676
# Parse: Extract "0.1.30093"
```

---

## Tool Availability Matrix

### Version Control

| Tool | Priority | Category | Min Version | Fallback Chain |
|------|----------|----------|-------------|----------------|
| git | Critical | VCS | 2.30.0 | None (required) |
| gh | High | GitHub | 2.30.0 | glab, tea, git |
| glab | Medium | GitLab | 1.30.0 | gh, tea, git |
| tea | Medium | Gitea | 0.9.0 | gh, glab, git |

### Package Managers

| Tool | Priority | Category | Min Version | Fallback Chain |
|------|----------|----------|-------------|----------------|
| npm | High | Node.js PM | 8.0.0 | yarn, pnpm, bun |
| yarn | Medium | Node.js PM | 1.22.0 | npm, pnpm, bun |
| pnpm | Medium | Node.js PM | 8.0.0 | npm, yarn, bun |
| bun | Low | Node.js PM+Runtime | 1.0.0 | npm, yarn, pnpm |

### Runtimes

| Tool | Priority | Category | Min Version | Fallback Chain |
|------|----------|----------|-------------|----------------|
| node | High | JavaScript | 18.0.0 | bun |
| python3 | High | Python | 3.9.0 | python (if 3.x) |
| python | Medium | Python | 3.9.0 | python3 |
| ruby | Low | Ruby | 3.0.0 | None |

### Build Tools

| Tool | Priority | Category | Min Version | Fallback Chain |
|------|----------|----------|-------------|----------------|
| make | Medium | Build automation | 4.0 | npm scripts, manual |
| cmake | Low | C/C++ build | 3.20.0 | make |
| docker | Medium | Containers | 24.0.0 | podman |
| kubectl | Low | Kubernetes | 1.28.0 | None |

---

## Fallback Strategies

### Git Forge CLI Fallback

```
Scenario: GitHub operation needed, but gh not available

1. Check for glab:
   - If available → adapt to GitLab API (if compatible)
   - Log: "Using glab as fallback for GitHub operation"

2. If glab not available, check for tea:
   - If available → adapt to Gitea API (if compatible)
   - Log: "Using tea as fallback for GitHub operation"

3. If no forge CLI available, use git:
   - Degrade to basic git operations (no PR/issue support)
   - Log: "No forge CLI available, using basic git only"
   - Warn: "Cannot create PRs/issues without forge CLI"

4. If git also missing:
   - Critical failure: VCS is required
   - Halt workflow
   - Report: "Install git to proceed"
```

### Package Manager Fallback

```
Scenario: npm install needed, but npm not available

1. Check for yarn:
   - If available → use yarn install
   - Log: "Using yarn as fallback for npm"

2. If yarn not available, check for pnpm:
   - If available → use pnpm install
   - Log: "Using pnpm as fallback for npm"

3. If pnpm not available, check for bun:
   - If available → use bun install
   - Log: "Using bun as fallback for npm"

4. If no package manager available:
   - Halt workflow if install is required
   - Skip if install is optional
   - Report: "Install npm, yarn, pnpm, or bun to proceed"
```

### Runtime Fallback

```
Scenario: node command needed, but node not available

1. Check for bun:
   - If available → use bun run (compatible with Node.js)
   - Log: "Using bun runtime as fallback for node"

2. If bun not available:
   - Halt workflow if Node.js is required
   - Report: "Install Node.js or Bun to proceed"
```

### Container Tool Fallback

```
Scenario: docker command needed, but docker not available

1. Check for podman:
   - If available → use podman (drop-in replacement)
   - Log: "Using podman as fallback for docker"
   - Create alias: alias docker=podman

2. If podman not available:
   - Determine if container operations are optional
   - If optional → skip container steps, warn user
   - If required → halt workflow, report missing dependency
```

---

## Installation Guidance

### Platform-Specific Installation Commands

#### Git Forge CLIs

```bash
# GitHub CLI (gh)
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Fedora/RHEL
sudo dnf install gh

# Windows
winget install GitHub.cli

# GitLab CLI (glab)
# macOS
brew install glab

# Ubuntu/Debian
sudo apt install glab

# Fedora/RHEL
sudo dnf install glab

# Gitea CLI (tea)
# macOS
brew install tea

# Linux (binary download)
curl -fsSL https://dl.gitea.io/tea/main/tea-main-linux-amd64 -o tea
chmod +x tea
sudo mv tea /usr/local/bin/
```

#### Package Managers

```bash
# npm (via Node.js)
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs npm

# Fedora/RHEL
sudo dnf install nodejs npm

# Yarn
npm install -g yarn

# pnpm
npm install -g pnpm

# Bun
curl -fsSL https://bun.sh/install | bash
```

#### Runtimes

```bash
# Node.js
# macOS
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Python 3
# macOS
brew install python3

# Ubuntu/Debian
sudo apt install python3 python3-pip

# Ruby
# macOS
brew install ruby

# Ubuntu/Debian
sudo apt install ruby-full
```

#### Build Tools

```bash
# Make
# Ubuntu/Debian
sudo apt install build-essential

# macOS (via Xcode)
xcode-select --install

# Docker
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh

# macOS
brew install --cask docker

# Kubectl
# macOS
brew install kubectl

# Ubuntu/Debian
sudo apt install kubectl
```

---

## Version Compatibility

### Minimum Version Requirements

```yaml
critical_tools:
  git: "2.30.0"  # Modern branch handling, worktree support

high_priority:
  gh: "2.30.0"   # Stable PR/issue API
  glab: "1.30.0" # Stable GitLab API
  npm: "8.0.0"   # Modern package resolution
  node: "18.0.0" # LTS with modern JS features

medium_priority:
  yarn: "1.22.0"  # Classic stable
  pnpm: "8.0.0"   # Modern workspace support
  python3: "3.9.0" # Type hints, async improvements
  docker: "24.0.0" # Modern BuildKit support

low_priority:
  bun: "1.0.0"    # First stable release
  tea: "0.9.0"    # Mature feature set
  make: "4.0"     # Modern features
  kubectl: "1.28.0" # Recent K8s API support
```

### Version Parsing Patterns

```javascript
// Extract semantic version from version string
function parseVersion(versionOutput) {
  // Match: 1.2.3, v1.2.3, version 1.2.3
  const match = versionOutput.match(/v?(\d+\.\d+\.\d+)/);
  return match ? match[1] : null;
}

// Compare versions
function isVersionSufficient(current, minimum) {
  const [cMajor, cMinor, cPatch] = current.split('.').map(Number);
  const [mMajor, mMinor, mPatch] = minimum.split('.').map(Number);

  if (cMajor > mMajor) return true;
  if (cMajor < mMajor) return false;
  if (cMinor > mMinor) return true;
  if (cMinor < mMinor) return false;
  return cPatch >= mPatch;
}
```

---

## Caching Strategy

### Cache Schema

```json
{
  "tool_availability": {
    "gh": {
      "available": true,
      "path": "/usr/local/bin/gh",
      "version": "2.40.1",
      "version_sufficient": true,
      "minimum_required": "2.30.0",
      "checked_at": "2026-02-16T10:30:00Z",
      "ttl": 86400
    },
    "tea": {
      "available": false,
      "checked_at": "2026-02-16T10:30:00Z",
      "ttl": 86400
    }
  }
}
```

### Cache Invalidation Rules

```
Invalidate (re-check) when:
1. TTL expired (checked_at + 24h < now)
2. Package manager operation completed (npm install, etc.)
3. User explicitly requests tool detection
4. Tool reported as unavailable but workflow requires it
5. Version check fails minimum requirements

Preserve cache when:
1. Within TTL window (< 24h)
2. Version sufficient for requirements
3. No package operations since last check
```

---

## Error Handling

### Tool Not Found

```
Error: Tool 'gh' not found in PATH

1. Check fallback chain: glab → tea → git
2. If fallback found:
   - Log: "Tool 'gh' not found, using fallback 'glab'"
   - Adapt workflow to use fallback
   - Continue execution

3. If no fallback and tool is optional:
   - Log: "Tool 'gh' not found, skipping optional operations"
   - Warn user about degraded functionality
   - Continue execution

4. If no fallback and tool is critical:
   - Log: "Critical tool 'gh' not found"
   - Provide installation guidance
   - Halt workflow
```

### Version Insufficient

```
Error: Tool 'node' version 16.0.0 < minimum 18.0.0

1. Log: "Tool 'node' version insufficient (16.0.0 < 18.0.0)"
2. Check fallback (bun for node):
   - If fallback available and version sufficient → use fallback
   - If no fallback → halt workflow

3. Provide upgrade guidance:
   - "Upgrade Node.js to 18.0.0 or higher"
   - Platform-specific upgrade commands
   - Link to official docs

4. Halt workflow (cannot proceed with incompatible version)
```

### Tool Execution Failure

```
Error: Tool 'gh' execution failed (exit code 1)

1. Check if tool is actually available:
   - Re-run: which gh
   - Verify executable permissions

2. If tool exists but fails:
   - Log full error output
   - Check for authentication issues (gh auth status)
   - Check for network issues (if tool requires network)

3. Determine if failure is transient:
   - Network timeout → retry via error-recovery
   - Auth expired → prompt user to re-auth
   - Permanent error → report to user

4. If critical → halt workflow
   If optional → skip with warning
```

---

## Integration Example

```markdown
## Tool Detection Integration

Before executing git forge operations:

1. Check tool availability:
   ```
   const tools = await context_awareness.detectTools(['gh', 'glab', 'tea']);
   const forge_cli = tools.find(t => t.available);
   ```

2. If no forge CLI available:
   ```
   if (!forge_cli) {
     warn("No git forge CLI found. Install gh, glab, or tea for PR/issue support.");
     fallback_to_basic_git();
   }
   ```

3. If forge CLI found, use it:
   ```
   const pr_command = forge_cli.name === 'gh'
     ? 'gh pr create'
     : forge_cli.name === 'glab'
     ? 'glab mr create'
     : 'tea pr create';
   ```
```

---

## References

- @skills/permission-awareness/ - Permission mode detection
- @skills/error-recovery/ - Tool execution failure recovery
