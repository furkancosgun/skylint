CLASS zcl_skylint_pref_msg_cls DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        message_class TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_MSG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MSG_CLASS'.

    METHODS uses_message_class
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_msg_cls IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'skylint: Use a message class instead of inline message text'
            remote_enablement = abap_true
            finding_codes     = VALUE #( ( code           = c_finding_codes-message_class
                                           severity       = if_ci_atc_check=>finding_severities-warning
                                           text           = 'Define the message class and raise it as e001( msg_class )'
                                           pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'MESSAGE'.
        CONTINUE.
      ENDIF.

      IF uses_message_class( it_statements = is_procedure-statements
                             is_statement  = <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-message_class ).
    ENDLOOP.
  ENDMETHOD.

  METHOD uses_message_class.
    DATA ls_token  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name   TYPE string.
    DATA lv_is_exc TYPE abap_bool.
    DATA lv_idx    TYPE i.
    DATA lv_cnt    TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok2> TYPE if_ci_atc_source_code_provider=>ty_token.

    IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                         iv_lexeme    = 'ID' ) > 0.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'MESSAGE' ).
    IF zcl_skylint_ast_util=>token_is_literal( ls_token ) = abap_true.
      rv_yes = abap_false.
      RETURN.
    ENDIF.

    IF contains( val = ls_token-lexeme
                 sub = '(' ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>has_compiler_reference(
           is_token = ls_token
           iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-message ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.
    IF zcl_skylint_ast_util=>has_compiler_reference(
           is_token = ls_token
           iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-message_id ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.
    IF zcl_skylint_ast_util=>has_compiler_reference(
           is_token = ls_token
           iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-message_number ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    lv_name = to_upper( ls_token-lexeme ).
    lv_is_exc = abap_false.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'DATA'.
        CONTINUE.
      ENDIF.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok2>.
        IF to_upper( <ls_tok2>-lexeme ) <> lv_name.
          CONTINUE.
        ENDIF.
        lv_cnt = lines( <ls_stmt>-tokens ).
        lv_idx = sy-tabix + 1.
        WHILE lv_idx <= lv_cnt.
          ls_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_stmt>
                                                    iv_index     = lv_idx ).
          IF ls_tok-lexeme IS NOT INITIAL AND to_upper( ls_tok-lexeme ) CP 'CX_*'.
            lv_is_exc = abap_true.
            EXIT.
          ENDIF.
          lv_idx += 1.
        ENDWHILE.
        IF lv_is_exc = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_is_exc = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_is_exc = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF lv_name CP 'LX*' OR lv_name CP 'EXC*' OR lv_name CP '*EXCEPTION*' OR lv_name CP '*ERROR*'.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    rv_yes = abap_false.
  ENDMETHOD.
ENDCLASS.
