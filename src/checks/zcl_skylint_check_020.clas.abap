CLASS zcl_skylint_check_020 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        yoda_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'YODACOND',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_literal
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_comparison_operator
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_identifier
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS has_yoda_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_020 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Yoda conditions in comparison expressions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-yoda_condition
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid Yoda conditions; place variable before literal in comparison' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF has_yoda_condition( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-yoda_condition ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_yoda_condition.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA ls_t1    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t2    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t3    TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    lv_total = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_total < 3.
      RETURN.
    ENDIF.

    lv_idx = 1.
    WHILE lv_idx <= lv_total - 2.
      ls_t1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_idx ).
      ls_t2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_idx + 1 ).
      ls_t3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_idx + 2 ).

      IF     zcl_skylint_ast_util=>token_is_literal( ls_t1 )               = abap_true
         AND ls_t2-references IS INITIAL
         AND zcl_skylint_ast_util=>is_comparison_operator( ls_t2-lexeme )  = abap_true
         AND is_identifier( ls_t3 ) = abap_true
         AND zcl_skylint_ast_util=>token_is_literal( ls_t3 )               = abap_false.
        rv_has = abap_true.
        RETURN.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_literal.
    DATA ls_dummy TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_dummy-lexeme = iv_str.
    rv_is = zcl_skylint_ast_util=>token_is_literal( ls_dummy ).
  ENDMETHOD.

  METHOD is_comparison_operator.
    rv_is = zcl_skylint_ast_util=>is_comparison_operator( iv_str ).
  ENDMETHOD.

  METHOD is_identifier.
    DATA lv_upper TYPE string.
    DATA lv_first TYPE c LENGTH 1.

    rv_is = abap_false.
    IF zcl_skylint_ast_util=>has_compiler_reference(
           is_token = is_token
           iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ) = abap_true.
      rv_is = abap_true.
      RETURN.
    ENDIF.

    IF is_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_upper = to_upper( is_token-lexeme ).
    lv_first = lv_upper(1).

    IF lv_first NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_'.
      RETURN.
    ENDIF.

    CASE lv_upper.
      WHEN 'AND' OR 'OR' OR 'NOT' OR 'EQUIV' OR 'IS' OR 'INITIAL' OR 'BOUND'
        OR 'ASSIGNED' OR 'REQUESTED' OR 'SUPPLIED' OR 'IN' OR 'BETWEEN'
        OR 'LIKE' OR 'LINES' OR 'TABLE' OR 'LINE_EXISTS' OR 'LINE_INDEX'.
        RETURN.
      WHEN OTHERS.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
