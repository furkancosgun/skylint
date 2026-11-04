---
title: "Enforce Consistent Statement Indentation Based on Block Nesting Depth"
description: "Enforce uniform statement indentation per control block nesting depth in ABAP routines using automated ATC inspection."
keywords: "no-bad-indent, indentation, code formatting, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "no-bad-indent"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3577"
---

# Enforce Consistent Statement Indentation Based on Block Nesting Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_BAD_INDENT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3577" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Bad Statement Indentation.

> **ATC Finding Message:** `Statement indentation does not match block nesting`

## Rationale

Indentation provides the primary visual structure of program flow. Inconsistent or misaligned statement indentation misleads readers regarding control block hierarchy, conceals nesting bugs, and generates noisy Git diffs during formatting. Each nested control statement (such as IF, LOOP, DO, WHILE, TRY, or CASE) must be systematically indented by a uniform step from its parent block. Skylint calculates the expected column position for each statement according to its nesting level, reporting NO_BAD_IND with the FIXINDENT quickfix on misalignment.

### Non-Compliant

```abap
METHOD run.
  DATA lv_tax_amount TYPE i.
  IF lv_is_taxable = abap_true.
lv_tax_amount = 19.
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD run.
  DATA lv_tax_amount TYPE i.
  IF lv_is_taxable = abap_true.
    lv_tax_amount = 19.
  ENDIF.
ENDMETHOD.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `INDENT_STEP` | `Integer` | <code>2</code> | Number of spaces required per nested block indentation level, defaulting to 2 spaces. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BAD_INDENT

" SAP CI_ prefix format:
... "#EC CI_NO_BAD_INDENT
```

## Indentation Rules and Quickfix

The check tracks nesting depth starting at the procedure header (`METHOD`, `FORM`, `FUNCTION`) and verifies every statement:

- **Block openings (`IF`, `LOOP`, `TRY`, `CASE`, etc.):** Checked at current depth, then increments depth by 1.
- **Branching statements (`ELSE`, `ELSEIF`, `WHEN`, `CATCH`):** Aligned at `(depth - 1) * INDENT_STEP`.
- **Block closures (`ENDIF`, `ENDLOOP`, `ENDTRY`, `ENDCASE`):** Decrements depth and checks alignment with the matching opener.

When a statement is under-indented, the `FIXINDENT` quickfix recalculates and prepends the required leading spaces.

Suppress findings with pseudo comment `"#EC NO_BAD_INDENT`.


## Related Rules

* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit Source Code Line Length to Avoid Horizontal Scrolling](/rules/max-line-len) — <code>#EC MAX_LINE_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BAD_INDENT`
* **ABAP Implementation:** [/skyl/cl_no_bad_indent.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bad_indent.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3577)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3577)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BAD_INDENT&title=%5BBug%5D%3A%20Issue%20in%20no-bad-indent)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bad-indent)**
