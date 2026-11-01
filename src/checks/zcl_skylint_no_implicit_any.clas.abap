CLASS zcl_skylint_no_implicit_any DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        implicit_any TYPE if_ci_atc_check=>ty_finding_code VALUE 'IMPL_ANY',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IMPLICIT_ANY'.

    METHODS check_field_symbols
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_def
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_implicit_any IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Specify concrete types instead of generic or implicit ANY'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-implicit_any
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Specify explicit concrete types instead of generic or implicit ANY'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'FIELD-SYMBOLS'.
          check_field_symbols( <ls_statement> ).

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          check_method_def( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_field_symbols.
    DATA lv_type_idx TYPE i.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.

    IF     zcl_skylint_ast_util=>has_token_lexeme(
               is_statement = is_statement
               iv_lexeme    = 'TYPE' ) = abap_false
       AND zcl_skylint_ast_util=>has_token_lexeme(
               is_statement = is_statement
               iv_lexeme    = 'LIKE' ) = abap_false.
      report_statement(
          is_statement    = is_statement
          iv_finding_code = c_finding_codes-implicit_any ).
      RETURN.
    ENDIF.

    lv_type_idx = zcl_skylint_ast_util=>find_token(
                      is_statement = is_statement
                      iv_lexeme    = 'TYPE' ).
    IF lv_type_idx > 0 AND lv_type_idx < lines( is_statement-tokens ).
      ls_tok = zcl_skylint_ast_util=>get_token(
                   is_statement = is_statement
                   iv_index     = lv_type_idx + 1 ).
      IF ls_tok-lexeme = 'ANY'.
        report_statement(
            is_statement    = is_statement
            iv_finding_code = c_finding_codes-implicit_any ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD check_method_def.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_total = lines( is_statement-tokens ).
    lv_idx = 1.

    WHILE lv_idx <= lv_total.
      ls_tok = is_statement-tokens[ lv_idx ].
      IF ls_tok-lexeme = 'TYPE' AND lv_idx < lv_total.
        ls_tok = is_statement-tokens[ lv_idx + 1 ].
        IF ls_tok-lexeme = 'ANY' OR ls_tok-lexeme = 'DATA'.
          report_statement(
              is_statement    = is_statement
              iv_finding_code = c_finding_codes-implicit_any ).
          RETURN.
        ENDIF.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
