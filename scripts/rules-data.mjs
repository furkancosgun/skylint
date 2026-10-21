/**
 * Central Skylint Rules Registry
 * Single Source of Truth for:
 * - Rule IDs (kebab-case, e.g. 'prefer-lines')
 * - ABAP Class Names (e.g. 'ZCL_SKYLINT_PREF_LINES')
 * - Pseudo-Comments (#EC ...)
 * - Categories
 * - Canonical Clean ABAP Examples (Bad / Good)
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
  {
    ruleId: 'downport-compat',
    title: 'Check Downport Compatibility (7.40+ Modern Constructs)',
    rationale: 'Flags modern 7.40+ ABAP constructs (constructor expressions, table expressions, inline declarations, string templates, and method chaining) when targeting legacy SAP NetWeaver downport releases (e.g. 7.00, 7.31). All checks default to disabled so modern workflows remain unaffected.',
    className: 'ZCL_SKYLINT_DOWNPORT_COMPAT',
    pseudoComment: 'DOWNPORT_COMPAT',
    category: 'cloud-readiness',
    example: {
      bad: `DATA(lv_val) = VALUE #( lt_data[ 1 ]-field OPTIONAL ).`,
      good: `DATA lv_val TYPE string.\nREAD TABLE lt_data INTO ls_data INDEX 1.\nIF sy-subrc = 0.\n  lv_val = ls_data-field.\nENDIF.`,
    },
  },
  {
    ruleId: 'prefer-reduce',
    title: 'Prefer REDUCE #( ) Expression over Simple Aggregation LOOP',
    rationale: 'Simple loops that only accumulate a sum or concatenate strings into a single target variable can be expressed much more concisely and declaratively with modern ABAP REDUCE #( ) constructor expressions.',
    className: 'ZCL_SKYLINT_PREF_REDUCE',
    pseudoComment: 'PREF_REDUCE',
    category: 'clean-abap',
    example: {
      bad: `LOOP AT lt_items INTO ls_item.\n  lv_sum = lv_sum + ls_item-amount.\nENDLOOP.`,
      good: `lv_sum = REDUCE #( \n  INIT res = lv_sum\n  FOR ls_item IN lt_items\n  NEXT res = res + ls_item-amount ).`,
    },
  },
  {
    ruleId: 'prefer-tab-expr',
    title: 'Prefer Table Expression itab[ ... ] over READ TABLE',
    rationale: 'Table expressions provide a direct, functional syntax for accessing internal table rows by key or index, eliminating procedural `READ TABLE` boilerplate and integrating seamlessly into expressions.',
    className: 'ZCL_SKYLINT_PREF_TAB_EXPR',
    pseudoComment: 'PREF_TAB_EXPR',
    category: 'clean-abap',
    example: {
      bad: `READ TABLE lt_items INTO ls_item WITH KEY id = lv_id.\nREAD TABLE lt_items ASSIGNING <fs_item> INDEX 1.`,
      good: `ls_item = VALUE #( lt_items[ id = lv_id ] OPTIONAL ).\nASSIGN lt_items[ 1 ] TO <fs_item>.`,
    },
  },
  {
    ruleId: 'prefer-cond',
    title: 'Prefer COND #( ) Expression over IF/ELSEIF/ELSE',
    rationale: 'IF/ELSEIF/ELSE statements that merely assign values to a single variable based on conditional checks can be written much more concisely and expressively using modern ABAP COND #( ) constructor expressions.',
    className: 'ZCL_SKYLINT_PREF_COND',
    pseudoComment: 'PREF_COND',
    category: 'clean-abap',
    example: {
      bad: `IF lv_score >= 90.\n  lv_grade = 'A'.\nELSEIF lv_score >= 80.\n  lv_grade = 'B'.\nELSE.\n  lv_grade = 'C'.\nENDIF.`,
      good: `lv_grade = COND #( \n  WHEN lv_score >= 90 THEN 'A'\n  WHEN lv_score >= 80 THEN 'B'\n  ELSE 'C' ).`,
    },
  },
  {
    ruleId: 'prefer-switch',
    title: 'Prefer SWITCH #( ) Expression over CASE Statement',
    rationale: 'CASE statements that merely assign values to a single variable can be written much more concisely using modern ABAP SWITCH #( ) constructor expressions, eliminating repetitive assignment code and improving readability.',
    className: 'ZCL_SKYLINT_PREF_SWITCH',
    pseudoComment: 'PREF_SWITCH',
    category: 'clean-abap',
    example: {
      bad: `CASE lv_status.\n  WHEN 'O'.\n    lv_text = 'Open'.\n  WHEN 'C'.\n    lv_text = 'Closed'.\n  WHEN OTHERS.\n    lv_text = 'Unknown'.\nENDCASE.`,
      good: `lv_text = SWITCH #( lv_status\n  WHEN 'O' THEN 'Open'\n  WHEN 'C' THEN 'Closed'\n  ELSE 'Unknown' ).`,
    },
  },
  {
    ruleId: 'prefer-lines',
    title: 'Prefer lines( ) over DESCRIBE TABLE',
    rationale: 'The built-in `lines( )` function is modern, functional, and can be embedded directly into expressions and conditionals without requiring a temporary variable or the cumbersome procedural `DESCRIBE TABLE ... LINES` statement.',
    className: 'ZCL_SKYLINT_PREF_LINES',
    pseudoComment: 'LINES',
    category: 'clean-abap',
    example: {
      bad: `DESCRIBE TABLE lt_customers LINES lv_count.`,
      good: `lv_count = lines( lt_customers ).`,
    },
  },
  {
    ruleId: 'no-call-method',
    title: 'Avoid Obsolete CALL METHOD',
    rationale: 'Procedural `CALL METHOD` is legacy syntax from early ABAP Objects. Modern ABAP exclusively uses functional call syntax (`ref->method( )` or `class=>method( )`), which reduces visual clutter and enables functional expression chaining.',
    className: 'ZCL_SKYLINT_NO_CALL_METHOD',
    pseudoComment: 'CALL_METH',
    category: 'anti-patterns',
    example: {
      bad: `CALL METHOD lo_service->calculate_tax(
  EXPORTING
    iv_amount = lv_amount ).`,
      good: `lo_service->calculate_tax( iv_amount = lv_amount ).`,
    },
  },
  {
    ruleId: 'no-default-key',
    title: 'Avoid WITH DEFAULT KEY',
    rationale: '`WITH DEFAULT KEY` is dangerous and unpredictable because it includes all non-numeric fields as table keys, causing unexpected sorting and duplicate record bugs. Always prefer `WITH EMPTY KEY` or explicitly specified table keys.',
    className: 'ZCL_SKYLINT_NO_DEFAULT_KEY',
    pseudoComment: 'DEFAULT_KEY',
    category: 'anti-patterns',
    example: {
      bad: `DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH DEFAULT KEY.`,
      good: `DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH EMPTY KEY.`,
    },
  },
  {
    ruleId: 'prefer-is-not',
    title: 'Prefer IS NOT over NOT ... IS',
    rationale: 'Writing `IF lo_ref IS NOT BOUND` or `IF lt_tab IS NOT INITIAL` mirrors natural language reading order and avoids misreading inverted expressions that start with `NOT`.',
    className: 'ZCL_SKYLINT_PREF_IS_NOT',
    pseudoComment: 'IS_NOT',
    category: 'clean-abap',
    example: {
      bad: `IF NOT lo_instance IS BOUND.
  RETURN.
ENDIF.`,
      good: `IF lo_instance IS NOT BOUND.
  RETURN.
ENDIF.`,
    },
  },
  {
    ruleId: 'no-me-reference',
    title: 'Avoid Redundant ME-> Self Reference',
    rationale: 'In ABAP, member variables and methods are automatically accessible within the instance context. Prefixing every member access with `me->` creates visual noise, except when disambiguating parameter shadowing in constructors.',
    className: 'ZCL_SKYLINT_NO_ME_REFERENCE',
    pseudoComment: 'ME',
    category: 'anti-patterns',
    example: {
      bad: `me->mv_status = c_active.
me->process_order( ).`,
      good: `mv_status = c_active.
process_order( ).`,
    },
  },
  {
    ruleId: 'no-redundant-method-call',
    title: 'Omit Redundant Call Syntax (EXPORTING / RECEIVING / Single Param)',
    rationale: 'Modern ABAP allows omitting the `EXPORTING` and `RECEIVING` keywords in functional method calls. Furthermore, when calling a method with a single importing parameter, the parameter name can be omitted entirely to make code clean and concise.',
    className: 'ZCL_SKYLINT_NO_REDUNDANT_CALL',
    pseudoComment: 'EXPORTING',
    category: 'anti-patterns',
    example: {
      bad: `lo_calc->compute( EXPORTING iv_val = 10 ).`,
      good: `lo_calc->compute( 10 ).`,
    },
  },
  {
    ruleId: 'no-chained-statements',
    title: 'Avoid Chained Declarations & Assignments',
    rationale: 'Chained statements (`DATA: ... , ... .`) create formatting headaches, merge conflicts in Git diffs, and frequently confuse developers regarding where a type or modifier applies. Each statement should stand independently on its own line.',
    className: 'ZCL_SKYLINT_NO_CHAINED_STMT',
    pseudoComment: 'CHAIN_DECL',
    category: 'anti-patterns',
    example: {
      bad: `DATA: lv_id   TYPE string,
      lv_name TYPE string.`,
      good: `DATA lv_id   TYPE string.
DATA lv_name TYPE string.`,
    },
  },
  {
    ruleId: 'prefer-string-template',
    title: 'Prefer String Templates over CONCATENATE',
    rationale: 'String templates (`|Hello { lv_name }|`) provide type-safe, readable string interpolation with built-in formatting options. They eliminate procedural `CONCATENATE` and `SEPARATED BY` statements.',
    className: 'ZCL_SKYLINT_PREF_STR_TMPL',
    pseudoComment: 'STR_TMPL',
    category: 'clean-abap',
    example: {
      bad: `CONCATENATE 'Hello' iv_name INTO lv_greeting SEPARATED BY space.`,
      good: `lv_greeting = |Hello { iv_name }|.`,
    },
  },
  {
    ruleId: 'no-boolean-comparison',
    title: 'Avoid Comparing to abap_true / abap_false',
    rationale: 'Predicate methods and boolean expressions evaluate directly to true or false. Comparing them explicitly (`IF is_valid( ) = abap_true`) is redundant, noisy, and unidiomatic.',
    className: 'ZCL_SKYLINT_NO_BOOL_COMPARE',
    pseudoComment: 'BOOL_COMPARE',
    category: 'anti-patterns',
    example: {
      bad: `IF is_valid( ) = abap_true.
  execute( ).
ENDIF.`,
      good: `IF is_valid( ).
  execute( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'prefer-line-exists',
    title: 'Prefer line_exists( ) over READ TABLE TRANSPORTING NO FIELDS',
    rationale: '`line_exists( )` clearly communicates the intent of checking table membership in a single functional expression, eliminating the boilerplate of `READ TABLE ... TRANSPORTING NO FIELDS` followed by `sy-subrc = 0`.',
    className: 'ZCL_SKYLINT_PREF_LINE_EXISTS',
    pseudoComment: 'LINE_EXISTS',
    category: 'clean-abap',
    example: {
      bad: `READ TABLE lt_items TRANSPORTING NO FIELDS WITH KEY id = lv_id.
IF sy-subrc = 0.
  process( ).
ENDIF.`,
      good: `IF line_exists( lt_items[ id = lv_id ] ).
  process( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'prefer-return',
    title: 'Prefer RETURN over EXIT in Methods',
    rationale: 'In method contexts, `EXIT` can be ambiguous when placed near loops. `RETURN` explicitly indicates an immediate exit from the current processing block or method.',
    className: 'ZCL_SKYLINT_PREF_RETURN',
    pseudoComment: 'RETURN',
    category: 'clean-abap',
    example: {
      bad: `METHOD execute.
  IF is_invalid( ).
    EXIT.
  ENDIF.
  process( ).
ENDMETHOD.`,
      good: `METHOD execute.
  IF is_invalid( ).
    RETURN.
  ENDIF.
  process( ).
ENDMETHOD.`,
    },
  },
  {
    ruleId: 'no-check-statement',
    title: 'Avoid CHECK Statements',
    rationale: '`CHECK` has context-dependent dual semantics: inside loops it behaves like `CONTINUE`, but outside loops it behaves like `RETURN`. This makes code fragile and refactoring hazardous. Use explicit `IF ... CONTINUE` or `IF ... RETURN` instead.',
    className: 'ZCL_SKYLINT_NO_CHECK_STMT',
    pseudoComment: 'CHECK_STMT',
    category: 'anti-patterns',
    example: {
      bad: `LOOP AT lt_items INTO ls_item.
  CHECK ls_item-status = 'ACTIVE'.
  process( ls_item ).
ENDLOOP.`,
      good: `LOOP AT lt_items INTO ls_item.
  IF ls_item-status <> 'ACTIVE'.
    CONTINUE.
  ENDIF.
  process( ls_item ).
ENDLOOP.`,
    },
  },
  {
    ruleId: 'no-empty-block',
    title: 'Avoid Empty Control Blocks',
    rationale: 'Empty blocks (such as `IF ... ELSEIF ... ENDIF` with no executable statements) confuse readers and usually represent unfinished business logic or forgotten debug code.',
    className: 'ZCL_SKYLINT_NO_EMPTY_BLOCK',
    pseudoComment: 'EMPTY_BLOCK',
    category: 'anti-patterns',
    example: {
      bad: `IF lv_condition = abap_true.
  " Empty block
ELSE.
  process( ).
ENDIF.`,
      good: `IF lv_condition = abap_false.
  process( ).
ENDIF.`,
    },
  },

  {
    ruleId: 'no-duplicate-conditions',
    title: 'Avoid Duplicate Branch Conditions',
    rationale: 'Repeating the exact same condition across `IF / ELSEIF` or `WHEN` branches means subsequent duplicate branches can never be reached, indicating a copy-paste error or broken logic.',
    className: 'ZCL_SKYLINT_NO_DUP_COND',
    pseudoComment: 'DUP_COND',
    category: 'anti-patterns',
    example: {
      bad: `IF lv_type = 'A' OR lv_type = 'A'.
  process( ).
ENDIF.`,
      good: `IF lv_type = 'A'.
  process( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'prefer-merged-ifs',
    title: 'Merge Nested IF Statements',
    rationale: 'Consecutive nested `IF` statements without intermediate statements can be combined with `AND`. This reduces nesting depth, flattens control flow, and simplifies cyclomatic complexity.',
    className: 'ZCL_SKYLINT_PREF_MERGE_IFS',
    pseudoComment: 'MERGE_IFS',
    category: 'clean-abap',
    example: {
      bad: `IF is_connected( ).
  IF has_permission( ).
    execute( ).
  ENDIF.
ENDIF.`,
      good: `IF is_connected( ) AND has_permission( ).
  execute( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'no-unreachable-code',
    title: 'Avoid Dead / Unreachable Code',
    rationale: 'Statements appearing immediately after an unconditional `RETURN`, `RAISE EXCEPTION`, `EXIT`, or `LEAVE PROGRAM` can never execute, cluttering the codebase and misleading maintainers.',
    className: 'ZCL_SKYLINT_NO_UNREACHABLE',
    pseudoComment: 'UNREACHABLE',
    category: 'anti-patterns',
    example: {
      bad: `RETURN.
lv_count = lv_count + 1. " Unreachable statement`,
      good: `lv_count = lv_count + 1.
RETURN.`,
    },
  },
  {
    ruleId: 'no-single-when',
    title: 'Avoid CASE with a Single WHEN Branch',
    rationale: 'A `CASE` statement containing only one `WHEN` branch is unnecessarily verbose. An `IF ... ENDIF` is more concise and idiomatic.',
    className: 'ZCL_SKYLINT_NO_SINGLE_WHEN',
    pseudoComment: 'SINGLE_WHEN',
    category: 'anti-patterns',
    example: {
      bad: `CASE lv_status.
  WHEN 'A'.
    process_a( ).
ENDCASE.`,
      good: `IF lv_status = 'A'.
  process_a( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'no-yoda-conditions',
    title: 'Avoid Yoda Conditions',
    rationale: 'Placing constants or literals on the left side of comparisons (`IF 42 = lv_value`) impairs readability. ABAP natural reading flow expects the variable or subject on the left (`IF lv_value = 42`).',
    className: 'ZCL_SKYLINT_NO_YODA_COND',
    pseudoComment: 'YODA_COND',
    category: 'anti-patterns',
    example: {
      bad: `IF 0 = lv_count.
  process( ).
ENDIF.`,
      good: `IF lv_count = 0.
  process( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'prefer-symbol-operators',
    title: 'Prefer Symbol Comparison Operators (=, <>, <, >)',
    rationale: 'Text comparison operators (`EQ`, `NE`, `LT`, `GT`, `LE`, `GE`) are legacy syntax. Modern programming and Clean ABAP universally standardize on mathematical symbols (`=`, `<>`, `<`, `>`, `<=`, `>=`).',
    className: 'ZCL_SKYLINT_PREF_SYMBOL_OP',
    pseudoComment: 'SYMBOL_OP',
    category: 'clean-abap',
    example: {
      bad: `IF lv_a EQ lv_b AND lv_c NE lv_d.
  process( ).
ENDIF.`,
      good: `IF lv_a = lv_b AND lv_c <> lv_d.
  process( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'prefer-new-operator',
    title: 'Prefer NEW #( ) over CREATE OBJECT',
    rationale: 'The constructor expression `NEW #( )` is type-inferred, expression-capable, and avoids the archaic procedural `CREATE OBJECT` statement.',
    className: 'ZCL_SKYLINT_PREF_NEW_OP',
    pseudoComment: 'NEW_OP',
    category: 'clean-abap',
    example: {
      bad: `DATA lo_customer TYPE REF TO cl_customer.
CREATE OBJECT lo_customer.`,
      good: `DATA lo_customer TYPE REF TO cl_customer.
lo_customer = NEW #( ).`,
    },
  },
  {
    ruleId: 'prefer-xsdbool',
    title: 'Prefer xsdbool( ) for Boolean Assignments',
    rationale: 'Writing `IF cond. lv_flag = abap_true. ELSE. lv_flag = abap_false. ENDIF.` is 5 lines of boilerplate. `lv_flag = xsdbool( cond )` expresses the same logic cleanly in one readable line.',
    className: 'ZCL_SKYLINT_PREF_XSDBOOL',
    pseudoComment: 'XSDBOOL',
    category: 'clean-abap',
    example: {
      bad: `IF lv_count > 0.
  lv_has_items = abap_true.
ELSE.
  lv_has_items = abap_false.
ENDIF.`,
      good: `lv_has_items = xsdbool( lv_count > 0 ).`,
    },
  },
  {
    ruleId: 'no-static-via-instance',
    title: 'Avoid Calling Static Methods via Instance References (->)',
    rationale: 'Calling a static method via an object reference arrow `lo_instance->static_method( )` gives the false impression that polymorphic instance dispatch is occurring. Use `cl_class=>static_method( )`.',
    className: 'ZCL_SKYLINT_NO_STATIC_ARROW',
    pseudoComment: 'STATIC_ARROW',
    category: 'anti-patterns',
    example: {
      bad: `DATA lo_instance TYPE REF TO cl_helper.
lo_instance->static_method( ).`,
      good: `cl_helper=>static_method( ).`,
    },
  },
  {
    ruleId: 'no-public-attributes',
    title: 'Avoid Public Attributes in Classes',
    rationale: 'Public attributes violate encapsulation because external consumers can mutate internal state arbitrarily. Encapsulate state using private/protected attributes exposed via methods or `READ-ONLY`.',
    className: 'ZCL_SKYLINT_NO_PUBLIC_ATTR',
    pseudoComment: 'PUBLIC_ATTR',
    category: 'anti-patterns',
    example: {
      bad: `CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i.
ENDCLASS.`,
      good: `CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS get_state RETURNING VALUE(rv_state) TYPE i.
  PRIVATE SECTION.
    DATA mv_state TYPE i.
ENDCLASS.`,
    },
  },
  {
    ruleId: 'no-obsolete-statements',
    title: 'Avoid Obsolete & Forbidden Statements',
    rationale: 'Legacy statements such as `MOVE`, `COMPUTE`, `REFRESH`, `TABLES`, `STATICS`, `FORM`, and `LEAVE` are prohibited in ABAP Cloud and discouraged in Clean ABAP. Replace them with modern value assignments and object-oriented constructs.',
    className: 'ZCL_SKYLINT_NO_OBSOLETE',
    pseudoComment: 'OBSOLETE',
    category: 'anti-patterns',
    example: {
      bad: `MOVE lv_src TO lv_dst.`,
      good: `lv_dst = lv_src.`,
    },
  },
  {
    ruleId: 'no-list-processing',
    title: 'Avoid Classic List Processing Statements',
    rationale: 'Statements such as `WRITE`, `ULINE`, `SKIP`, `NEW-LINE`, `FORMAT`, `POSITION`, `RESERVE`, `READ LINE`, `MODIFY LINE`, and `SCROLL LIST` are classic list-processing constructs forbidden in OO/Cloud ABAP. Use application logging and modern UI frameworks instead.',
    className: 'ZCL_SKYLINT_NO_LIST_PROC',
    pseudoComment: 'LIST_PROC',
    category: 'anti-patterns',
    example: {
      bad: `WRITE: / 'Order processed:'.\nULINE.`,
      good: `mo_logger->info( 'Order processed:' ).`,
    },
  },
  {
    ruleId: 'max-params',
    title: 'Limit Method Parameter Count',
    rationale: 'Methods with excessive parameters are difficult to comprehend, call, and test. When a method needs more than 5-8 parameters, bundle related fields into a structured type or parameter object.',
    className: 'ZCL_SKYLINT_MAX_PARAMS',
    pseudoComment: 'MAX_PARAMS',
    category: 'metrics',
    example: {
      bad: `METHODS execute
  IMPORTING p1 TYPE i p2 TYPE i p3 TYPE i p4 TYPE i p5 TYPE i p6 TYPE i.`,
      good: `METHODS execute
  IMPORTING is_options TYPE ty_options.`,
    },
  },
  {
    ruleId: 'no-db-in-loop',
    title: 'Avoid Database Access Inside Loops',
    rationale: 'Executing SQL queries (`SELECT`, `UPDATE`, `DELETE`) inside a `LOOP` generates an N+1 query performance anti-pattern. Fetch data in bulk using `FOR ALL ENTRIES` or SQL Joins outside the loop.',
    className: 'ZCL_SKYLINT_NO_DB_IN_LOOP',
    pseudoComment: 'DB_IN_LOOP',
    category: 'performance',
    example: {
      bad: `LOOP AT lt_orders INTO ls_order.
  SELECT SINGLE * FROM /dmo/customer
    WHERE customer_id = @ls_order-customer_id
    INTO @ls_customer.
ENDLOOP.`,
      good: `SELECT * FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customers.`,
    },
  },
  {
    ruleId: 'no-empty-fae',
    title: 'Prevent Empty FOR ALL ENTRIES Inquiries',
    rationale: 'In ABAP SQL, executing `FOR ALL ENTRIES IN @lt_table` when `lt_table` is empty drops the `WHERE` clause entirely and performs a full table scan, causing severe system performance degradation and data leaks.',
    className: 'ZCL_SKYLINT_NO_EMPTY_FAE',
    pseudoComment: 'EMPTY_FAE',
    category: 'performance',
    example: {
      bad: `SELECT * FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customers.`,
      good: `IF lt_orders IS NOT INITIAL.
  SELECT * FROM /dmo/customer
    FOR ALL ENTRIES IN @lt_orders
    WHERE customer_id = @lt_orders-customer_id
    INTO TABLE @lt_customers.
ENDIF.`,
    },
  },
  {
    ruleId: 'no-select-star',
    title: 'Avoid SELECT * Queries',
    rationale: 'Selecting all database columns transfers unnecessary data across the network, bypasses secondary indexes, and breaks table buffering. Always specify the explicit columns required.',
    className: 'ZCL_SKYLINT_NO_SELECT_STAR',
    pseudoComment: 'SELECT_STAR',
    category: 'performance',
    example: {
      bad: `SELECT * FROM /dmo/customer INTO TABLE @lt_customers.`,
      good: `SELECT customer_id, first_name, last_name
  FROM /dmo/customer
  INTO TABLE @lt_customers.`,
    },
  },
  {
    ruleId: 'no-scope-leak',
    title: 'Avoid Variable Scope Leaking from Inner Blocks',
    rationale: 'In ABAP, variable declarations inside control blocks (`IF`, `LOOP`) have procedure-wide scope. Using an inner-declared variable outside its originating block creates confusing temporal dependencies.',
    className: 'ZCL_SKYLINT_NO_SCOPE_LEAK',
    pseudoComment: 'SCOPE_LEAK',
    category: 'anti-patterns',
    example: {
      bad: `IF lv_condition = abap_true.
  DATA(lv_value) = 10.
ENDIF.
use_value( lv_value ). " Leaked outside block`,
      good: `DATA lv_value TYPE i.
IF lv_condition = abap_true.
  lv_value = 10.
ENDIF.
use_value( lv_value ).`,
    },
  },
  {
    ruleId: 'no-self-assignment',
    title: 'Avoid Redundant Self-Assignments',
    rationale: 'Assigning a variable or structure field to itself (`lv_x = lv_x`) is a redundant no-op and frequently hides a typo where another source field was intended.',
    className: 'ZCL_SKYLINT_NO_SELF_ASSIGN',
    pseudoComment: 'SELF_ASSIGN',
    category: 'anti-patterns',
    example: {
      bad: `lv_name = lv_name.`,
      good: `lv_name = iv_new_name.`,
    },
  },
  {
    ruleId: 'prefer-fully-typed',
    title: 'Require Fully Typed Variables and Parameters',
    rationale: 'Generic types (`ANY`, `DATA`, `TABLE`) bypass compiler type checking and hide runtime type mismatches. Always declare concrete, specific types unless writing truly generic frameworks.',
    className: 'ZCL_SKYLINT_PREF_FULL_TYPED',
    pseudoComment: 'FULL_TYPED',
    category: 'clean-abap',
    example: {
      bad: `CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1`,
      good: `CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.`,
    },
  },

  {
    ruleId: 'prefer-corresponding',
    title: 'Prefer CORRESPONDING #( ) Operator',
    rationale: 'The constructor expression `CORRESPONDING #( )` is type-safe, expression-capable, and supports modern features like `EXCEPT` and `MAPPING`. It replaces the archaic `MOVE-CORRESPONDING` statement.',
    className: 'ZCL_SKYLINT_PREF_CORRESP',
    pseudoComment: 'CORRESP',
    category: 'clean-abap',
    example: {
      bad: `MOVE-CORRESPONDING ls_source TO ls_target.`,
      good: `ls_target = CORRESPONDING #( ls_source ).`,
    },
  },
  {
    ruleId: 'max-method-length',
    title: 'Limit Method Length (Statements)',
    rationale: 'Long methods violate the Single Responsibility Principle, accumulate side effects, and are notoriously difficult to unit test. Split large methods into small, focused sub-methods.',
    className: 'ZCL_SKYLINT_MAX_METHOD_LEN',
    pseudoComment: 'METHOD_LEN',
    category: 'metrics',
    example: {
      bad: `" Large method exceeding configured statement threshold (> 50 statements)
METHOD execute.
  " 60+ statements in a single procedure...
ENDMETHOD.`,
      good: `" Split into smaller, single-responsibility helper methods
METHOD execute.
  prepare_data( ).
  process_records( ).
  finalize_result( ).
ENDMETHOD.`,
    },
  },
  {
    ruleId: 'max-nesting-depth',
    title: 'Limit Control Flow Nesting Depth',
    rationale: 'Deeply nested blocks (`IF`, `LOOP`, `TRY`, `CASE`) cause cognitive overload ("arrow antipattern"). Flatten nested code using early exits (`RETURN`), guard clauses, and extracted methods.',
    className: 'ZCL_SKYLINT_MAX_NESTING',
    pseudoComment: 'NESTING',
    category: 'metrics',
    example: {
      bad: `IF cond1.
  IF cond2.
    IF cond3.
      IF cond4.
        execute( ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.`,
      good: `IF NOT cond1 OR NOT cond2 OR NOT cond3 OR NOT cond4.
  RETURN.
ENDIF.
execute( ).`,
    },
  },
  {
    ruleId: 'no-sy-modify',
    title: 'Avoid Modifying System Fields (sy-*)',
    rationale: 'System fields like `sy-subrc`, `sy-tabix`, and `sy-index` are managed exclusively by the ABAP runtime. Writing to them manually undermines system integrity and masks actual execution results.',
    className: 'ZCL_SKYLINT_NO_SY_MODIFY',
    pseudoComment: 'SY_MODIFY',
    category: 'security',
    example: {
      bad: `sy-subrc = 0.
sy-tabix = 1.`,
      good: `" Pass explicit return values or flags instead of modifying system variables (sy-*)
rv_success = abap_true.`,
    },
  },
  {
    ruleId: 'prefer-returning',
    title: 'Prefer Functional RETURNING Parameters',
    rationale: 'Methods with a `RETURNING` parameter can be used directly within expressions, assignments, and assertions. Prefer `RETURNING` over a single `EXPORTING` parameter.',
    className: 'ZCL_SKYLINT_PREF_RETURNING',
    pseudoComment: 'RETURNING',
    category: 'clean-abap',
    example: {
      bad: `METHODS calculate
  EXPORTING ev_result TYPE i.`,
      good: `METHODS calculate
  RETURNING VALUE(rv_result) TYPE i.`,
    },
  },
  {
    ruleId: 'prefer-class-exceptions',
    title: 'Prefer Class-Based Exceptions over Classic EXCEPTIONS',
    rationale: 'Classic non-class exceptions (set via `sy-subrc`) lack stack traces, cannot carry context data, and cannot be propagated up call stacks cleanly. Use class-based exceptions (`CX_ROOT` subclasses).',
    className: 'ZCL_SKYLINT_PREF_CLASS_EXC',
    pseudoComment: 'CLASS_EXC',
    category: 'clean-abap',
    example: {
      bad: `METHODS execute EXCEPTIONS not_found failed.`,
      good: `METHODS execute RAISING cx_not_found cx_failed.`,
    },
  },
  {
    ruleId: 'no-dangerous-statements',
    title: 'Avoid Dangerous & Dynamic Native Statements',
    rationale: 'Dynamic code generation (`GENERATE SUBROUTINE POOL`, `INSERT REPORT`), kernel calls (`SYSTEM-CALL`), and production `ASSERT` or `RAISE SHORTDUMP` jeopardize cloud compliance, security, and stability.',
    className: 'ZCL_SKYLINT_NO_DANGEROUS_STMT',
    pseudoComment: 'DANGEROUS_STMT',
    category: 'security',
    example: {
      bad: `EXEC SQL.
  SELECT * FROM /dmo/customer INTO :wa
ENDEXEC.`,
      good: `SELECT * FROM /dmo/customer INTO TABLE @lt_customers.`,
    },
  },
  {
    ruleId: 'prefer-auth-check',
    title: 'Ensure AUTHORITY-CHECK Before Sensitive Operations',
    rationale: 'Omitting authorization checks leaves critical business data and actions exposed to unauthorized users. Always verify permissions before selecting or modifying protected resources.',
    className: 'ZCL_SKYLINT_PREF_AUTH_CHECK',
    pseudoComment: 'AUTH_CHECK',
    category: 'security',
    example: {
      bad: `CALL TRANSACTION 'VA01'.`,
      good: `CALL TRANSACTION 'VA01' WITH AUTHORITY-CHECK.`,
    },
  },
  {
    ruleId: 'prefer-order-by',
    title: 'Require ORDER BY for Deterministic SELECT Results',
    rationale: 'Selecting rows from a relational database without an explicit `ORDER BY` clause yields non-deterministic ordering that can change unpredictably between DB executions and updates.',
    className: 'ZCL_SKYLINT_PREF_ORDER_BY',
    pseudoComment: 'ORDER_BY',
    category: 'performance',
    example: {
      bad: `SELECT * FROM /dmo/customer UP TO 1 ROWS INTO @ls_customer.`,
      good: `SELECT * FROM /dmo/customer ORDER BY customer_id UP TO 1 ROWS INTO @ls_customer.`,
    },
  },
  {
    ruleId: 'max-cyclomatic-complexity',
    title: 'Limit Cyclomatic Complexity',
    rationale: 'High cyclomatic complexity means a method contains too many decision points (branches, loops, catches), making comprehensive unit test branch coverage nearly impossible.',
    className: 'ZCL_SKYLINT_MAX_CYCLO_COMP',
    pseudoComment: 'CYCLO_COMP',
    category: 'metrics',
    example: {
      bad: `" Complex method containing excessive branches (> 10 cyclomatic complexity)
METHOD compute.
  IF c1. ... ELSEIF c2. ... ELSEIF c3. ...
ENDMETHOD.`,
      good: `" Decompose into strategy classes or cohesive helper methods
METHOD compute.
  ro_strategy = mo_factory->get_strategy( mv_type ).
  ro_strategy->execute( ).
ENDMETHOD.`,
    },
  },
  {
    ruleId: 'prefer-final-class',
    title: 'Design for Inheritance or Prohibit It (FINAL)',
    rationale: 'Classes not explicitly designed and documented for inheritance should be declared `FINAL`. This prevents subclassing that relies on fragile base-class implementation details.',
    className: 'ZCL_SKYLINT_PREF_FINAL_CLS',
    pseudoComment: 'FINAL_CLS',
    category: 'clean-abap',
    example: {
      bad: `CLASS cl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
  " Class not intended for inheritance
ENDCLASS.`,
      good: `CLASS cl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
ENDCLASS.`,
    },
  },

  {
    ruleId: 'no-magic-numbers',
    title: 'Avoid Magic Numbers; Use Named Constants',
    rationale: 'Hardcoded numeric literals scattered in logic obscure business rules and make updates error-prone. Give numbers meaningful names by declaring structured constants.',
    className: 'ZCL_SKYLINT_NO_MAGIC_NUMBERS',
    pseudoComment: 'MAGIC_NUMBERS',
    category: 'anti-patterns',
    example: {
      bad: `IF lv_status = 3.
  process( ).
ENDIF.`,
      good: `CONSTANTS c_status_completed TYPE i VALUE 3.
IF lv_status = c_status_completed.
  process( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'prefer-insert-into',
    title: 'Prefer INSERT ... INTO TABLE over APPEND',
    rationale: '`APPEND` implies indexed, sequential appending and fails on hashed or sorted tables. `INSERT ... INTO TABLE` works polymorphically across all internal table categories.',
    className: 'ZCL_SKYLINT_PREF_INSERT',
    pseudoComment: 'INSERT_INTO',
    category: 'clean-abap',
    example: {
      bad: `APPEND ls_item TO lt_items.`,
      good: `INSERT ls_item INTO TABLE lt_items.`,
    },
  },
  {
    ruleId: 'no-like-objects',
    title: 'Avoid LIKE Typing on Global Dictionary Objects',
    rationale: 'Typing dictionary objects with `LIKE` is obsolete. Use `TYPE` to refer to data types and reserve `LIKE` solely for referencing local data objects in the same procedure.',
    className: 'ZCL_SKYLINT_NO_LIKE_OBJECTS',
    pseudoComment: 'LIKE_OBJECTS',
    category: 'anti-patterns',
    example: {
      bad: `DATA lv_copy LIKE lv_original.`,
      good: `DATA lv_copy TYPE string.`,
    },
  },
  {
    ruleId: 'max-constructor-statements',
    title: 'Keep Constructors Clean & Lightweight',
    rationale: 'Constructors should only initialize state and inject dependencies. Heavy business logic, database queries, or network I/O in constructors make test mocking and instantiation brittle.',
    className: 'ZCL_SKYLINT_MAX_CTOR_STMTS',
    pseudoComment: 'CLEAN_CTOR',
    category: 'metrics',
    example: {
      bad: `METHOD constructor.
  super->constructor( ).
  " 15+ statements initializing complex states and reading DB...
ENDMETHOD.`,
      good: `METHOD constructor.
  super->constructor( ).
  mo_gateway = io_gateway. " Simple dependency assignment only
ENDMETHOD.`,
    },
  },
  {
    ruleId: 'no-static-classes',
    title: 'Avoid Purely Static Utility Classes',
    rationale: 'Classes consisting entirely of static methods cannot be mocked via interfaces or subclassing during unit tests, creating rigid coupling throughout the application.',
    className: 'ZCL_SKYLINT_NO_STATIC_CLS',
    pseudoComment: 'STATIC_CLS',
    category: 'anti-patterns',
    example: {
      bad: `CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
    CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.`,
      good: `CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_math_util.
    METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.`,
    },
  },
  {
    ruleId: 'prefer-predicate-names',
    title: 'Use Predicate Naming for Boolean Methods (is_, has_, can_)',
    rationale: 'Methods returning boolean status should read like questions (`is_valid`, `has_children`, `can_execute`) so conditionals read naturally like plain English.',
    className: 'ZCL_SKYLINT_PREF_PRED_NAME',
    pseudoComment: 'PRED_NAME',
    category: 'clean-abap',
    example: {
      bad: `METHODS check_active RETURNING VALUE(rv_active) TYPE abap_bool.`,
      good: `METHODS is_active RETURNING VALUE(rv_active) TYPE abap_bool.`,
    },
  },
  {
    ruleId: 'max-inheritance-depth',
    title: 'Limit Inheritance Depth',
    rationale: 'Deep class inheritance hierarchies create the fragile base class problem and tight coupling. Favor composition over inheritance (`HAS-A` instead of `IS-A`).',
    className: 'ZCL_SKYLINT_MAX_INHERIT',
    pseudoComment: 'INHERIT_DEPTH',
    category: 'metrics',
    example: {
      bad: `CLASS lcl_child DEFINITION INHERITING FROM lcl_sub_parent. " Depth > 3
ENDCLASS.`,
      good: `" Favor composition over deep class inheritance hierarchies
CLASS lcl_worker DEFINITION.
  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO if_engine.
ENDCLASS.`,
    },
  },
  {
    ruleId: 'max-attributes',
    title: 'Limit Member Attributes per Class',
    rationale: 'Classes with dozens of member variables are almost always God Objects that handle multiple unrelated responsibilities. Split them into smaller, focused domain classes.',
    className: 'ZCL_SKYLINT_MAX_ATTRIBUTES',
    pseudoComment: 'ATTRIBUTES',
    category: 'metrics',
    example: {
      bad: `CLASS cl_order DEFINITION.
  PRIVATE SECTION.
    " 30+ individual scalar member variables
ENDCLASS.`,
      good: `CLASS cl_order DEFINITION.
  PRIVATE SECTION.
    DATA ms_header TYPE ty_order_header.
    DATA mt_items  TYPE ty_order_items.
ENDCLASS.`,
    },
  },
  {
    ruleId: 'no-interface-data',
    title: 'Avoid DATA Attributes in Interfaces',
    rationale: 'Interfaces should declare behavior (methods) and immutable contracts (constants). Mutable data in interfaces creates hidden global state across all implementers.',
    className: 'ZCL_SKYLINT_NO_INTF_DATA',
    pseudoComment: 'INTF_DATA',
    category: 'anti-patterns',
    example: {
      bad: `INTERFACE if_customer.
  DATA mv_state TYPE i. " Mutable DATA in interface
ENDINTERFACE.`,
      good: `INTERFACE if_customer.
  CONSTANTS c_default_status TYPE i VALUE 1.
  METHODS get_state RETURNING VALUE(rv_state) TYPE i.
ENDINTERFACE.`,
    },
  },
  {
    ruleId: 'no-catch-cx-root',
    title: 'Avoid Catching Generic CX_ROOT',
    rationale: 'Catching `cx_root` indiscriminately swallows system runtime errors, resource exhaustion errors, and programming bugs, masking critical defects from developers.',
    className: 'ZCL_SKYLINT_NO_CATCH_ROOT',
    pseudoComment: 'CATCH_ROOT',
    category: 'security',
    example: {
      bad: `TRY.
    process_order( ).
  CATCH cx_root.
    " Indiscriminately catches all exceptions, masking unexpected bugs
ENDTRY.`,
      good: `TRY.
    process_order( ).
  CATCH cx_order_failed INTO DATA(lx_order).
    logger->record( lx_order ).
ENDTRY.`,
    },
  },
  {
    ruleId: 'no-message-raising',
    title: 'Avoid Obsolete MESSAGE ... RAISING in Methods',
    rationale: '`MESSAGE ... RAISING` combines procedural exception handling with UI messaging, preventing proper separation of concerns. Raise modern class-based exceptions instead.',
    className: 'ZCL_SKYLINT_NO_MSG_RAISING',
    pseudoComment: 'MSG_RAISING',
    category: 'anti-patterns',
    example: {
      bad: `MESSAGE e001(zmsg) RAISING not_found.`,
      good: `RAISE EXCEPTION NEW cx_not_found( textid = cx_not_found=>c_item_missing ).`,
    },
  },
  {
    ruleId: 'no-nested-try',
    title: 'Avoid Deeply Nested TRY ... CATCH Blocks',
    rationale: 'Nesting `TRY` blocks inside other `TRY` blocks obfuscates error handling flow. Extract inner protected operations into distinct methods.',
    className: 'ZCL_SKYLINT_NO_NESTED_TRY',
    pseudoComment: 'NESTED_TRY',
    category: 'anti-patterns',
    example: {
      bad: `TRY.
    step1( ).
    TRY.
        step2( ).
      CATCH cx_step2_err.
        handle_step2( ).
    ENDTRY.
  CATCH cx_step1_err.
    handle_step1( ).
ENDTRY.`,
      good: `" Extract inner operations into focused helper methods
TRY.
    step1( ).
    execute_step2( ).
  CATCH cx_step1_err.
    handle_step1( ).
ENDTRY.`,
    },
  },
  {
    ruleId: 'no-raise-cx-sy',
    title: 'Avoid Explicitly Raising System Exceptions (CX_SY_*)',
    rationale: '`cx_sy_*` exceptions are reserved exclusively for the ABAP runtime engine (e.g., divide by zero, null reference). Applications must define and raise their own custom exception hierarchies.',
    className: 'ZCL_SKYLINT_NO_RAISE_CX_SY',
    pseudoComment: 'RAISE_CX_SY',
    category: 'security',
    example: {
      bad: `RAISE EXCEPTION NEW cx_sy_itab_line_not_found( ).`,
      good: `RAISE EXCEPTION NEW cx_item_not_found( ).`,
    },
  },
  {
    ruleId: 'prefer-subrc-check',
    title: 'Verify sy-subrc Promptly After System Calls',
    rationale: 'Statements that set `sy-subrc` (such as `SELECT SINGLE`, `READ TABLE`, `AUTHORITY-CHECK`, `ASSIGN`) must have their return code verified immediately before invoking unrelated statements.',
    className: 'ZCL_SKYLINT_PREF_CHECK_SUBRC',
    pseudoComment: 'CHECK_SUBRC',
    category: 'security',
    example: {
      bad: `SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
process_customer( ls_customer ). " sy-subrc is never checked`,
      good: `SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
IF sy-subrc = 0.
  process_customer( ls_customer ).
ENDIF.`,
    },
  },
  {
    ruleId: 'no-client-specified',
    title: 'Avoid CLIENT SPECIFIED / USING CLIENT in Cloud',
    rationale: 'Explicit client switching bypasses automatic multi-tenant client isolation and is strictly prohibited in ABAP Cloud environment standards.',
    className: 'ZCL_SKYLINT_NO_CLIENT_SPEC',
    pseudoComment: 'CLIENT_SPEC',
    category: 'security',
    example: {
      bad: `SELECT * FROM /dmo/customer USING CLIENT '100' INTO TABLE @lt_customers.`,
      good: `SELECT * FROM /dmo/customer INTO TABLE @lt_customers.`,
    },
  },
  {
    ruleId: 'no-commit-work',
    title: 'Avoid Explicit COMMIT WORK in Business Logic',
    rationale: 'Transactional business logic should rely on the persistence framework or framework save sequence (e.g. RAP) rather than triggering premature or uncoordinated database commits.',
    className: 'ZCL_SKYLINT_NO_COMMIT_WORK',
    pseudoComment: 'COMMIT_WORK',
    category: 'security',
    example: {
      bad: `" Inside a RAP behavior implementation (CL_ABAP_BEHAVIOR_HANDLER)
METHOD update.
  MODIFY ENTITIES OF ...
  COMMIT WORK.
ENDMETHOD.`,
      good: `" In RAP, commits are managed automatically by the framework save sequence
METHOD update.
  MODIFY ENTITIES OF ...
ENDMETHOD.`,
    },
  },
  {
    ruleId: 'prefer-transporting',
    title: 'Specify TRANSPORTING in MODIFY / READ TABLE',
    rationale: 'Modifying internal tables without specifying `TRANSPORTING` copies all table fields across the buffer. Specify only the modified fields to optimize execution speed.',
    className: 'ZCL_SKYLINT_PREF_TRANSPORT',
    pseudoComment: 'TRANSPORTING',
    category: 'performance',
    example: {
      bad: `LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item. " Full line copy without specifying TRANSPORTING
ENDLOOP.`,
      good: `LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item TRANSPORTING status.
ENDLOOP.`,
    },
  },

  {
    ruleId: 'prefer-string-functions',
    title: 'Prefer Built-in String Functions over SEARCH/SHIFT',
    rationale: 'Procedural string statements (`SEARCH`, `SHIFT`, `TRANSLATE`) are legacy ABAP. Replace them with functional built-in string functions (`find`, `to_upper`, `substring`, `shift_left`).',
    className: 'ZCL_SKYLINT_PREF_STR_FUNC',
    pseudoComment: 'STR_FUNC',
    category: 'clean-abap',
    example: {
      bad: `CONDENSE lv_text.
TRANSLATE lv_code TO UPPER CASE.`,
      good: `lv_text = condense( lv_text ).
lv_code = to_upper( lv_code ).`,
    },
  },
  {
    ruleId: 'prefer-calc-assign-op',
    title: 'Prefer Calculation Assignment Operators (+=, -=, *=)',
    rationale: 'Modern ABAP supports arithmetic assignment operators (`lv_count += 1.`), which are cleaner and more expressive than verbose legacy assignments (`lv_count = lv_count + 1.`).',
    className: 'ZCL_SKYLINT_PREF_CALC_OP',
    pseudoComment: 'CALC_ASSIGN',
    category: 'clean-abap',
    example: {
      bad: `lv_count = lv_count + 1.
lv_total = lv_total * 2.`,
      good: `lv_count += 1.
lv_total *= 2.`,
    },
  },
  {
    ruleId: 'prefer-early-return',
    title: 'Prefer Early Return to Reduce Nesting (Guard Clauses)',
    rationale: 'Check preconditions and invalid states at the start of the method and return immediately. This eliminates deeply nested `IF ... ELSE` ladders.',
    className: 'ZCL_SKYLINT_PREF_EARLY_RET',
    pseudoComment: 'EARLY_RETURN',
    category: 'clean-abap',
    example: {
      bad: `METHOD process_order.
  IF is_valid( ).
    " Entire method logic deeply nested
    execute_order( ).
  ENDIF.
ENDMETHOD.`,
      good: `METHOD process_order.
  IF NOT is_valid( ).
    RETURN.
  ENDIF.
  execute_order( ).
ENDMETHOD.`,
    },
  },

  {
    ruleId: 'no-unused-variables',
    title: 'Eliminate Unused Local Variables and Symbols',
    rationale: 'Unused variables clutter code, confuse developers reviewing changes, and increase compilation and execution memory overhead without providing any benefit.',
    className: 'ZCL_SKYLINT_NO_UNUSED_VARS',
    pseudoComment: 'NEEDED',
    category: 'anti-patterns',
    example: {
      bad: `DATA lv_temp TYPE string. " Declared but never referenced`,
      good: `" Remove unused declarations or add ##NEEDED pragma if required by interface`,
    },
  },
  {
    ruleId: 'prefer-decl-order',
    title: 'Order Declarations (TYPES, CONSTANTS, DATA)',
    rationale: 'Declaring types first, then constants, then data variables creates a logical reading flow where subsequent definitions can safely depend on preceding ones.',
    className: 'ZCL_SKYLINT_PREF_DECL_ORDER',
    pseudoComment: 'DECL_ORDER',
    category: 'clean-abap',
    example: {
      bad: `METHOD execute.
  DATA lv_count TYPE i.
  TYPES ty_status TYPE c LENGTH 1. " TYPES declared after DATA
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
ENDMETHOD.`,
      good: `METHOD execute.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS c_init TYPE ty_status VALUE 'I'.
  DATA lv_count TYPE i.
ENDMETHOD.`,
    },
  },
  {
    ruleId: 'no-param-escape',
    title: 'Avoid Reassigning Importing Parameters',
    rationale: 'Importing parameters should be treated as immutable inputs. Modifying them inside the method leads to unexpected side effects and debugging difficulties.',
    className: 'ZCL_SKYLINT_NO_PARAM_ESCAPE',
    pseudoComment: 'PARAM_ESCAPE',
    category: 'anti-patterns',
    example: {
      bad: `METHODS process IMPORTING !iv_data TYPE string.`,
      good: `METHODS process IMPORTING iv_data TYPE string.`,
    },
  },

  {
    ruleId: 'prefer-case',
    title: 'Prefer CASE over Multiple IF / ELSEIF on the Same Variable',
    rationale: 'When branching on multiple values of a single variable, `CASE ... WHEN` is more readable, structured, and performant than a chain of `ELSEIF` statements.',
    className: 'ZCL_SKYLINT_PREF_CASE',
    pseudoComment: 'PREF_CASE',
    category: 'clean-abap',
    example: {
      bad: `IF lv_type = 'A'.
  process_a( ).
ELSEIF lv_type = 'B'.
  process_b( ).
ELSEIF lv_type = 'C'.
  process_c( ).
ENDIF.`,
      good: `CASE lv_type.
  WHEN 'A'.
    process_a( ).
  WHEN 'B'.
    process_b( ).
  WHEN 'C'.
    process_c( ).
ENDCASE.`,
    },
  },
  {
    ruleId: 'no-inline-length',
    title: 'Avoid Obsolete Inline Length Specifications (var(len))',
    rationale: 'Specifying length in parentheses directly after a variable name (`lv_str(10) TYPE c`) is legacy syntax. Use modern explicit typing: `TYPE c LENGTH 10`.',
    className: 'ZCL_SKYLINT_NO_INLINE_LEN',
    pseudoComment: 'PAREN_LEN',
    category: 'anti-patterns',
    example: {
      bad: `DATA lv_code(10) TYPE c.`,
      good: `DATA lv_code TYPE c LENGTH 10.`,
    },
  },
  {
    ruleId: 'max-one-statement',
    title: 'Limit One Statement per Source Code Line',
    rationale: 'Placing multiple statements on a single line hinders debugger stepping, breaks Git line diffs, and hurts overall code scannability.',
    className: 'ZCL_SKYLINT_MAX_ONE_STMT',
    pseudoComment: 'ONE_STMT',
    category: 'clean-abap',
    example: {
      bad: `lv_a = 1. lv_b = 2.`,
      good: `lv_a = 1.\nlv_b = 2.`,
    },
  },
  {
    ruleId: 'no-dash-in-names',
    title: 'Avoid Obsolete Dash (-) in Program Identifiers',
    rationale: 'Using a hyphen/dash in structure component references is archaic. Modern ABAP standardizes on the arrow notation `->` or hyphen only where mandatory.',
    className: 'ZCL_SKYLINT_NO_DASH_IN_NAMES',
    pseudoComment: 'NO_DASH',
    category: 'anti-patterns',
    example: {
      bad: `DATA foo-bar TYPE i.`,
      good: `DATA foobar TYPE i.`,
    },
  },
  {
    ruleId: 'prefer-inline',
    title: 'Prefer Modern Inline Declarations in ABAP 7.40+',
    rationale: 'In versions supporting inline declarations, declaring variables at the point of first use reduces variable lifetime scope and removes top-of-method variable clutter.',
    className: 'ZCL_SKYLINT_PREF_INLINE',
    pseudoComment: 'PREFER_INLINE',
    category: 'clean-abap',
    example: {
      bad: `DATA lv_count TYPE i.\nlv_count = 10.`,
      good: `DATA(lv_count) = 10.`,
    },
  },
  {
    ruleId: 'prefer-final-data',
    title: 'Prefer FINAL( ) over DATA( ) when the variable is never written again',
    rationale: 'When an inline DATA( ) variable is assigned once and never written again, declaring it FINAL( ) communicates immutability and lets the compiler enforce it.',
    className: 'ZCL_SKYLINT_PREF_FINAL_DATA',
    pseudoComment: 'PREF_FINAL',
    category: 'clean-abap',
    example: {
      bad: `DATA(lv_count) = 10.\nWRITE lv_count.`,
      good: `FINAL(lv_count) = 10.\nWRITE lv_count.`,
    },
  },
  {
    ruleId: 'no-friends',
    title: 'Avoid FRIENDS in class definitions',
    rationale: 'FRIENDS grants another class access to private/protected members, breaking encapsulation. Expose behaviour through the public interface instead.',
    className: 'ZCL_SKYLINT_NO_FRIENDS',
    pseudoComment: 'FRIENDS',
    category: 'anti-patterns',
    example: {
      bad: `CLASS lcl_service DEFINITION FINAL FRIENDS lcl_helper CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS.`,
      good: `CLASS lcl_service DEFINITION FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS.`,
    },
  },
  {
    ruleId: 'prefer-message-class',
    title: 'Use a message class (SE91) instead of inline message text',
    rationale: 'Inline message texts cannot be translated and are hard to maintain. Define messages in a message class and raise them as e001( msg_class ).',
    className: 'ZCL_SKYLINT_PREF_MSG_CLS',
    pseudoComment: 'MSG_CLASS',
    category: 'clean-abap',
    example: {
      bad: `MESSAGE 'Something went wrong' TYPE 'E'.`,
      good: `MESSAGE e001(bc_msg).`,
    },
  },
  {
    ruleId: 'prefer-inline-cast',
    title: 'Inline a CAST helper that is only read once',
    rationale: 'A CAST helper declared as DATA and read exactly once in the following statement can be inlined, removing a temporary variable.',
    className: 'ZCL_SKYLINT_PREF_INL_CAST',
    pseudoComment: 'INLINE_CAST',
    category: 'clean-abap',
    example: {
      bad: `DATA(helper) = CAST lcl_node( object ).\nresult = helper->get_tokens( ).`,
      good: `result = CAST lcl_node( object )->get_tokens( ).`,
    },
  },
  {
    ruleId: 'no-exception-overlap',
    title: 'Classic EXCEPTIONS must not map two errors to the same number',
    rationale: 'When two classic exceptions share one error number, the caller cannot tell which one was raised.',
    className: 'ZCL_SKYLINT_NO_EXC_OVERLAP',
    pseudoComment: 'EXC_OVERLAP',
    category: 'anti-patterns',
    example: {
      bad: `CALL FUNCTION 'SOMETHING'\n  EXCEPTIONS\n    system_failure        = 1 MESSAGE lv_message\n    communication_failure = 1 MESSAGE lv_message\n    OTHERS                = 1.`,
      good: `CALL FUNCTION 'SOMETHING'\n  EXCEPTIONS\n    system_failure        = 1 MESSAGE lv_message\n    communication_failure = 2 MESSAGE lv_message\n    OTHERS                = 3.`,
    },
  },
  {
    ruleId: 'no-rfc-error-handling',
    title: 'RFC calls must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE',
    rationale: 'Remote calls can fail at runtime; the caller must handle system and communication failures (and resource failures for async calls in a group).',
    className: 'ZCL_SKYLINT_NO_RFC_ERR',
    pseudoComment: 'RFC_ERR',
    category: 'security',
    example: {
      bad: `CALL FUNCTION 'Z_RFC'\n  DESTINATION lv_rfc.`,
      good: `CALL FUNCTION 'Z_RFC'\n  DESTINATION lv_rfc\n  EXCEPTIONS\n    system_failure        = 1 MESSAGE msg\n    communication_failure = 2 MESSAGE msg\n    OTHERS                = 3.`,
    },
  },
  {
    ruleId: 'no-many-parentheses',
    title: 'Remove redundant parentheses',
    rationale: 'Parentheses that only wrap a complete condition or expression add noise and can be removed without changing semantics.',
    className: 'ZCL_SKYLINT_NO_MANY_PARENS',
    pseudoComment: 'MANY_PARENS',
    category: 'anti-patterns',
    example: {
      bad: `IF ( destination IS INITIAL ).\nENDIF.`,
      good: `IF destination IS INITIAL.\nENDIF.`,
    },
  },
  {
    ruleId: 'prefer-pass-by-reference',
    title: 'Avoid Unnecessary Pass-by-Value for Large Tables',
    rationale: 'Passing large internal tables by value creates an in-memory deep copy on every method invocation. Use pass-by-reference (`REFERENCE(it_data)`) or read-only references.',
    className: 'ZCL_SKYLINT_PREF_PASS_BY_REF',
    pseudoComment: 'SLOW_PARAM',
    category: 'performance',
    example: {
      bad: `METHODS process IMPORTING VALUE(iv_text) TYPE string.`,
      good: `METHODS process IMPORTING iv_text TYPE string.`,
    },
  },
  {
    ruleId: 'no-modify-standard-tables',
    title: 'Only Modify Tables Defined in Your Own Package/Component',
    rationale: 'Directly inserting, updating, or deleting tables belonging to another application component bypasses business validation logic and violates modular architecture.',
    className: 'ZCL_SKYLINT_NO_MOD_STD_TABLE',
    pseudoComment: 'OWN_TABLES',
    category: 'security',
    example: {
      bad: `DELETE FROM mara WHERE matnr = '100'.`,
      good: `DELETE FROM zmara WHERE matnr = '100'.`,
    },
  },
  {
    ruleId: 'no-dynamic-stuff',
    title: 'Avoid Unnecessary Dynamic Programming Constructs',
    rationale: 'Dynamic programming (`ASSIGN (lv_var)`, `CALL METHOD (lv_method)`) disables compile-time type checking, hampers automated refactoring, and opens security vulnerabilities.',
    className: 'ZCL_SKYLINT_NO_DYNAMIC_STMT',
    pseudoComment: 'NO_DYNAMIC',
    category: 'security',
    example: {
      bad: `CALL FUNCTION lv_func_name.`,
      good: `CALL FUNCTION 'BAPI_USER_GET_DETAIL'.`,
    },
  },
  {
    ruleId: 'prefer-public-constructor',
    title: 'Declare Constructor in PUBLIC SECTION',
    rationale: 'Instance constructors must always be declared in the PUBLIC SECTION, even for classes with CREATE PRIVATE or CREATE PROTECTED, ensuring standard reflection, factory instantiation, and Clean ABAP compliance.',
    className: 'ZCL_SKYLINT_PREF_PUB_CTOR',
    pseudoComment: 'PUB_CTOR',
    category: 'clean-abap',
    example: {
      bad: `CLASS zcl_service DEFINITION PUBLIC CREATE PRIVATE.\n  PRIVATE SECTION.\n    METHODS constructor.\nENDCLASS.`,
      good: `CLASS zcl_service DEFINITION PUBLIC CREATE PRIVATE.\n  PUBLIC SECTION.\n    METHODS constructor.\nENDCLASS.`,
    },
  },
  {
    ruleId: 'prefer-definitions-top',
    title: 'Place Definitions at Top of Routine',
    rationale: 'Explicit local definitions (DATA, TYPES, CONSTANTS, FIELD-SYMBOLS) should be placed at the very beginning of the routine rather than scattered in the middle of executable code.',
    className: 'ZCL_SKYLINT_PREF_DEF_TOP',
    pseudoComment: 'DEF_TOP',
    category: 'clean-abap',
    example: {
      bad: `METHOD calculate.\n  lv_total = 100.\n  DATA lv_tax TYPE i.\nENDMETHOD.`,
      good: `METHOD calculate.\n  DATA lv_tax TYPE i.\n  lv_total = 100.\nENDMETHOD.`,
    },
  },
  {
    ruleId: 'no-unnecessary-return',
    title: 'Omit Unnecessary RETURN Statement',
    rationale: 'Routines automatically return upon reaching ENDMETHOD, ENDFORM, or ENDFUNCTION. An explicit RETURN statement at the very end of the routine body is redundant and clutters the code.',
    className: 'ZCL_SKYLINT_NO_UNNEC_RETURN',
    pseudoComment: 'NO_UNNEC_RETURN',
    category: 'anti-patterns',
    example: {
      bad: `METHOD calculate.\n  lv_total = 100.\n  RETURN.\nENDMETHOD.`,
      good: `METHOD calculate.\n  lv_total = 100.\nENDMETHOD.`,
    },
  },
  {
    ruleId: 'mix-returning',
    title: 'Do Not Mix RETURNING with EXPORTING or CHANGING',
    rationale: 'Clean ABAP methods should either be pure functional (RETURNING a single result) or procedures (using EXPORTING/CHANGING). Mixing both in the same signature creates confusing APIs.',
    className: 'ZCL_SKYLINT_NO_MIX_RETURNING',
    pseudoComment: 'NO_MIX_RETURNING',
    category: 'anti-patterns',
    example: {
      bad: `METHODS get_data\n  EXPORTING ev_val TYPE i\n  RETURNING VALUE(rv_res) TYPE string.`,
      good: `METHODS get_data\n  RETURNING VALUE(rv_res) TYPE string.`,
    },
  },
  {
    ruleId: 'method-overwrites-builtin',
    title: 'Avoid Method Names That Overwrite Built-in Functions',
    rationale: 'Naming a method after a built-in ABAP function (e.g., LINES, STRLEN, MATCHES, XSDBOOL) obscures the standard SAP built-in and makes expressions ambiguous and difficult to read.',
    className: 'ZCL_SKYLINT_NO_OVERW_BUILTIN',
    pseudoComment: 'NO_OVERW_BUILTIN',
    category: 'anti-patterns',
    example: {
      bad: `METHODS matches RETURNING VALUE(rv_res) TYPE abap_bool.`,
      good: `METHODS do_match RETURNING VALUE(rv_res) TYPE abap_bool.`,
    },
  },
  {
    ruleId: 'max-one-method-parameter-per-line',
    title: 'Max One Method Parameter Definition Per Line',
    rationale: 'Defining multiple parameters on the same line hampers readability and produces noisy version control diffs. Each parameter in a signature should be declared on its own dedicated line.',
    className: 'ZCL_SKYLINT_MAX_PARAM_LINE',
    pseudoComment: 'MAX_PARAM_LINE',
    category: 'clean-abap',
    example: {
      bad: `METHODS foo IMPORTING iv_a TYPE i iv_b TYPE string.`,
      good: `METHODS foo\n  IMPORTING\n    iv_a TYPE i\n    iv_b TYPE string.`,
    },
  },
  {
    ruleId: 'prefer-is-initial',
    title: 'Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons',
    rationale: 'Checking whether an internal table, string, or variable is empty should be done with `IS [NOT] INITIAL` rather than counting `lines( ) > 0` or comparing to empty literals (`""`, `space`, `0`). `IS INITIAL` is idiomatic Clean ABAP, expressive, and optimized.',
    className: 'ZCL_SKYLINT_PREF_IS_INITIAL',
    pseudoComment: 'PREF_INIT',
    category: 'clean-abap',
    example: {
      bad: `IF lines( lt_items ) > 0.\nENDIF.`,
      good: `IF lt_items IS NOT INITIAL.\nENDIF.`,
    },
  },
  {
    ruleId: 'no-ignored-return-value',
    title: 'Do Not Ignore Return Value of Functional Methods',
    rationale: 'Functional methods that declare a `RETURNING` parameter are designed to compute and return a value. Calling such methods without assigning or consuming their result indicates a bug, dead code, or an improper command-query violation where side effects were bundled into a query.',
    className: 'ZCL_SKYLINT_NO_IGNORED_RETURN',
    pseudoComment: 'NO_IGNORED_RET',
    category: 'anti-patterns',
    example: {
      bad: `lo_calc->get_total( ).`,
      good: `lv_total = lo_calc->get_total( ).`,
    },
  },
  {
    ruleId: 'prefer-cast',
    title: 'Prefer CAST #( ) over ?=',
    rationale: '`?=` is legacy downcast syntax from early ABAP Objects. Modern ABAP exclusively uses `CAST #( )` constructor expressions, which can be inlined directly into method call chains and expressions.',
    className: 'ZCL_SKYLINT_PREF_CAST',
    pseudoComment: 'PREF_CAST',
    category: 'clean-abap',
    example: {
      bad: `lo_child ?= lo_parent.`,
      good: `lo_child = CAST #( lo_parent ).`,
    },
  },
  {
    ruleId: 'no-redundant-clear',
    title: 'Do Not CLEAR Variables Directly After Declaration',
    rationale: 'Variables in ABAP are automatically initialized to their type-specific default initial value upon declaration. Explicitly executing `CLEAR` immediately after declaration adds visual noise and redundant statements without any functional effect.',
    className: 'ZCL_SKYLINT_NO_REDUNDANT_CLEAR',
    pseudoComment: 'REDUNDANT_CLEAR',
    category: 'anti-patterns',
    example: {
      bad: `DATA lv_count TYPE i.\nCLEAR lv_count.`,
      good: `DATA lv_count TYPE i.`,
    },
  },
  {
    ruleId: 'no-modify-loop-table',
    title: 'Do Not Mutate the Internal Table Currently Being Looped',
    rationale: 'Adding rows (APPEND/INSERT), modifying, deleting, or clearing rows from the table while actively looping over it can cause infinite loops, skipped rows, or cursor invalidation. Parametric toggles are available for append, insert, modify, delete, and clear operations.',
    className: 'ZCL_SKYLINT_NO_MOD_LOOP_TAB',
    pseudoComment: 'LOOP_MODIFY',
    category: 'performance',
    example: {
      bad: `LOOP AT lt_orders INTO ls_order.\n  APPEND ls_order TO lt_orders.\nENDLOOP.`,
      good: `LOOP AT lt_orders INTO ls_order.\n  APPEND ls_order TO lt_new_orders.\nENDLOOP.`,
    },
  },
  {
    ruleId: 'no-hardcoded-env-checks',
    title: 'Avoid Hardcoding System & Tenant Environment Checks',
    rationale: 'Hardcoding system identifiers (sy-sysid), client numbers (sy-mandt), host names (sy-host), or database systems (sy-dbsys) against literal values violates cloud multi-tenancy and breaks during staging, system copy, or migration. Use feature toggles, switch frameworks, or customizing instead.',
    className: 'ZCL_SKYLINT_NO_HARDCODED_ENV',
    pseudoComment: 'HARDCODED_ENV',
    category: 'security',
    example: {
      bad: `IF sy-sysid = 'PRD' OR sy-mandt = '100'.\n  enable_production_mode( ).\nENDIF.`,
      good: `IF is_feature_enabled( c_features-prod_mode ) = abap_true.\n  enable_production_mode( ).\nENDIF.`,
    },
  },
  {
    ruleId: 'max-line-length',
    title: 'Limit Line Length',
    rationale: 'Long lines reduce readability, force horizontal scrolling, and complicate code review. Keep source lines within a configurable limit (typically 120 characters) by breaking statements and using expression-based ABAP.',
    className: 'ZCL_SKYLINT_MAX_LINE_LEN',
    pseudoComment: 'LINE_LEN',
    category: 'metrics',
    example: {
      bad: `DATA lv_extremely_long_variable_name_created_specifically_to_exceed_the_maximum_allowed_line_length_of_one_hundred_twenty_chars TYPE i.`,
      good: `DATA lv_compact_name TYPE i.`,
    },
  },
  {
    ruleId: 'prefer-naming',
    title: 'Enforce Naming Conventions',
    rationale: 'Consistent naming conventions (prefixes for variables, parameters, types, etc.) make code self-documenting and easier to navigate. Configure patterns per scope to enforce team standards automatically.',
    className: 'ZCL_SKYLINT_PREF_NAMING',
    pseudoComment: 'NAMING',
    category: 'clean-abap',
    example: {
      bad: `DATA foo TYPE i.`,
      good: `DATA lv_foo TYPE i.`,
    },
  },
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
