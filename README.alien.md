# CRM Alien Creativo

Release-based fork of Chatwoot for Alien Creativo. The base is upstream
`v4.19.1`; our release images will use Community Edition without `enterprise/`
or `spec/enterprise/`. Upstream source and licensing notices remain intact.

## Working on a change

Use the checkout in the WSL Linux filesystem, not a mounted Windows drive.
Keep each task on its own branch and isolated working tree.

1. Branch from `main` into `feature/<name>` (or `hotfix/<name>`).
2. Put backend extensions in `custom/` and record every edited upstream path
   in `PATCHES.md`. Keep frontend changes small.
3. Open a PR to `main` and pass the required checks.
4. Validate the built image in staging before tagging a production release.

`main` is the staging integration branch. Feature changes enter through PRs.
Only upstream release tags are followed; do not merge upstream `develop`.

## Upstream updates

```bash
git fetch upstream --tags
git switch main
git pull --ff-only origin main
git switch -c update/vX.Y.Z
git merge vX.Y.Z
```

Resolve conflicts using `PATCHES.md`, remove reintroduced upstream workflows,
retain our own CI, and update `UPSTREAM_VERSION`. Open a PR to `main`, pass CI
and validate migrations and behavior in staging before releasing.

## Images and environments

| Source | Image tags | Destination |
|---|---|---|
| `main` | `main-<sha7>`, `staging` | Staging, started only for validation |
| `vX.Y.Z-alien.N` | `vX.Y.Z-alien.N` | Production, after explicit approval |

Image package: `ghcr.io/alien-creativo/crm-aliencreativo` (public).
First planned release: `v4.19.1-alien.1`. The counter resets for each upstream
release. Production always uses a fixed release tag.

CI, the development environment and extension features will be added in the
following implementation phases. This bootstrap does not deploy an image or
modify a running installation.

## Private operational data

Never commit `.env`, tokens, SSH keys, server addresses, backups, database dumps
or customer data. Use GitHub Secrets and deployment environment variables.
Keep coordination notes and backups outside this public repository. Use seeded
test data locally; sanitize any staging data before starting background jobs.

## Bootstrap verification

Check the upstream ancestry, ignore rules, changed-file list and absence of
upstream workflows before publishing. Runtime checks are not applicable to
this documentation and repository-configuration change. Reverting the
bootstrap commit removes these fork-specific files and restores the upstream
repository configuration without changing application code.
