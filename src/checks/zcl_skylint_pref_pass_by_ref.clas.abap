CLASS zcl_skylint_pref_pass_by_ref DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        slow_param_passing TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_PASRF',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_value TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMIT_VAL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_PASS_BY_REF'.

ENDCLASS.


CLASS zcl_skylint_pref_pass_by_ref IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Slow Parameter Passing'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-slow_param_passing
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Avoid pass-by-value for importing method parameters'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_value
                                                short_text = 'Omit VALUE() for importing parameter' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_importing TYPE abap_bool.
    DATA lv_stmt_idx     TYPE i.
    DATA lv_tok_idx      TYPE i.

    DATA lt_overrides    TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lv_line         TYPE string.
    DATA ls_quickfix     TYPE ty_quickfix.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>       TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.
      lv_in_importing = abap_false.
      CLEAR lt_overrides.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_tok>.
        lv_tok_idx = sy-tabix.
        CASE <ls_tok>-lexeme.
          WHEN 'IMPORTING'.
            lv_in_importing = abap_true.
          WHEN 'EXPORTING' OR 'CHANGING' OR 'RETURNING' OR 'RAISING' OR 'EXCEPTIONS' OR 'FOR' OR 'REDEFINITION'.
            lv_in_importing = abap_false.
          WHEN OTHERS.
            IF lv_in_importing = abap_true AND <ls_tok>-lexeme CP 'VALUE(*)'.
              APPEND VALUE #( index  = lv_tok_idx
                              lexeme = zcl_skylint_ast_util=>extract_name_from_paren( <ls_tok>-lexeme ) ) TO lt_overrides.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      IF lt_overrides IS NOT INITIAL.
        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                           it_overrides = lt_overrides
                                                           iv_suffix    = '.' ).
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_value
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-slow_param_passing
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
