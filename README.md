[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Find

This repository contains the beta-stage frontend component of data.gov.uk

# main-mvp Branch CI/CD Pipeline

##  Overview

This repository contains an automated CI/CD pipeline for the `main-mvp` branch that enables rapid development and deployment of MVP features to the Integration environment.

**What it does:**
- Runs automated security scans and tests on every PR
- Builds Docker images when code is merged
- Automatically updates deployment configurations
- Deploys to Integration environment via ArgoCD


### Branch Structure

```
datagovuk_find repository:
├── main            → Production deployments
└── main-mvp        → MVP/Integration deployments
```

### Pipeline Flow

```
Developer creates PR → main-mvp
         ↓
    CI Checks Run
    ├─ Security Analysis
    ├─ CodeQL SAST
    ├─ Dependency Review
    └─ Test Suite
         ↓
    PR Approved & Merged
         ↓
    Docker Image Built
    (ghcr.io/alphagov/datagovuk_find:main-mvp-<SHA>)
         ↓
    Charts Updated
    (charts/datagovuk/images/integration/find.yaml)
         ↓
    ArgoCD Detects Change
         ↓
    Deployed to Integration! 
```

### GitHub Actions Workflows

Located in `.github/workflows/`:

#### 1. `ci-mvp.yaml`
**Purpose:** Runs CI checks on every PR to main-mvp

**Triggers:**
- Pull requests to any branch
- Pushes to main-mvp

**Jobs:**
- **Security Analysis** - Brakeman security scanning
- **CodeQL SAST** - Semantic code analysis
- **Dependency Review** - Checks for vulnerable dependencies
- **Test Suite** - Full RSpec tests with Redis


#### 2. `build-image-mvp.yaml`
**Purpose:** Builds and pushes Docker image on merge

**Triggers:**
- Merges to main-mvp branch
- Manual workflow dispatch

**Process:**
- Builds Docker image
- Tags with commit SHA
- Pushes to `ghcr.io/alphagov/datagovuk_find:<SHA>`

#### 3. `update-charts-mvp.yaml`
**Purpose:** Updates deployment configuration automatically

**Triggers:**
- After `build-image-mvp.yaml` completes successfully

**Process:**
- Runs `update-find-sha-mvp.sh` script
- Updates image SHA in govuk-dgu-charts
- Pushes directly to main-mvp branch


### Scripts

Located in `docker/`:

#### `update-find-sha-mvp.sh`
**Purpose:** Updates Find application image SHA in deployment charts

**What it does:**
1. Clones `govuk-dgu-charts` repository
2. Checks out `main-mvp` branch
3. Updates `charts/datagovuk/images/integration/find.yaml`
4. Commits change with detailed message
5. Pushes directly to main-mvp branch
6. Cleans up temporary files

**Environment Variables Required:**
- `GH_TOKEN` - GitHub token with write access to govuk-dgu-charts
- `GH_REF` - Source branch reference (main-mvp)

**File Updated and this path is on the govuk-dgu-charts repo:**
```yaml
# charts/datagovuk/images/integration/find.yaml
repository: ghcr.io/alphagov/datagovuk_find
tag: <SHA>
branch: main-mvp
```
---

#### Creating a Feature

```bash
# 1. Create feature branch from main-mvp
git checkout main-mvp
git pull origin main-mvp
git checkout -b feature/jira-ticket-requirement

# 2. Make your changes
# ... code, commit, etc.

# 3. Push and create PR
git push origin feature/jira-ticket-requirement
```

#### Creating a Pull Request

1. Go to GitHub and create PR targeting `main-mvp`
2. CI checks will run automatically:
   -  Security Analysis
   -  CodeQL SAST scan
   -  Dependency Review
   -  Tests
3. All checks must pass before merging
4. Request review from national-data-library team
5. Once approved, merge the PR

## How to run this repo locally

There are currently 3 ways to run this repo locally:

1. Via  [govuk-dgu-charts](https://github.com/alphagov/govuk-dgu-charts) - An end to end setup from ckan to Solr to Find. This is the closest stack to the Find app running on EKS. Instructions for how to setup and run Find this way available on the linked repo.
2. Via [docker stack in ckanext-datagovuk](https://github.com/alphagov/ckanext-datagovuk) - This will be the fastest way to see your changes deployed and interact with a stack containing some seeded test data. It is also possible to run tests on it and debug issues within the containers.
3. Manual installation - this will give the fastest way to run the tests. Instructions for this below.

## Manual installation
### Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [yarn](https://yarnpkg.com/en/) to manage node packages

Most of these can be installed with Homebrew on a Mac.

### Getting Started

First run `bin/setup` to bundle, etc. Then run `rails s`.

## Deployment

See [the developer docs on data.gov.uk deployment](https://docs.publishing.service.gov.uk/manual/data-gov-uk-deployment.html)

## Example application URLs

- Find landing page: https://data.gov.uk
- Search results: https://data.gov.uk/search?filters%5Btopic%5D=Environment
- Dataset: https://data.gov.uk/dataset/ce5f9a81-742d-4446-8610-2ec138e1b7e5/st-john-s-lake-intertidal-biotope-map-tamar-estuary-plymouth
- Dataset with publisher login: https://data.gov.uk/dataset/cf725d50-6535-4f8b-bc98-5ab01aa866a7/grants-to-voluntary-community-and-social-enterprise-organisations-local-government-transparency-code
- Support page: https://data.gov.uk/support
- Publisher login page: https://data.gov.uk/publishers
