# koestler apt repository

Signed apt repository hosted on GitHub Pages: https://koestler.github.io/apt

## Install

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://koestler.github.io/apt/key.gpg | sudo tee /etc/apt/keyrings/koestler.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/koestler.gpg] https://koestler.github.io/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/koestler.list
sudo apt update
```

## How it works

The `publish` workflow reads `packages.yml`, downloads the `.deb` assets of the latest releases,
builds the repository with reprepro, signs it and deploys it to Pages. It runs on
`repository_dispatch` (`package-released`), nightly, on manual dispatch and on config changes.

## Add a new project

1. Add an entry to `packages.yml`.
2. Add secret `APT_DISPATCH_TOKEN` (fine-grained PAT, *Contents: read & write* on `koestler/apt`) to the project repo.
3. Add a final step to its release job:

```yaml
- name: Notify apt repository
  continue-on-error: true
  env:
    GH_TOKEN: ${{ secrets.APT_DISPATCH_TOKEN }}
  run: |
    gh api repos/koestler/apt/dispatches \
      -f event_type=package-released \
      -f 'client_payload[repo]=${{ github.repository }}' \
      -f 'client_payload[tag]=${{ github.ref_name }}'
```

## Required configuration

Secret `APT_GPG_PRIVATE_KEY` (key without passphrase); variable `APT_GPG_KEY_ID`; Pages source set to *GitHub Actions*.
