CLASS zcl_skylint_no_me_reference DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_me TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_ME_REF',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_me TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMITME',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_ME_REFERENCE'.

    DATA mv_allow_in_constructors TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_me_reference IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid self-reference ME->'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-avoid_me
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Avoid unnecessary ME-> reference'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_me
                                                short_text = 'Omit ME-> prefix' ) )
                 attributes        = VALUE #( ( name  = 'ALLOW_IN_CONSTRUCTORS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_allow_in_constructors ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_tok_idx   TYPE i.
    DATA lv_lexeme    TYPE string.
    DATA lv_replace   TYPE string.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-name CP '*=>CONSTRUCTOR' AND mv_allow_in_constructors = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_tok_idx = sy-tabix.
        lv_lexeme = <ls_token>-lexeme.
        IF lv_lexeme CP 'ME->*'.
          lv_replace = substring( val = lv_lexeme
                                  off = 4 ).
          lt_overrides = VALUE #( ( index  = lv_tok_idx
                                    lexeme = lv_replace ) ).
          lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                             it_overrides = lt_overrides
                                                             iv_suffix    = '.' ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_me
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line ) ) ).

          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-avoid_me
                        is_quickfix     = ls_quickfix ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
