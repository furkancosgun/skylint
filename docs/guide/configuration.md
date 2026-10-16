# ⚙️ Configuration (`skylint.yaml`)

Skylint is configured using a `skylint.yaml` file in the root of your project or scanned folder.

## Example `skylint.yaml`

```yaml
# Hide findings below this severity: error | warning | note
minSeverity: warning

# Skip files using glob patterns
exclude:
  - "**/*.testclasses.abap"
  - "**/generated/**"

# Per-rule overrides by rule id
checks:
  prefer-lines:
    enabled: true
    severity: warning

  no-call-method:
    enabled: true
    severity: error

  max-method-length:
    enabled: false
```
