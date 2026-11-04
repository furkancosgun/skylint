---
title: "Avoid Method Call Chains Longer Than the Configured Limit"
description: "Limit chained ABAP method calls with the configurable MAX_CHAIN threshold - readable, debuggable object navigation instead of fluent one-liners."
keywords: "ABAP method chaining, no-method-chain, MAX_CHAIN, Clean ABAP readability, SAP ATC"
category: "clean-abap"
ruleId: "no-method-chain"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5024"
---

# Avoid Method Call Chains Longer Than the Configured Limit

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_METHOD_CHAIN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5024" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid excessive method chaining; extract into variables.

> **ATC Finding Message:** `Excessive method chaining; extract intermediate results into variables`

## Rationale

A chain such as lo_invoice->get_header( )->get_total_amount( ) hides two intermediate objects and one implicit dependency in a single line, so a dump in the second call cannot be reproduced without first inspecting what the first call returned, and the debugger cannot stop between the calls. Extracting each step into a well-named variable makes the data flow explicit for reviewers and lets you reuse or null-check the intermediate reference. The check counts the -> tokens of every method-call statement (string literals are excluded) and reports NO_CHAIN when the count exceeds MAX_CHAIN. A plain lo_service->run( ) counts as one link and therefore passes with the default value 1.

### Non-Compliant

```abap
DATA(lo_invoice) = NEW zcl_invoice( iv_order_id = lv_order_id ).
DATA(lv_total) = lo_invoice->get_header( )->get_total_amount( ).
```

### Compliant

```abap
DATA(lo_invoice) = NEW zcl_invoice( iv_order_id = lv_order_id ).
DATA(lo_header) = lo_invoice->get_header( ).
DATA(lv_total) = lo_header->get_total_amount( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_CHAIN` | `Integer` | <code>1</code> | Maximum number of -> links allowed in one method-call statement. Default 1 permits a single object->method( ) call; raise it to 2-3 only for intentional fluent APIs. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_METHOD_CHAIN

" SAP CI_ prefix format:
... "#EC CI_NO_METHOD_CHAIN
```

## How MAX_CHAIN is counted

Each `->` token of a method-call statement counts as one link. Static access with `=>` and text inside literals are ignored.

| Statement | Links |
| --- | --- |
| `lo_service->run( ).` | 1 |
| `lo_service->get_reader( )->read( ).` | 2 |
| `lo_service->get_reader( )->get_buffer( )->read( ).` | 3 |
| `cl_service=>create( )->run( ).` | 1 |

- `MAX_CHAIN` is an integer with default `1`: a single `object->method( )` call is fine, the first real chaining is reported.
- Raising `MAX_CHAIN` to `2` tolerates short fluent chains while still catching long builder sequences.
- Only statements recognised as method calls are inspected, so declarations and assignments without a call are never counted.

## Refactoring recipe

1. Name the intermediate object after its role (`lo_header`, `lo_position`), not after its type.
2. Keep the fluent builder chain at the place where the object is created (`NEW zcl_document( )->add_line( ... )->build( )`) only if it is a single expression assigned to one variable.
3. If the chain exists only to reach a nested attribute, ask the owning class for a dedicated getter instead of navigating the object graph.


## Related Rules

* [Replace Obsolete CALL METHOD Statements with Functional Invocations](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_METHOD_CHAIN`
* **ABAP Implementation:** [/skyl/cl_no_method_chain.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_method_chain.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5024)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5024)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_METHOD_CHAIN&title=%5BBug%5D%3A%20Issue%20in%20no-method-chain)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-method-chain)**
