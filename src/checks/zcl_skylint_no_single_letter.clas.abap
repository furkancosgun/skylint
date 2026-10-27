CLASS zcl_skylint_no_single_letter DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        single_letter TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_SGL_LTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_SINGLE_LETTER'.

    DATA mv_min_name_len TYPE i VALUE 2.

    METHODS is_single_letter
      IMPORTING iv_name      TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_decl_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_single_letter IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid single-letter variable names'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-single_letter
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid single-letter variable names; use descriptive identifiers'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                              ( name  = 'MIN_NAME_LEN'
                                                value = REF #( mv_min_name_len ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'DATA' OR 'CLASS-DATA' OR 'STATICS' OR 'FIELD-SYMBOLS'.
          check_decl_statement( <ls_stmt> ).

        WHEN OTHERS.
          check_inline_declarations( <ls_stmt> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name TYPE string.

    ls_tok = zcl_skylint_ast_util=>get_declaration_token( is_statement ).
    IF ls_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.
    lv_name = ls_tok-lexeme.

    IF lv_name IS NOT INITIAL AND is_single_letter( lv_name ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-single_letter ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      LOOP AT <ls_tok>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          CONTINUE.
        ENDIF.

        IF    <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
           OR <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
          lv_name = zcl_skylint_ast_util=>extract_name_from_paren( <ls_tok>-lexeme ).
          IF lv_name IS NOT INITIAL AND is_single_letter( lv_name ) = abap_true.
            report_statement( is_statement    = is_statement
                              iv_finding_code = c_finding_codes-single_letter ).
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_single_letter.
    DATA lv_clean TYPE string.
    DATA lv_idx   TYPE i.

    rv_is = abap_false.
    lv_clean = condense( iv_name ).

    IF lv_clean CS '<'.
      REPLACE ALL OCCURRENCES OF '<' IN lv_clean WITH ''.
    ENDIF.
    IF lv_clean CS '>'.
      REPLACE ALL OCCURRENCES OF '>' IN lv_clean WITH ''.
    ENDIF.

    IF strlen( lv_clean ) = 1.
      rv_is = abap_true.
      RETURN.
    ENDIF.

    lv_idx = find( val = lv_clean
                   sub = '_'
                   occ = -1 ).
    IF lv_idx >= 0 AND lv_idx = strlen( lv_clean ) - 2.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
