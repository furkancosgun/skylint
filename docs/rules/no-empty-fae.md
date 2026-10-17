# Prevent Empty FOR ALL ENTRIES Inquiries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: FAENOCHECK" />
</div>

## 📖 Description

Unsecure FOR ALL ENTRIES (Missing empty itab check).

> **ATC Finding Message:** `FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan`

## 🧠 Rationale & Best Practices

In ABAP SQL, executing `FOR ALL ENTRIES IN @lt_table` when `lt_table` is empty drops the `WHERE` clause entirely and performs a full table scan, causing severe system performance degradation and data leaks.

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customers.
```

## ✅ Compliant Code

```abap
IF lt_orders IS NOT INITIAL.
  SELECT * FROM /dmo/customer
    FOR ALL ENTRIES IN @lt_orders
    WHERE customer_id = @lt_orders-customer_id
    INTO TABLE @lt_customers.
ENDIF.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-empty-fae:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EMPTY_FAE
" Or with SAP CI_ prefix:
... "#EC CI_EMPTY_FAE

" Using pragma:
... ##EMPTY_FAE.
" Or with SAP CI_ prefix:
... ##CI_EMPTY_FAE.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_FAE`
* **Finding Code:** `FAENOCHECK`
* **Implementation File:** [zcl_skylint_no_empty_fae.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_fae.clas.abap)
