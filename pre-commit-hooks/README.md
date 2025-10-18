# latex-precommit-hooks

A pre-commit hook to sanitize `.tex` and `.bib` files by replacing non-ASCII characters
(e.g. en dash, non-breaking space, curly apostrophes, etc.) with plain ASCII equivalents.

### Usage

Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/SL2000s/pre-commit-latex-hooks
    rev: v1.0.0
    hooks:
      - id: replace-bad-chars
```

Then run:

```bash
pre-commit autoupdate
pre-commit install
```
