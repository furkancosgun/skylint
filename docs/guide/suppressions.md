# 🤫 Suppressions & Pragmas

When non-compliant code is intentional, Skylint supports line-level suppressions.

## Using Pseudo-Comments

Append `"#EC <CODE>"` to the flagged statement:

```abap
DESCRIBE TABLE lt_data LINES lv_count. "#EC LINES
```

## Using Pragmas

Alternatively, modern ABAP pragmas `##<CODE>` are supported:

```abap
DESCRIBE TABLE lt_data LINES lv_count ##LINES.
```

Refer to individual rule documentation in the [Rules Catalog](/rules/) for each rule's specific suppression code.
