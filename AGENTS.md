# Agent Guidelines

## What this repo is

Helm chart for deploying [Zigbee2MQTT](https://www.zigbee2mqtt.io) on Kubernetes.
Published publicly under the Sironite org. Chart is generic — usable by anyone, not homelab-specific.

## Repo layout

```
Chart.yaml          chart metadata and ArtifactHub annotations
values.yaml         generic defaults — full helm-docs (# --) comments on every key
values.yaml.example realistic example with all features enabled
docs/README.md.gotmpl  helm-docs template — README.md is generated, never edit manually
templates/          Kubernetes manifests
tests/units/        helm-unittest test suites (*_test.yaml)
.github/workflows/  CI: tests.yml (lint/security/unit), release-please.yml (release + publish)
```

## Development commands

```bash
# lint
helm lint . -f values.yaml.example

# unit tests
helm plugin install https://github.com/helm-unittest/helm-unittest.git --version 0.7.1 --verify=false
helm unittest -f 'tests/units/*_test.yaml' .

# render templates locally
helm template zigbee2mqtt . -f values.yaml.example

# regenerate README (requires Docker)
docker run --rm -v "$PWD:/helm-docs" -w /helm-docs jnorwood/helm-docs:v1.14.2 \
  --chart-search-root=. --template-files=docs/README.md.gotmpl --output-file=README.md
```

## Rules

- **Conventional commits** (`feat:` / `fix:` / `chore:` / `ci:` / `docs:`). Release Please reads these.
- **No Co-Authored-By or AI references** in commit messages.
- Every `values.yaml` key needs a `# --` helm-docs comment.
- `README.md` is generated — never edit it directly.
- `artifacthub-repo.yml` lives on the `gh-pages` branch, not `main`.
- `values.yaml.example` uses generic hostnames (`example.com`) and secret store refs (`my-secret-store`).
- ArtifactHub category annotation must be a valid slug — `integration-delivery`, not `monitoring`.

## CI / release pipeline

Tests run on every PR and push to `main` (lint → security → unit-tests).

Releases are fully automated:
1. Push conventional commits to `main`.
2. Release Please opens a release PR (bumps `Chart.yaml` version + `CHANGELOG.md`).
3. Merge the release PR → Release Please creates the GitHub Release.
4. The `release` job in `release-please.yml` chains directly (GITHUB_TOKEN cannot trigger separate workflows) and publishes to GitHub Pages + OCI (GHCR).

## Known constraints

- helm-unittest `hasDocuments` counts per-template-file scope, not per suite.
- gitleaks requires a paid license for GitHub orgs — do not add it.
- External secrets are mounted at `/app/data/{secretKey}` via subPath inside the PVC mount.
