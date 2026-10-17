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

## ⚡ Generate Default Template (`skylint init`)

To quickly bootstrap a fully commented `skylint.yaml` template pre-populated with all available rules and categories, simply run:

```bash
skylint init
```
Or specify a custom destination path:
```bash
skylint init ./config/skylint.yaml
```

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

  # 2. Metrics & Complexity Thresholds (supports camelCase and UPPER_CASE)
  max-method-length:
    enabled: true
    severity: warning
    attributes:
      maxStatements: 50           # Maximum statements allowed per method

  max-nesting-depth:
    enabled: true
    severity: error
    attributes:
      maxDepth: 3                 # Maximum nested control structures

  max-parameters:
    enabled: true
    severity: warning
    attributes:
      maxParameters: 5            # Max formal parameters per method

  # 3. Disabling a specific rule
  prefer-predicate-names:
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

---

## 🎛️ Configurable Rules & Default Thresholds Reference

The following **21 check rules** support customizable parameters in both `skylint.yaml` and the SAP ATC Check Variant (`CHKV`):

### 1. Numeric Thresholds & Metrics

| Rule ID | ABAP Class | Parameter Name | Data Type | Default Value | Description |
|---|---|---|:---:|:---:|---|
| [`clean-constructor`](/rules/clean-constructor) | `ZCL_SKYLINT_CLEAN_CTOR` | `MAX_STATEMENTS` | Integer | `10` | Max statements allowed in constructor |
| [`max-attributes`](/rules/max-attributes) | `ZCL_SKYLINT_MAX_ATTRIBUTES` | `MAX_ATTRIBUTES` | Integer | `5` | Max member attributes (God Class guard) |
| [`max-cyclomatic-complexity`](/rules/max-cyclomatic-complexity) | `ZCL_SKYLINT_MAX_CYCLO_COMP` | `MAX_COMPLEXITY` | Integer | `5` | Cyclomatic complexity branch limit |
| [`max-inheritance-depth`](/rules/max-inheritance-depth) | `ZCL_SKYLINT_MAX_INHERIT` | `MAX_DEPTH` | Integer | `1` | Max class inheritance hierarchy depth |
| [`max-method-length`](/rules/max-method-length) | `ZCL_SKYLINT_MAX_METHOD_LEN` | `MAX_STATEMENTS` | Integer | `5` | Max statements per procedure |
| [`max-nesting-depth`](/rules/max-nesting-depth) | `ZCL_SKYLINT_MAX_NESTING` | `MAX_DEPTH` | Integer | `3` | Max nested control structure depth |
| [`max-params`](/rules/max-params) | `ZCL_SKYLINT_MAX_PARAMS` | `MAX_PARAMETERS` | Integer | `8` | Max formal parameters per method |
| [`prefer-case`](/rules/prefer-case) | `ZCL_SKYLINT_PREF_CASE` | `MIN_BRANCHES` | Integer | `3` | Min branches required to prefer CASE over IF |

### 2. Boolean Feature Toggles

| Rule ID | ABAP Class | Parameter Name(s) | Default Value | Description |
|---|---|---|:---:|---|
| [`require-subrc-check`](/rules/require-subrc-check) | `ZCL_SKYLINT_CHECK_SUBRC` | `CHECK_SELECT_SINGLE`, `CHECK_READ_TABLE`, `CHECK_AUTHORITY_CHECK`, `CHECK_FIND_SEARCH`, `CHECK_ASSIGN` | `X` (`true`) | Enforce `sy-subrc` check for individual operation kinds |
| [`no-chained-statements`](/rules/no-chained-statements) | `ZCL_SKYLINT_NO_CHAINED_STMT` | `ALLOW_STRUCTURE_CHAINS`<br>`CHECK_CHAINED_DECL`<br>`CHECK_CHAINED_ASSIGN` | `X` (`true`)<br>`X` (`true`)<br>`X` (`true`) | Allow structure chains (`BEGIN OF`); disallow chained declarations and assignments |
| [`no-dangerous-statements`](/rules/no-dangerous-statements) | `ZCL_SKYLINT_NO_DANGEROUS_STMT` | `CHECK_EXEC_SQL`, `CHECK_KERNEL_CALL`, `CHECK_SYSTEM_CALL`, `CHECK_SYNTAX_CHECK`, `CHECK_DYNAMIC_SQL`, `CHECK_RAISE_SHORTDUMP`, `CHECK_PROD_ASSERT`, ... *(18 flags)* | `X` (`true`) | Enable or disable detection of specific critical statements |
| [`no-empty-block`](/rules/no-empty-block) | `ZCL_SKYLINT_NO_EMPTY_BLOCK` | `CHECK_IF`, `CHECK_LOOP`, `CHECK_CASE`, `CHECK_TRY`, `CHECK_CATCH`, `CHECK_TRY_NO_CATCH`, `CHECK_DO`, `CHECK_WHILE` | `X` (`true`) | Enable or disable checks for specific control block types |
| [`no-me-reference`](/rules/no-me-reference) | `ZCL_SKYLINT_NO_ME_REFERENCE` | `ALLOW_IN_CONSTRUCTORS` | `X` (`true`) | Allow `me->` self-reference inside constructor methods |
| [`no-obsolete-statements`](/rules/no-obsolete-statements) | `ZCL_SKYLINT_NO_OBSOLETE` | `CHECK_MOVE`, `CHECK_REFRESH`, `CHECK_COMPUTE`, `CHECK_TABLES`, `CHECK_FIELD_GROUPS`, `CHECK_TEST_SEAMS`, `CHECK_BREAK`, `CHECK_STATICS`, `CHECK_DEFINE`, `CHECK_EXPORT_MEMORY`, `CHECK_FORM`, `CHECK_LOOP_CTL` | `X` (`true`) | Enable or disable detection of individual obsolete statements |
| [`no-redundant-method-call`](/rules/no-redundant-method-call) | `ZCL_SKYLINT_NO_REDUNDANT_CALL` | `CHECK_EXPORTING`, `CHECK_RECEIVING`, `CHECK_PARAM_NAME` | `X` (`true`) | Omit redundant EXPORTING, RECEIVING, or single parameter names |
| [`no-select-star`](/rules/no-select-star) | `ZCL_SKYLINT_NO_SELECT_STAR` | `CHECK_SELECT_STAR`, `CHECK_ENDSELECT` | `X` (`true`) | Flag `SELECT *` and `SELECT ... ENDSELECT` loops |
| [`prefer-early-return`](/rules/prefer-early-return) | `ZCL_SKYLINT_PREF_EARLY_RET` | `CHECK_METHOD_RETURN`, `CHECK_LOOP_CONTINUE` | `X` (`true`) | Enforce early return in methods or early continue in loops |
| [`prefer-final-class`](/rules/prefer-final-class) | `ZCL_SKYLINT_PREF_FINAL_CLS` | `CHECK_CLASSES`, `CHECK_METHODS` | `X` (`true`) | Check for FINAL on classes and methods |
| [`prefer-new-operator`](/rules/prefer-new-operator) | `ZCL_SKYLINT_PREF_NEW_OP` | `CHECK_CREATE_OBJECT`, `CHECK_RAISE_EXCEPTION` | `X` (`true`) | Prefer NEW over CREATE OBJECT and RAISE EXCEPTION TYPE |
| [`prefer-string-functions`](/rules/prefer-string-functions) | `ZCL_SKYLINT_PREF_STR_FUNC` | `CHECK_CONDENSE`, `CHECK_TRANSLATE` | `X` (`true`) | Detect obsolete string statements (CONDENSE, TRANSLATE) |
| [`prefer-string-template`](/rules/prefer-string-template) | `ZCL_SKYLINT_PREF_STR_TMPL` | `ALLOW_IN_BYTE_MODE` | ` ` (`false`) | Allow string templates in byte mode operations |

