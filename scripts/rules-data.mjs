/**
 * Central Skylint Rules Registry
 * Single Source of Truth for:
 * - Rule IDs (kebab-case, e.g. 'prefer-lines')
 * - ABAP Class Names (e.g. 'ZCL_SKYLINT_PREF_LINES')
 * - Pseudo-Comments (#EC ...)
 * - Categories
 */

export const CATEGORIES = {
  'clean-abap': {
    title: 'Clean ABAP & Modern Syntax',
    description: 'Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.',
  },
  'anti-patterns': {
    title: 'Anti-Patterns & Bad Practices',
    description: 'Discouraged language constructs, legacy statements, and redundant syntax.',
  },
  'performance': {
    title: 'Performance & Database',
    description: 'Database query efficiency, buffer protection, and internal table operation guidelines.',
  },
  'security': {
    title: 'Security & Robustness',
    description: 'Authorizations, dynamic execution sanitation, error handling, and runtime safety.',
  },
  'metrics': {
    title: 'Metrics & Complexity Limits',
    description: 'Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.',
  },
};

export const RULES = [
  { ruleId: 'prefer-lines', className: 'ZCL_SKYLINT_PREF_LINES', pseudoComment: 'LINES', category: 'clean-abap' },
  { ruleId: 'no-call-method', className: 'ZCL_SKYLINT_NO_CALL_METHOD', pseudoComment: 'CALL_METH', category: 'anti-patterns' },
  { ruleId: 'no-default-key', className: 'ZCL_SKYLINT_NO_DEFAULT_KEY', pseudoComment: 'DEFAULT_KEY', category: 'anti-patterns' },
  { ruleId: 'prefer-is-not', className: 'ZCL_SKYLINT_PREF_IS_NOT', pseudoComment: 'IS_NOT', category: 'clean-abap' },
  { ruleId: 'no-me-reference', className: 'ZCL_SKYLINT_NO_ME_REFERENCE', pseudoComment: 'ME', category: 'anti-patterns' },
  { ruleId: 'no-exporting', className: 'ZCL_SKYLINT_NO_EXPORTING', pseudoComment: 'EXPORTING', category: 'anti-patterns' },
  { ruleId: 'no-chained-assignment', className: 'ZCL_SKYLINT_NO_CHAIN_ASSIGN', pseudoComment: 'CHAIN_ASSIGN', category: 'anti-patterns' },
  { ruleId: 'no-chained-decl', className: 'ZCL_SKYLINT_NO_CHAIN_DECL', pseudoComment: 'CHAIN_DECL', category: 'anti-patterns' },
  { ruleId: 'prefer-string-template', className: 'ZCL_SKYLINT_PREF_STR_TMPL', pseudoComment: 'STR_TMPL', category: 'clean-abap' },
  { ruleId: 'no-boolean-comparison', className: 'ZCL_SKYLINT_NO_BOOL_COMPARE', pseudoComment: 'BOOL_COMPARE', category: 'anti-patterns' },
  { ruleId: 'prefer-line-exists', className: 'ZCL_SKYLINT_PREF_LINE_EXISTS', pseudoComment: 'LINE_EXISTS', category: 'clean-abap' },
  { ruleId: 'prefer-return', className: 'ZCL_SKYLINT_PREF_RETURN', pseudoComment: 'RETURN', category: 'clean-abap' },
  { ruleId: 'no-check-in-loop', className: 'ZCL_SKYLINT_NO_CHECK_IN_LOOP', pseudoComment: 'CHECK_IN_LOOP', category: 'anti-patterns' },
  { ruleId: 'no-empty-block', className: 'ZCL_SKYLINT_NO_EMPTY_BLOCK', pseudoComment: 'EMPTY_BLOCK', category: 'anti-patterns' },
  { ruleId: 'no-empty-catch', className: 'ZCL_SKYLINT_NO_EMPTY_CATCH', pseudoComment: 'NO_HANDLER', category: 'anti-patterns' },
  { ruleId: 'no-duplicate-conditions', className: 'ZCL_SKYLINT_NO_DUP_COND', pseudoComment: 'DUP_COND', category: 'anti-patterns' },
  { ruleId: 'merge-nested-ifs', className: 'ZCL_SKYLINT_PREF_MERGE_IFS', pseudoComment: 'MERGE_IFS', category: 'clean-abap' },
  { ruleId: 'no-unreachable-code', className: 'ZCL_SKYLINT_NO_UNREACHABLE', pseudoComment: 'UNREACHABLE', category: 'anti-patterns' },
  { ruleId: 'no-single-when', className: 'ZCL_SKYLINT_NO_SINGLE_WHEN', pseudoComment: 'SINGLE_WHEN', category: 'anti-patterns' },
  { ruleId: 'no-yoda-conditions', className: 'ZCL_SKYLINT_NO_YODA_COND', pseudoComment: 'YODA_COND', category: 'anti-patterns' },
  { ruleId: 'prefer-symbol-operators', className: 'ZCL_SKYLINT_PREF_SYMBOL_OP', pseudoComment: 'SYMBOL_OP', category: 'clean-abap' },
  { ruleId: 'prefer-new-operator', className: 'ZCL_SKYLINT_PREF_NEW_OP', pseudoComment: 'NEW_OP', category: 'clean-abap' },
  { ruleId: 'prefer-raise-new', className: 'ZCL_SKYLINT_PREF_RAISE_NEW', pseudoComment: 'RAISE_NEW', category: 'clean-abap' },
  { ruleId: 'prefer-xsdbool', className: 'ZCL_SKYLINT_PREF_XSDBOOL', pseudoComment: 'XSDBOOL', category: 'clean-abap' },
  { ruleId: 'no-receiving', className: 'ZCL_SKYLINT_NO_RECEIVING', pseudoComment: 'RECEIVING', category: 'anti-patterns' },
  { ruleId: 'no-static-via-instance', className: 'ZCL_SKYLINT_NO_STATIC_ARROW', pseudoComment: 'STATIC_ARROW', category: 'anti-patterns' },
  { ruleId: 'no-public-attributes', className: 'ZCL_SKYLINT_NO_PUBLIC_ATTR', pseudoComment: 'PUBLIC_ATTR', category: 'anti-patterns' },
  { ruleId: 'no-obsolete-statements', className: 'ZCL_SKYLINT_NO_OBSOLETE', pseudoComment: 'OBSOLETE', category: 'anti-patterns' },
  { ruleId: 'max-params', className: 'ZCL_SKYLINT_MAX_PARAMS', pseudoComment: 'MAX_PARAMS', category: 'metrics' },
  { ruleId: 'no-db-in-loop', className: 'ZCL_SKYLINT_NO_DB_IN_LOOP', pseudoComment: 'DB_IN_LOOP', category: 'performance' },
  { ruleId: 'no-empty-fae', className: 'ZCL_SKYLINT_NO_EMPTY_FAE', pseudoComment: 'EMPTY_FAE', category: 'performance' },
  { ruleId: 'no-select-star', className: 'ZCL_SKYLINT_NO_SELECT_STAR', pseudoComment: 'SELECT_STAR', category: 'performance' },
  { ruleId: 'no-scope-leak', className: 'ZCL_SKYLINT_NO_SCOPE_LEAK', pseudoComment: 'SCOPE_LEAK', category: 'anti-patterns' },
  { ruleId: 'no-self-assignment', className: 'ZCL_SKYLINT_NO_SELF_ASSIGN', pseudoComment: 'SELF_ASSIGN', category: 'anti-patterns' },
  { ruleId: 'require-fully-typed', className: 'ZCL_SKYLINT_PREF_FULL_TYPED', pseudoComment: 'FULL_TYPED', category: 'clean-abap' },
  { ruleId: 'no-single-param-name', className: 'ZCL_SKYLINT_NO_PARAM_NAME', pseudoComment: 'PARAM_NAME', category: 'anti-patterns' },
  { ruleId: 'no-try-without-catch', className: 'ZCL_SKYLINT_NO_TRY_NO_CATCH', pseudoComment: 'TRY_NO_CATCH', category: 'anti-patterns' },
  { ruleId: 'prefer-corresponding', className: 'ZCL_SKYLINT_PREF_CORRESP', pseudoComment: 'CORRESP', category: 'clean-abap' },
  { ruleId: 'max-method-length', className: 'ZCL_SKYLINT_MAX_METHOD_LEN', pseudoComment: 'METHOD_LEN', category: 'metrics' },
  { ruleId: 'max-nesting-depth', className: 'ZCL_SKYLINT_MAX_NESTING', pseudoComment: 'NESTING', category: 'metrics' },
  { ruleId: 'no-sy-modify', className: 'ZCL_SKYLINT_NO_SY_MODIFY', pseudoComment: 'SY_MODIFY', category: 'anti-patterns' },
  { ruleId: 'prefer-returning', className: 'ZCL_SKYLINT_PREF_RETURNING', pseudoComment: 'RETURNING', category: 'clean-abap' },
  { ruleId: 'prefer-class-exceptions', className: 'ZCL_SKYLINT_PREF_CLASS_EXC', pseudoComment: 'CLASS_EXC', category: 'clean-abap' },
  { ruleId: 'no-dangerous-dynamic', className: 'ZCL_SKYLINT_NO_DYNAMIC_STMT', pseudoComment: 'DYNAMIC_STMT', category: 'security' },
  { ruleId: 'require-auth-check', className: 'ZCL_SKYLINT_PREF_AUTH_CHECK', pseudoComment: 'AUTH_CHECK', category: 'security' },
  { ruleId: 'require-order-by', className: 'ZCL_SKYLINT_PREF_ORDER_BY', pseudoComment: 'ORDER_BY', category: 'performance' },
  { ruleId: 'max-cyclomatic-complexity', className: 'ZCL_SKYLINT_MAX_CYCLO_COMP', pseudoComment: 'CYCLO_COMP', category: 'metrics' },
  { ruleId: 'prefer-final-class', className: 'ZCL_SKYLINT_PREF_FINAL_CLS', pseudoComment: 'FINAL_CLS', category: 'clean-abap' },
  { ruleId: 'no-raise-shortdump', className: 'ZCL_SKYLINT_NO_SHORTDUMP', pseudoComment: 'SHORTDUMP', category: 'anti-patterns' },
  { ruleId: 'no-magic-numbers', className: 'ZCL_SKYLINT_NO_MAGIC_NUMBERS', pseudoComment: 'MAGIC_NUMBERS', category: 'anti-patterns' },
  { ruleId: 'prefer-insert-into', className: 'ZCL_SKYLINT_PREF_INSERT', pseudoComment: 'INSERT_INTO', category: 'clean-abap' },
  { ruleId: 'no-obsolete-loop-control', className: 'ZCL_SKYLINT_NO_OBS_LOOP_CTL', pseudoComment: 'OBS_LOOP_CTL', category: 'anti-patterns' },
  { ruleId: 'no-like-objects', className: 'ZCL_SKYLINT_NO_LIKE_OBJECTS', pseudoComment: 'LIKE_OBJECTS', category: 'anti-patterns' },
  { ruleId: 'clean-constructor', className: 'ZCL_SKYLINT_CLEAN_CTOR', pseudoComment: 'CLEAN_CTOR', category: 'clean-abap' },
  { ruleId: 'no-static-classes', className: 'ZCL_SKYLINT_NO_STATIC_CLS', pseudoComment: 'STATIC_CLS', category: 'clean-abap' },
  { ruleId: 'prefer-predicate-names', className: 'ZCL_SKYLINT_PREF_PRED_NAME', pseudoComment: 'PRED_NAME', category: 'clean-abap' },
  { ruleId: 'max-inheritance-depth', className: 'ZCL_SKYLINT_MAX_INHERIT', pseudoComment: 'INHERIT_DEPTH', category: 'metrics' },
  { ruleId: 'max-attributes', className: 'ZCL_SKYLINT_MAX_ATTRIBUTES', pseudoComment: 'ATTRIBUTES', category: 'metrics' },
  { ruleId: 'no-interface-data', className: 'ZCL_SKYLINT_NO_INTF_DATA', pseudoComment: 'INTF_DATA', category: 'anti-patterns' },
  { ruleId: 'no-catch-cx-root', className: 'ZCL_SKYLINT_NO_CATCH_ROOT', pseudoComment: 'CATCH_ROOT', category: 'security' },
  { ruleId: 'no-message-raising', className: 'ZCL_SKYLINT_NO_MSG_RAISING', pseudoComment: 'MSG_RAISING', category: 'anti-patterns' },
  { ruleId: 'no-nested-try', className: 'ZCL_SKYLINT_NO_NESTED_TRY', pseudoComment: 'NESTED_TRY', category: 'clean-abap' },
  { ruleId: 'no-raise-cx-sy', className: 'ZCL_SKYLINT_NO_RAISE_CX_SY', pseudoComment: 'RAISE_CX_SY', category: 'security' },
  { ruleId: 'require-subrc-check', className: 'ZCL_SKYLINT_CHECK_SUBRC', pseudoComment: 'CHECK_SUBRC', category: 'security' },
  { ruleId: 'no-form-routines', className: 'ZCL_SKYLINT_NO_FORM', pseudoComment: 'NO_FORM', category: 'anti-patterns' },
  { ruleId: 'no-client-specified', className: 'ZCL_SKYLINT_NO_CLIENT_SPEC', pseudoComment: 'CLIENT_SPEC', category: 'security' },
  { ruleId: 'no-commit-work', className: 'ZCL_SKYLINT_NO_COMMIT_WORK', pseudoComment: 'COMMIT_WORK', category: 'security' },
  { ruleId: 'require-transporting', className: 'ZCL_SKYLINT_PREF_TRANSPORT', pseudoComment: 'TRANSPORTING', category: 'performance' },
  { ruleId: 'test-method-naming', className: 'ZCL_SKYLINT_PREF_TEST_NAME', pseudoComment: 'TEST_NAME', category: 'clean-abap' },
  { ruleId: 'no-raw-dynamic-sql', className: 'ZCL_SKYLINT_NO_RAW_DYN_SQL', pseudoComment: 'RAW_DYN_SQL', category: 'security' },
  { ruleId: 'prefer-final-method', className: 'ZCL_SKYLINT_PREF_FINAL_METH', pseudoComment: 'FINAL_METHOD', category: 'clean-abap' },
  { ruleId: 'prefer-string-functions', className: 'ZCL_SKYLINT_PREF_STR_FUNC', pseudoComment: 'STR_FUNC', category: 'clean-abap' },
  { ruleId: 'prefer-calc-assign-op', className: 'ZCL_SKYLINT_PREF_CALC_OP', pseudoComment: 'CALC_ASSIGN', category: 'clean-abap' },
  { ruleId: 'prefer-early-continue', className: 'ZCL_SKYLINT_PREF_EARLY_CONT', pseudoComment: 'EARLY_CONTINUE', category: 'clean-abap' },
  { ruleId: 'prefer-early-return', className: 'ZCL_SKYLINT_PREF_EARLY_RET', pseudoComment: 'EARLY_RETURN', category: 'clean-abap' },
  { ruleId: 'no-production-assert', className: 'ZCL_SKYLINT_NO_PROD_ASSERT', pseudoComment: 'PROD_ASSERT', category: 'security' },
  { ruleId: 'no-unused-variables', className: 'ZCL_SKYLINT_NO_UNUSED_VARS', pseudoComment: 'NEEDED', category: 'anti-patterns' },
  { ruleId: 'require-decl-order', className: 'ZCL_SKYLINT_PREF_DECL_ORDER', pseudoComment: 'DECL_ORDER', category: 'clean-abap' },
  { ruleId: 'no-param-escape', className: 'ZCL_SKYLINT_NO_PARAM_ESCAPE', pseudoComment: 'PARAM_ESCAPE', category: 'clean-abap' },
  { ruleId: 'no-forbidden-statements', className: 'ZCL_SKYLINT_NO_FORBIDDEN', pseudoComment: 'FORBIDDEN', category: 'security' },
  { ruleId: 'prefer-case', className: 'ZCL_SKYLINT_PREF_CASE', pseudoComment: 'PREF_CASE', category: 'clean-abap' },
  { ruleId: 'no-inline-length', className: 'ZCL_SKYLINT_NO_INLINE_LEN', pseudoComment: 'PAREN_LEN', category: 'anti-patterns' },
];

export const RULE_BY_RULE_ID = new Map(RULES.map(r => [r.ruleId, r]));
export const RULE_BY_CLASS = new Map(RULES.map(r => [r.className.toUpperCase(), r]));
export const RULE_BY_CLASS_LOWER = new Map(RULES.map(r => [r.className.toLowerCase(), r]));

/**
 * Resolve rule strictly by ruleId (kebab-case) or ABAP class name
 */
export function resolveRule(input) {
  if (!input) return null;
  const raw = String(input).trim();
  const kebab = raw.toLowerCase().replace(/_/g, '-');
  if (RULE_BY_RULE_ID.has(kebab)) return RULE_BY_RULE_ID.get(kebab);
  const upper = raw.toUpperCase();
  if (RULE_BY_CLASS.has(upper)) return RULE_BY_CLASS.get(upper);
  const lower = raw.toLowerCase();
  if (RULE_BY_CLASS_LOWER.has(lower)) return RULE_BY_CLASS_LOWER.get(lower);
  return null;
}
