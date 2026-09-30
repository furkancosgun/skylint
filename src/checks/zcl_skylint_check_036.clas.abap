CLASS zcl_skylint_check_036 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_param TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITPARM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OMIT_PARAM_NAME'.

    METHODS is_exempt_statement
      IMPORTING iv_keyword       TYPE string
      RETURNING VALUE(rv_exempt) TYPE abap_bool.

    METHODS has_single_named_param
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_036 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kuralda compiler seviyesine cikarilsin + rtti ile desteklensin manuel parametre toplanmasin
    super->constructor( VALUE #( description       = 'Omit parameter name in single parameter method call'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_param
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Omit explicit parameter name in single parameter method call'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_exempt_statement( <ls_statement>-keyword ) = abap_true.
        CONTINUE.
      ENDIF.

      IF has_single_named_param( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-omit_param ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exempt_statement.
    CASE iv_keyword.
      WHEN 'CALL' OR 'EXPORT' OR 'METHODS' OR 'CLASS-METHODS'
        OR 'EVENTS' OR 'CLASS-EVENTS' OR 'INTERFACES' OR 'SUBMIT'
        OR 'FORM' OR 'FUNCTION' OR 'MODULE'.
        rv_exempt = abap_true.
      WHEN OTHERS.
        rv_exempt = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD has_single_named_param.
    DATA lv_count TYPE i.
    DATA lv_idx TYPE i.
    DATA lv_open_idx TYPE i.
    DATA lv_close_idx TYPE i.
    DATA lv_equals_count TYPE i.
    DATA lv_comma_count TYPE i.
    DATA lv_tok TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found TYPE abap_bool.

    rv_res = abap_false.
    lv_count = lines( is_statement-tokens ).

    IF lv_count < 4.
      RETURN.
    ENDIF.

    DO lv_count TIMES.
      lv_idx = sy-index.
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx
                      IMPORTING es_token     = ls_token
                                ev_found     = lv_found ).
      IF lv_found = abap_false.
        CONTINUE.
      ENDIF.
      lv_tok = ls_token-lexeme.
      IF lv_tok CP '*(' OR lv_tok = '('.
        lv_open_idx = lv_idx.
      ELSEIF lv_tok = ')'.
        lv_close_idx = lv_idx.
        EXIT.
      ENDIF.
    ENDDO.

    IF lv_open_idx = 0 OR lv_close_idx <= lv_open_idx + 2.
      RETURN.
    ENDIF.

    lv_equals_count = 0.
    lv_comma_count = 0.
    lv_idx = lv_open_idx + 1.
    WHILE lv_idx < lv_close_idx.
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx
                      IMPORTING es_token     = ls_token
                                ev_found     = lv_found ).
      IF lv_found = abap_false.
        lv_idx += 1.
        CONTINUE.
      ENDIF.
      lv_tok = ls_token-lexeme.
      CASE lv_tok.
        WHEN '='.
          lv_equals_count += 1.
        WHEN ','.
          lv_comma_count += 1.
      ENDCASE.
      lv_idx += 1.
    ENDWHILE.

    " Ensure not a constructor VALUE #( ... ) or COND #( ... )
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = lv_open_idx
                    IMPORTING es_token     = ls_token
                              ev_found     = lv_found ).
    IF lv_found = abap_false.
      RETURN.
    ENDIF.
    lv_tok = to_upper( ls_token-lexeme ).
    IF lv_equals_count = 1 AND lv_comma_count = 0 AND lv_tok <> 'VALUE' AND lv_tok <> 'COND'
       AND lv_tok <> 'EXACT' AND lv_tok <> 'CORRESPONDING' AND lv_tok <> '#(' AND lv_tok <> '('.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
