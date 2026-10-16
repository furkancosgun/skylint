# ⚙️ Configuration Reference (`skylint.yaml`)

Skylint offers flexible configuration options at both the repository level (via `skylint.yaml`) and the SAP ATC level (via ATC Check Variant attributes).

---

## 📄 File Location & Hierarchy

When running Skylint CLI or CI/CD pipelines, Skylint searches for a configuration file in the following order:
1. File explicitly passed via `--config <path>`
2. `./skylint.yaml` in the current working directory
3. `./skylint.yml` in the current working directory
4. Built-in defaults (all rules enabled at their default severities)

---

## 🛠️ Complete `skylint.yaml` Example

```yaml
# ==============================================================================
# Skylint Static Analysis Configuration
# ==============================================================================

# Minimum finding severity reported to console and exit code
# Supported values: error | warning | note
minSeverity: warning

# File and folder exclusion patterns (standard glob syntax)
exclude:
  - "**/*.testclasses.abap"       # Ignore unit test doubles/includes
  - "**/generated/**"             # Ignore auto-generated proxies/CDS artifacts
  - "**/zcl_legacy_*.clas.abap"   # Exclude legacy modules during transition

# Rule-specific overrides keyed by semantic ruleId
checks:
  # 1. Clean ABAP & Modern Syntax
  prefer-lines:
    enabled: true
    severity: warning

  no-call-method:
    enabled: true
    severity: error

  prefer-string-template:
    enabled: true
    severity: warning

  # 2. Metrics & Complexity Thresholds
  max-method-length:
    enabled: true
    severity: warning
    attributes:
      MAX_STATEMENTS: 50          # Maximum statements allowed per method

  max-nesting-depth:
    enabled: true
    severity: error
    attributes:
      MAX_DEPTH: 3               # Maximum nested control structures

  max-parameters:
    enabled: true
    severity: warning
    attributes:
      MAX_PARAMS: 5              # Max formal parameters per method

  # 3. Disabling a specific rule
  avoid-me:
    enabled: false
```

---

## 📋 Configuration Options Reference

### Global Settings

| Property | Type | Default | Description |
|---|---|---|---|
| `minSeverity` | `string` | `note` | Minimum severity of findings to output (`error`, `warning`, `note`). Findings below this threshold are omitted. |
| `exclude` | `string[]` | `[]` | Array of glob patterns matching files or folders that should be completely skipped during analysis. |
| `checks` | `map` | `{}` | Key-value dictionary containing per-rule overrides. |

---

### Per-Rule Settings (`checks.<ruleId>`)

Each rule entry in `checks` uses the semantic kebab-case `ruleId` (e.g. `prefer-lines`, `no-db-in-loop`, `max-method-length`):

| Property | Type | Default | Description |
|---|---|---|---|
| `enabled` | `boolean` | `true` | Enables or disables the check rule completely. |
| `severity` | `string` | Rule default | Overrides the severity level (`error`, `warning`, or `note`). |
| `attributes` | `map` | `{}` | Check-specific parameter key-value pairs (e.g., numeric limits or boolean flags). |

---

## 🔄 Mapping to SAP ATC Check Variants

When running inside an SAP system, the configuration defined in `skylint.yaml` directly corresponds to settings available in the **Eclipse ADT ATC Check Variant Editor**:

| `skylint.yaml` Concept | SAP ATC Check Variant Concept |
|---|---|
| `checks.<ruleId>.enabled` | Checkbox next to the check class (`ZCL_SKYLINT_*`) |
| `checks.<ruleId>.severity` | Severity column in the ATC Check Variant Editor |
| `checks.<ruleId>.attributes` | Check Attributes pane in the Eclipse ADT Variant Editor |
| `exclude` | Object/Package selection filter in the ATC run configuration |
