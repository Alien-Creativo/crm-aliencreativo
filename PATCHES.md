# Upstream changes

Base release: `v4.19.1`. Record each changed upstream path here before merging it.

| Upstream path | Reason | Date | Handling an upstream update |
|---|---|---|---|
| `.gitignore` | Exclude local credentials, backups, dumps and index data | 2026-11-03 | Keep these exclusions and merge new upstream rules |
| `.github/workflows/*` | Remove publishing and maintenance jobs intended for the upstream project | 2026-11-03 | Remove reintroduced upstream workflows; preserve our own CI |

Files added for this fork: `UPSTREAM_VERSION`, `PATCHES.md`, `README.alien.md`.
