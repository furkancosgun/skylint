CLASS zcl_skylint_no_dyn_message DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_dyn_msg TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DYN_MSG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DYN_MESSAGE'.

    METHODS operand_not_literal
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index     TYPE i
      RETURNING VALUE(rv_no) TYPE abap_bool.

    METHODS uses_dynamic_operand
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_no) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_dyn_message IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Dynamic MESSAGE Statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-no_dyn_msg
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'MESSAGE works with a dynamic operand - keep ID, TYPE and NUMBER static'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'MESSAGE'.
        CONTINUE.
      ENDIF.

      IF uses_dynamic_operand( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-no_dyn_msg ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD uses_dynamic_operand.
    DATA lv_index   TYPE i.
    DATA lv_id_bad  TYPE abap_bool.
    DATA lv_typ_bad TYPE abap_bool.
    DATA lv_num_bad TYPE abap_bool.

    " Inline MESSAGE 'text' and MESSAGE e001(ad) carry no ID section -
    " message class preference ( pref-msg-cls ) is not this rule's domain
    lv_index = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'ID' ).
    IF lv_index = 0.
      RETURN.
    ENDIF.

    lv_id_bad = operand_not_literal( is_statement = is_statement
                                     iv_index     = lv_index ).

    lv_typ_bad = operand_not_literal( is_statement = is_statement
                                      iv_index     = zcl_skylint_ast_util=>find_token(
                                                         is_statement = is_statement
                                                         iv_lexeme    = 'TYPE' ) ).

    lv_num_bad = operand_not_literal( is_statement = is_statement
                                      iv_index     = zcl_skylint_ast_util=>find_token(
                                                         is_statement = is_statement
                                                         iv_lexeme    = 'NUMBER' ) ).

    rv_no = xsdbool( lv_id_bad = abap_true
                     OR lv_typ_bad = abap_true
                     OR lv_num_bad = abap_true ).
  ENDMETHOD.

  METHOD operand_not_literal.
    DATA ls_operand TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_no = abap_false.
    IF iv_index <= 0.
      RETURN.
    ENDIF.

    ls_operand = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = iv_index + 1 ).
    IF ls_operand-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    rv_no = xsdbool( zcl_skylint_ast_util=>token_is_literal( ls_operand ) = abap_false ).
  ENDMETHOD.
ENDCLASS.
