CLASS zcl_skylint_pref_sy DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        use_sy TYPE if_ci_atc_check=>ty_finding_code VALUE 'USE_SY',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_sy TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USE_SY',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_SY'.

    METHODS collect_overrides
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_found) TYPE zcl_skylint_ast_util=>ty_token_overrides.

ENDCLASS.


CLASS zcl_skylint_pref_sy IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer the short system field alias SY over SYST'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-use_sy
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use sy- instead of syst- for system fields'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_sy
                                                short_text = 'Replace SYST with SY' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lt_overrides = collect_overrides( <ls_statement> ).
      IF lt_overrides IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement(
                    is_statement = <ls_statement>
                    it_overrides = lt_overrides
                    iv_suffix    = '.' ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_sy
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-use_sy
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_overrides.
    DATA ls_ref  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rt_found.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme NP 'SYST*' OR <ls_token>-references IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = <ls_token>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF    ls_ref-full_name <> '\DA:SYST'
         AND ls_ref-full_name NP '\DA:SYST\*'.
        CONTINUE.
      ENDIF.

      lv_name = 'SY' && substring( val = <ls_token>-lexeme
                                    off = 4 ).
      APPEND VALUE #( index  = sy-tabix
                      lexeme = lv_name ) TO rt_found.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
