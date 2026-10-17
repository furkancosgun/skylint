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
    ruleId: 'prefer-lines',
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
    ruleId: 'no-exporting',
    className: 'ZCL_SKYLINT_NO_EXPORTING',
    pseudoComment: 'EXPORTING',
    category: 'anti-patterns',
    example: {
      bad: `lo_calc->compute( EXPORTING iv_val = 10 ).`,
      good: `lo_calc->compute( iv_val = 10 ).`,
    },
  },
  {
    ruleId: 'no-chained-assignment',
    className: 'ZCL_SKYLINT_NO_CHAIN_ASSIGN',
    pseudoComment: 'CHAIN_ASSIGN',
    category: 'anti-patterns',
    example: {
      bad: `lv_a = lv_b = lv_c = 0.`,
      good: `lv_a = 0.
lv_b = 0.
lv_c = 0.`,
    },
  },
  {
    ruleId: 'no-chained-decl',
    className: 'ZCL_SKYLINT_NO_CHAIN_DECL',
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
    ruleId: 'no-check-in-loop',
    className: 'ZCL_SKYLINT_NO_CHECK_IN_LOOP',
    pseudoComment: 'CHECK_IN_LOOP',
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
    ruleId: 'merge-nested-ifs',
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
    ruleId: 'prefer-raise-new',
    className: 'ZCL_SKYLINT_PREF_RAISE_NEW',
    pseudoComment: 'RAISE_NEW',
    category: 'clean-abap',
    example: {
      bad: `RAISE EXCEPTION TYPE cx_failed.`,
      good: `RAISE EXCEPTION NEW cx_failed( ).`,
    },
  },
  {
    ruleId: 'prefer-xsdbool',
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
    ruleId: 'no-receiving',
    className: 'ZCL_SKYLINT_NO_RECEIVING',
    pseudoComment: 'RECEIVING',
    category: 'anti-patterns',
    example: {
      bad: `lo_calc->compute( RECEIVING rv_result = lv_result ).`,
      good: `lv_result = lo_calc->compute( ).`,
    },
  },
  {
    ruleId: 'no-static-via-instance',
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
    className: 'ZCL_SKYLINT_NO_OBSOLETE',
    pseudoComment: 'OBSOLETE',
    category: 'anti-patterns',
    example: {
      bad: `MOVE lv_src TO lv_dst.`,
      good: `lv_dst = lv_src.`,
    },
  },
  {
    ruleId: 'max-params',
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
    className: 'ZCL_SKYLINT_NO_SELF_ASSIGN',
    pseudoComment: 'SELF_ASSIGN',
    category: 'anti-patterns',
    example: {
      bad: `lv_name = lv_name.`,
      good: `lv_name = iv_new_name.`,
    },
  },
  {
    ruleId: 'require-fully-typed',
    className: 'ZCL_SKYLINT_PREF_FULL_TYPED',
    pseudoComment: 'FULL_TYPED',
    category: 'clean-abap',
    example: {
      bad: `CONSTANTS c_status VALUE 'A'. " TYPE is omitted; implicitly typed as c length 1`,
      good: `CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'.`,
    },
  },
  {
    ruleId: 'no-single-param-name',
    className: 'ZCL_SKYLINT_NO_PARAM_NAME',
    pseudoComment: 'PARAM_NAME',
    category: 'anti-patterns',
    example: {
      bad: `cl_helper=>execute( iv_data = lv_data ).`,
      good: `cl_helper=>execute( lv_data ).`,
    },
  },

  {
    ruleId: 'prefer-corresponding',
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
    className: 'ZCL_SKYLINT_NO_SY_MODIFY',
    pseudoComment: 'SY_MODIFY',
    category: 'anti-patterns',
    example: {
      bad: `sy-subrc = 0.
sy-tabix = 1.`,
      good: `" Pass explicit return values or flags instead of modifying system variables (sy-*)
rv_success = abap_true.`,
    },
  },
  {
    ruleId: 'prefer-returning',
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
    className: 'ZCL_SKYLINT_PREF_CLASS_EXC',
    pseudoComment: 'CLASS_EXC',
    category: 'clean-abap',
    example: {
      bad: `METHODS execute EXCEPTIONS not_found failed.`,
      good: `METHODS execute RAISING cx_not_found cx_failed.`,
    },
  },
  {
    ruleId: 'dangerous-statement',
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
    ruleId: 'require-auth-check',
    className: 'ZCL_SKYLINT_PREF_AUTH_CHECK',
    pseudoComment: 'AUTH_CHECK',
    category: 'security',
    example: {
      bad: `CALL TRANSACTION 'VA01'.`,
      good: `CALL TRANSACTION 'VA01' WITH AUTHORITY-CHECK.`,
    },
  },
  {
    ruleId: 'require-order-by',
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
    ruleId: 'no-raise-shortdump',
    className: 'ZCL_SKYLINT_NO_SHORTDUMP',
    pseudoComment: 'SHORTDUMP',
    category: 'anti-patterns',
    example: {
      bad: `RAISE SHORTDUMP TYPE cx_fatal.`,
      good: `RAISE EXCEPTION NEW cx_fatal( ).`,
    },
  },
  {
    ruleId: 'no-magic-numbers',
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
    className: 'ZCL_SKYLINT_PREF_INSERT',
    pseudoComment: 'INSERT_INTO',
    category: 'clean-abap',
    example: {
      bad: `APPEND ls_item TO lt_items.`,
      good: `INSERT ls_item INTO TABLE lt_items.`,
    },
  },
  {
    ruleId: 'no-obsolete-loop-control',
    className: 'ZCL_SKYLINT_NO_OBS_LOOP_CTL',
    pseudoComment: 'OBS_LOOP_CTL',
    category: 'anti-patterns',
    example: {
      bad: `LOOP AT lt_items INTO ls_item.
  AT NEW id.
    " Obsolete control statement in loop
  ENDAT.
ENDLOOP.`,
      good: `LOOP AT lt_items INTO ls_item GROUP BY ( id = ls_item-id ) INTO DATA(group).
  " Modern ABAP GROUP BY
ENDLOOP.`,
    },
  },
  {
    ruleId: 'no-like-objects',
    className: 'ZCL_SKYLINT_NO_LIKE_OBJECTS',
    pseudoComment: 'LIKE_OBJECTS',
    category: 'anti-patterns',
    example: {
      bad: `DATA lv_copy LIKE lv_original.`,
      good: `DATA lv_copy TYPE string.`,
    },
  },
  {
    ruleId: 'clean-constructor',
    className: 'ZCL_SKYLINT_CLEAN_CTOR',
    pseudoComment: 'CLEAN_CTOR',
    category: 'clean-abap',
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
    className: 'ZCL_SKYLINT_NO_STATIC_CLS',
    pseudoComment: 'STATIC_CLS',
    category: 'clean-abap',
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
    className: 'ZCL_SKYLINT_NO_NESTED_TRY',
    pseudoComment: 'NESTED_TRY',
    category: 'clean-abap',
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
    className: 'ZCL_SKYLINT_NO_RAISE_CX_SY',
    pseudoComment: 'RAISE_CX_SY',
    category: 'security',
    example: {
      bad: `RAISE EXCEPTION NEW cx_sy_itab_line_not_found( ).`,
      good: `RAISE EXCEPTION NEW cx_item_not_found( ).`,
    },
  },
  {
    ruleId: 'require-subrc-check',
    className: 'ZCL_SKYLINT_CHECK_SUBRC',
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
    ruleId: 'no-form-routines',
    className: 'ZCL_SKYLINT_NO_FORM',
    pseudoComment: 'NO_FORM',
    category: 'anti-patterns',
    example: {
      bad: `PERFORM calculate_total USING lv_qty CHANGING lv_total.
FORM calculate_total ...
ENDFORM.`,
      good: `lo_calculator->calculate_total(
  EXPORTING iv_qty   = lv_qty
  IMPORTING ev_total = lv_total ).`,
    },
  },
  {
    ruleId: 'no-client-specified',
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
    ruleId: 'require-transporting',
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
    ruleId: 'test-method-naming',
    className: 'ZCL_SKYLINT_PREF_TEST_NAME',
    pseudoComment: 'TEST_NAME',
    category: 'clean-abap',
    example: {
      bad: `METHODS calculate_discount FOR TESTING.`,
      good: `METHODS test_calculate_discount FOR TESTING.
" Or:
METHODS should_calculate_discount FOR TESTING.`,
    },
  },

  {
    ruleId: 'prefer-final-method',
    className: 'ZCL_SKYLINT_PREF_FINAL_METH',
    pseudoComment: 'FINAL_METHOD',
    category: 'clean-abap',
    example: {
      bad: `CLASS cl_service DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS process. " Non-final method in class not designed for inheritance
ENDCLASS.`,
      good: `CLASS cl_service DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS process FINAL.
ENDCLASS.`,
    },
  },
  {
    ruleId: 'prefer-string-functions',
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
    ruleId: 'prefer-early-continue',
    className: 'ZCL_SKYLINT_PREF_EARLY_CONT',
    pseudoComment: 'EARLY_CONTINUE',
    category: 'clean-abap',
    example: {
      bad: `LOOP AT lt_items INTO ls_item.
  IF ls_item-is_active = abap_true.
    " Long nested loop body
    process_item( ls_item ).
  ENDIF.
ENDLOOP.`,
      good: `LOOP AT lt_items INTO ls_item.
  IF ls_item-is_active = abap_false.
    CONTINUE.
  ENDIF.
  process_item( ls_item ).
ENDLOOP.`,
    },
  },
  {
    ruleId: 'prefer-early-return',
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
    ruleId: 'no-production-assert',
    className: 'ZCL_SKYLINT_NO_PROD_ASSERT',
    pseudoComment: 'PROD_ASSERT',
    category: 'security',
    example: {
      bad: `ASSERT lv_amount >= 0. " Triggers runtime shortdump in production if false`,
      good: `IF lv_amount < 0.
  RAISE EXCEPTION NEW cx_invalid_amount( ).
ENDIF.`,
    },
  },
  {
    ruleId: 'no-unused-variables',
    className: 'ZCL_SKYLINT_NO_UNUSED_VARS',
    pseudoComment: 'NEEDED',
    category: 'anti-patterns',
    example: {
      bad: `DATA lv_temp TYPE string. " Declared but never referenced`,
      good: `" Remove unused declarations or add ##NEEDED pragma if required by interface`,
    },
  },
  {
    ruleId: 'require-decl-order',
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
    className: 'ZCL_SKYLINT_NO_PARAM_ESCAPE',
    pseudoComment: 'PARAM_ESCAPE',
    category: 'clean-abap',
    example: {
      bad: `METHODS process IMPORTING !iv_data TYPE string.`,
      good: `METHODS process IMPORTING iv_data TYPE string.`,
    },
  },

  {
    ruleId: 'prefer-case',
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
    className: 'ZCL_SKYLINT_MAX_ONE_STMT',
    pseudoComment: 'ONE_STMT',
    category: 'clean-abap',
    example: {
      bad: `lv_a = 1. lv_b = 2.`,
      good: `lv_a = 1.\nlv_b = 2.`,
    },
  },
  {
    ruleId: 'names-no-dash',
    className: 'ZCL_SKYLINT_NAMES_NO_DASH',
    pseudoComment: 'NO_DASH',
    category: 'anti-patterns',
    example: {
      bad: `DATA foo-bar TYPE i.`,
      good: `DATA foobar TYPE i.`,
    },
  },
  {
    ruleId: 'prefer-inline',
    className: 'ZCL_SKYLINT_PREF_INLINE',
    pseudoComment: 'PREFER_INLINE',
    category: 'clean-abap',
    example: {
      bad: `DATA lv_count TYPE i.\nlv_count = 10.`,
      good: `DATA(lv_count) = 10.`,
    },
  },
  {
    ruleId: 'slow-param-passing',
    className: 'ZCL_SKYLINT_SLOW_PARAM_PASS',
    pseudoComment: 'SLOW_PARAM',
    category: 'performance',
    example: {
      bad: `METHODS process IMPORTING VALUE(iv_text) TYPE string.`,
      good: `METHODS process IMPORTING iv_text TYPE string.`,
    },
  },
  {
    ruleId: 'modify-own-tables',
    className: 'ZCL_SKYLINT_MODIFY_OWN_TAB',
    pseudoComment: 'OWN_TABLES',
    category: 'security',
    example: {
      bad: `DELETE FROM mara WHERE matnr = '100'.`,
      good: `DELETE FROM zmara WHERE matnr = '100'.`,
    },
  },
  {
    ruleId: 'no-dynamic-stuff',
    className: 'ZCL_SKYLINT_NO_DYNAMIC_STMT',
    pseudoComment: 'NO_DYNAMIC',
    category: 'security',
    example: {
      bad: `CALL FUNCTION lv_func_name.`,
      good: `CALL FUNCTION 'BAPI_USER_GET_DETAIL'.`,
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
