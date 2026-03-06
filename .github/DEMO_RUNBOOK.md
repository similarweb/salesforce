# CI/CD Demo Runbook

Use this guide to verify the setup and demo the CI/CD pipeline.

## Pre-Demo Verification Checklist

### 1. GitHub Secrets (Settings → Secrets → Actions)
- [ ] `SFDX_AUTH_URL_PARTIAL` - Partial sandbox auth URL
- [ ] `SFDX_AUTH_URL_FULL` - Full sandbox auth URL  
- [ ] `SFDX_AUTH_URL_PRODUCTION` - Production auth URL

### 2. GitHub Environments (Settings → Environments)
- [ ] `partial` environment exists
- [ ] `full` environment exists
- [ ] `production` environment exists with required reviewers

### 3. Branches Exist
- [ ] `main` branch (production)
- [ ] `partial` branch (QA)
- [ ] `full` branch (UAT)

### 4. Workflows in All Branches
- [ ] `.github/workflows/` exists in `main`
- [ ] `.github/workflows/` exists in `partial`
- [ ] `.github/workflows/` exists in `full`

---

## Demo Script

### Demo 1: PR Validation (5 min)

**Story:** "When a developer opens a PR, we automatically validate the JIRA ticket and Salesforce metadata."

1. Create a feature branch:
   ```bash
   git checkout partial
   git checkout -b feature/MIS-1234
   ```

2. Make a small change to an Apex class (add a comment)

3. Commit and push:
   ```bash
   git add .
   git commit -m "MIS-1234: Demo PR validation"
   git push -u origin feature/MIS-1234
   ```

4. Create PR to `partial` on GitHub

5. **Show:**
   - PR template auto-populates with JIRA field
   - "Validate PR Title (JIRA Ticket)" check runs
   - "Apex Validation" check runs (validates metadata can deploy)

6. **Key Point:** "PRs without JIRA tickets are blocked"

---

### Demo 2: Deploy to QA (5 min)

**Story:** "When PR is merged to partial, it automatically deploys to QA sandbox."

1. Merge the PR from Demo 1

2. Go to Actions → "Deploy to Partial (QA)"

3. **Show:**
   - Workflow triggered automatically on merge
   - Delta deployment (only changed files)
   - JIRA tickets extracted from commits
   - Deployment summary

4. **Show in Salesforce:** Open Partial sandbox → Setup → Deployment Status

---

### Demo 3: Promote to UAT (3 min)

**Story:** "After QA approval, we promote to UAT by merging partial to full."

1. Create PR from `partial` → `full`

2. Merge the PR

3. **Show:** "Deploy to Full (UAT)" workflow runs

---

### Demo 4: Sprint Release to Production (7 min)

**Story:** "At sprint end, we create a release branch, cherry-pick approved stories, and deploy to production."

1. Create release branch:
   ```bash
   git checkout main
   git checkout -b release/sprint-99
   ```

2. Cherry-pick approved commits from full:
   ```bash
   git cherry-pick <commit-hash>
   ```

3. Push the release branch:
   ```bash
   git push -u origin release/sprint-99
   ```

4. **Show:**
   - "Release to Production" workflow triggers
   - Validation phase runs (dry-run with tests)
   - Manual approval gate (requires reviewer)
   - Quick deploy after approval
   - GitHub Release created with changelog
   - JIRA tickets listed in release notes

---

## Key Talking Points for Manager

### SOX Compliance
- Every PR requires JIRA ticket (audit trail)
- Production requires manual approval
- GitHub Releases document what deployed
- Branch protection prevents unauthorized changes

### Developer Experience
- Automatic deployments on merge
- Delta deployments (fast, only changed files)
- Clear feedback on PR validation
- No manual deployment steps

### Traceability
- Every deployment linked to JIRA tickets
- GitHub Release history shows all production deployments
- Can trace any production change back to ticket and PR

---

## Troubleshooting

### "No local changes to deploy"
- The delta found no Salesforce metadata changes
- Only `.github` files changed, which don't deploy to SF
- This is expected behavior - not an error

### "502 tests failing"
- Existing tests in sandbox are failing
- Not related to CI/CD - tests need fixing
- PR validation uses `NoTestRun` to avoid this

### "Maximum size of request reached"
- Full deployment is too large (>39MB)
- Solution: Using delta deployments (already implemented)

### Auth URL expired
Regenerate with:
```bash
sf org login web --alias <alias>
sf org display --target-org <alias> --verbose
```
Update the GitHub secret with new URL.

---

## Quick Test Commands

```bash
# Test PR validation - create a PR to partial
git checkout -b feature/MIS-TEST
echo "// test" >> force-app/main/default/classes/SomeClass.cls
git add . && git commit -m "MIS-TEST: Quick test"
git push -u origin feature/MIS-TEST
# Create PR on GitHub, then delete branch after

# Manually trigger deployment
# Go to Actions → Deploy to Partial (QA) → Run workflow
```
