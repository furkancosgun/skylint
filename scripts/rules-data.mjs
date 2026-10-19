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
    ruleId: 'no-redundant-method-call',
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
    ruleId: 'no-check-statement',
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
    ruleId: 'prefer-merged-ifs',
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
    ruleId: 'prefer-fully-typed',
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
    ruleId: 'no-dangerous-statements',
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
    ruleId: 'max-constructor-statements',
    className: 'ZCL_SKYLINT_MAX_CTOR_STMTS',
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
    ruleId: 'prefer-subrc-check',
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
    ruleId: 'prefer-transporting',
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
    ruleId: 'prefer-decl-order',
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
    ruleId: 'no-dash-in-names',
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
    className: 'ZCL_SKYLINT_NO_UNNEC_RETURN',
    pseudoComment: 'NO_UNNEC_RETURN',
    category: 'clean-abap',
    example: {
      bad: `METHOD calculate.\n  lv_total = 100.\n  RETURN.\nENDMETHOD.`,
      good: `METHOD calculate.\n  lv_total = 100.\nENDMETHOD.`,
    },
  },
  {
    ruleId: 'mix-returning',
    className: 'ZCL_SKYLINT_NO_MIX_RETURNING',
    pseudoComment: 'NO_MIX_RETURNING',
    category: 'clean-abap',
    example: {
      bad: `METHODS get_data\n  EXPORTING ev_val TYPE i\n  RETURNING VALUE(rv_res) TYPE string.`,
      good: `METHODS get_data\n  RETURNING VALUE(rv_res) TYPE string.`,
    },
  },
  {
    ruleId: 'method-overwrites-builtin',
    className: 'ZCL_SKYLINT_NO_OVERW_BUILTIN',
    pseudoComment: 'NO_OVERW_BUILTIN',
    category: 'naming',
    example: {
      bad: `METHODS matches RETURNING VALUE(rv_res) TYPE abap_bool.`,
      good: `METHODS do_match RETURNING VALUE(rv_res) TYPE abap_bool.`,
    },
  },
  {
    ruleId: 'max-one-method-parameter-per-line',
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
    className: 'ZCL_SKYLINT_NO_REDUNDANT_CLEAR',
    pseudoComment: 'REDUNDANT_CLEAR',
    category: 'clean-abap',
    example: {
      bad: `DATA lv_count TYPE i.\nCLEAR lv_count.`,
      good: `DATA lv_count TYPE i.`,
    },
  },
  {
    ruleId: 'no-modify-loop-table',
    className: 'ZCL_SKYLINT_NO_MOD_LOOP_TAB',
    pseudoComment: 'LOOP_MODIFY',
    category: 'anti-patterns',
    example: {
      bad: `LOOP AT lt_orders INTO ls_order.\n  APPEND ls_order TO lt_orders.\nENDLOOP.`,
      good: `LOOP AT lt_orders INTO ls_order.\n  APPEND ls_order TO lt_new_orders.\nENDLOOP.`,
    },
  },
  {
    ruleId: 'no-hardcoded-env-checks',
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
