# CI/CD Setup Guide

This document provides instructions for setting up the GitHub Actions CI/CD pipeline for Salesforce deployments with SOX compliance.

## Table of Contents

- [Prerequisites](#prerequisites)
- [GitHub Secrets Setup](#github-secrets-setup)
- [GitHub Environments Setup](#github-environments-setup)
- [Branch Protection Rules](#branch-protection-rules)
- [JIRA Integration](#jira-integration)
- [Workflow Overview](#workflow-overview)

---

## Prerequisites

1. **Salesforce CLI** installed locally for generating auth URLs
2. **GitHub repository** with admin access
3. **Salesforce orgs** authenticated:
   - Partial (QA) Sandbox
   - Full (UAT) Sandbox
   - Production

---

## GitHub Secrets Setup

### Step 1: Generate SFDX Auth URLs

For each Salesforce org, run the following command locally:

```bash
# Authenticate with the org first (if not already)
sf org login web --alias partial-qa --instance-url https://test.salesforce.com

# Display the auth URL
sf org display --target-org partial-qa --verbose
```

Look for the line starting with `Sfdx Auth Url:` and copy the entire value.

### Step 2: Add Secrets to GitHub

Go to **Repository Settings → Secrets and variables → Actions → New repository secret**

Add the following secrets:

| Secret Name | Value |
|-------------|-------|
| `SFDX_AUTH_URL_PARTIAL` | Auth URL from Partial sandbox |
| `SFDX_AUTH_URL_FULL` | Auth URL from Full sandbox |
| `SFDX_AUTH_URL_PRODUCTION` | Auth URL from Production org |

> **Security Note:** Auth URLs contain sensitive credentials. Never commit them to the repository or share them in logs.

---

## GitHub Environments Setup

Create environments for deployment approval gates.

Go to **Repository Settings → Environments**

### Environment: `partial`

1. Click **New environment** → Name: `partial`
2. No protection rules required (auto-deploy on push)

### Environment: `full`

1. Click **New environment** → Name: `full`
2. Optional: Add required reviewers for UAT deployments

### Environment: `production`

1. Click **New environment** → Name: `production`
2. **Required reviewers:** Add at least 2 approvers (SOX requirement)
3. **Wait timer:** Optional, add delay before deployment (e.g., 5 minutes)
4. **Deployment branches:** Limit to `release/*` branches only

---

## Branch Protection Rules

For SOX compliance, configure branch protection rules.

Go to **Repository Settings → Branches → Add branch protection rule**

### Rule 1: `main` (Production)

| Setting | Value |
|---------|-------|
| Branch name pattern | `main` |
| Require a pull request before merging | ✅ |
| Required approvals | 2 |
| Dismiss stale reviews | ✅ |
| Require review from code owners | ✅ (optional) |
| Require status checks to pass | ✅ |
| Required status checks | `PR Validation`, `Code Quality Checks`, `Apex Validation` |
| Require branches to be up to date | ✅ |
| Do not allow bypassing | ✅ |
| Restrict who can push | ✅ (limit to admins) |
| Allow force pushes | ❌ |
| Allow deletions | ❌ |

### Rule 2: `full` (UAT)

| Setting | Value |
|---------|-------|
| Branch name pattern | `full` |
| Require a pull request before merging | ✅ |
| Required approvals | 1 |
| Require status checks to pass | ✅ |
| Required status checks | `PR Validation`, `Code Quality Checks` |
| Allow force pushes | ❌ |

### Rule 3: `partial` (QA)

| Setting | Value |
|---------|-------|
| Branch name pattern | `partial` |
| Require a pull request before merging | ✅ |
| Required approvals | 0 (optional) |
| Require status checks to pass | ✅ |
| Required status checks | `PR Validation` |
| Allow force pushes | ❌ |

### Rule 4: `release/*` (Sprint Releases)

| Setting | Value |
|---------|-------|
| Branch name pattern | `release/*` |
| Require a pull request before merging | ❌ (cherry-picks) |
| Allow force pushes | ❌ |
| Allow deletions | ❌ (keep for audit) |

---

## JIRA Integration

### Option 1: GitHub for JIRA App (Recommended)

1. Go to [GitHub Marketplace - Jira Software](https://github.com/marketplace/jira-software-github)
2. Install the app for your repository
3. Connect to your Atlassian account
4. Configure which repositories to sync

This automatically:
- Links commits mentioning JIRA tickets
- Shows PR status in JIRA tickets
- Creates deployment tracking in JIRA

### Option 2: Manual JIRA Links

The workflows extract JIRA tickets from commit messages and PR titles. Ensure all commits follow the pattern:

```
MIS-8567: Add new Account field
```

GitHub Releases will include links to JIRA tickets in the format:
```
https://similarweb.atlassian.net/browse/MIS-8567
```

---

## Workflow Overview

### PR Validation (`pr-validation.yml`)

**Triggers:** All pull requests to `main`, `partial`, `full`

**Checks:**
- PR title contains JIRA ticket (MIS-XXXX)
- Prettier formatting
- ESLint
- Apex validation (check-only deploy)

### Deploy to Partial (`deploy-partial.yml`)

**Triggers:** Push to `partial` branch, manual dispatch

**Actions:**
- Deploy to Partial (QA) sandbox
- Run local Apex tests
- Extract JIRA tickets for tracking

### Deploy to Full (`deploy-full.yml`)

**Triggers:** Push to `full` branch, manual dispatch

**Actions:**
- Deploy to Full (UAT) sandbox
- Run local Apex tests
- Extract JIRA tickets for tracking

### Release to Production (`release-production.yml`)

**Triggers:** Push to `release/sprint-*` branches, manual dispatch

**Actions:**
1. Extract JIRA tickets and components
2. Validate deployment (runs all tests)
3. Wait for manual approval (production environment)
4. Quick deploy using validation ID
5. Create GitHub Release with changelog
6. Merge release branch to main

---

## SOX Compliance Checklist

| Requirement | Implementation |
|-------------|----------------|
| Change tracking | JIRA tickets required in PR titles |
| Approval gates | Branch protection + environment approvals |
| Audit trail | GitHub Releases with ticket list |
| Separation of duties | Different approvers for UAT vs Production |
| Testing requirements | Apex tests run on every deployment |
| Deployment records | Workflow summaries + GitHub Releases |

---

## Troubleshooting

### Auth URL Expired

SFDX Auth URLs can expire. To regenerate:

```bash
sf org login web --alias org-alias --instance-url https://login.salesforce.com
sf org display --target-org org-alias --verbose
```

Update the corresponding GitHub secret.

### Validation Failed

Check the workflow logs for:
- Apex test failures
- Component conflicts
- Missing dependencies

### Quick Deploy Failed

Quick deploy must happen within 10 days of validation. If expired:
1. Re-run the workflow
2. Or manually trigger with `skip_validation: false`

---

## Support

For issues with this CI/CD setup:
1. Check workflow logs in GitHub Actions
2. Review Salesforce deployment status in Setup → Deployment Status
3. Contact the DevOps team
