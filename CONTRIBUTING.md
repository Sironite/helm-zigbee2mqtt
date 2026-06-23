# Contributing

## Issues and feature requests

Open an issue at https://github.com/Sironite/helm-zigbee2mqtt/issues.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Make your changes following the conventions below.
3. Open a pull request against `main`.

## Conventions

**Commits** — use [Conventional Commits](https://www.conventionalcommits.org):

| Prefix | When |
|--------|------|
| `feat:` | new value key or template feature |
| `fix:` | bug in templates or incorrect default |
| `docs:` | README or comment-only changes |
| `chore:` | dependency bumps, CI, tooling |

Versioning is automated via Release Please reading these prefixes.
`feat` → minor bump. `fix` / `chore` → patch bump.

**values.yaml** — every key must have a `# --` helm-docs comment above it.
README is generated automatically; do not edit it manually.

**Templates** — use `{{ include "zigbee2mqtt.<helper>" . }}` for all name/label helpers.

**Tests** — add or update `tests/units/*_test.yaml` for any new template or changed behaviour.
Run locally with:
```bash
helm plugin install https://github.com/helm-unittest/helm-unittest.git --version 0.7.1 --verify=false
helm unittest -f 'tests/units/*_test.yaml' .
```

**Lint** before opening a PR:
```bash
helm lint . -f values.yaml.example
```
