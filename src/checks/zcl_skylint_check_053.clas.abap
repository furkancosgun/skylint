CLASS zcl_skylint_check_053 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_auth_check TYPE if_ci_atc_check=>ty_finding_code VALUE 'AUTH_CHECK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CALL_TRANSACTION'.

    METHODS is_call_transaction
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS has_inline_auth_check
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_053 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Call Transaction Authority Check'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-missing_auth_check
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'CALL TRANSACTION must be protected with AUTHORITY-CHECK'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_auth_checked TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_auth_checked = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'AUTHORITY-CHECK'.
        lv_auth_checked = abap_true.
      ELSEIF <ls_statement>-keyword = 'CALL' AND is_call_transaction( <ls_statement> ) = abap_true.
        IF has_inline_auth_check( <ls_statement> ) = abap_false AND lv_auth_checked = abap_false.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-missing_auth_check ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_call_transaction.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    IF lines( is_statement-tokens ) >= 2.
      READ TABLE is_statement-tokens INDEX 2 INTO ls_tok2.
      IF sy-subrc = 0 AND to_upper( ls_tok2-lexeme ) = 'TRANSACTION'.
        rv_res = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD has_inline_auth_check.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex  TYPE string.
    DATA lv_prev TYPE string.

    rv_res = abap_false.
    lv_prev = ''.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).
      IF lv_prev = 'WITH' AND lv_lex = 'AUTHORITY-CHECK'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
      lv_prev = lv_lex.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
