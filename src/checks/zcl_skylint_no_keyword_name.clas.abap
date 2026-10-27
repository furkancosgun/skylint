CLASS zcl_skylint_no_keyword_name DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        keyword_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_KWD_NAM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_KEYWORD_NAME'.

    METHODS check_decl_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_keyword_name IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Using ABAP Keywords as Identifier Names'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-keyword_name
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Identifier name matches an ABAP keyword'
                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'CONSTANTS' OR 'STATICS' OR 'TYPES' OR 'FIELD-SYMBOLS'.
          check_decl_statement( <ls_statement> ).

        WHEN OTHERS.
          check_inline_declarations( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_statement.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name  TYPE string.

    ls_token = zcl_skylint_ast_util=>get_declaration_token( is_statement ).
    IF ls_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_name = ls_token-lexeme.
    IF lv_name CS '<'.
      REPLACE ALL OCCURRENCES OF '<' IN lv_name WITH ''.
    ENDIF.
    IF lv_name CS '>'.
      REPLACE ALL OCCURRENCES OF '>' IN lv_name WITH ''.
    ENDIF.

    IF lv_name IS NOT INITIAL AND zcl_skylint_ast_util=>is_abap_keyword( lv_name ) = abap_true.
      report_token( is_statement    = is_statement
                    is_token        = ls_token
                    iv_finding_code = c_finding_codes-keyword_name ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          CONTINUE.
        ENDIF.

        IF NOT (    <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
                 OR <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign ).
          CONTINUE.
        ENDIF.

        lv_name = zcl_skylint_ast_util=>extract_name_from_paren( <ls_token>-lexeme ).
        IF lv_name CS '<'.
          REPLACE ALL OCCURRENCES OF '<' IN lv_name WITH ''.
        ENDIF.
        IF lv_name CS '>'.
          REPLACE ALL OCCURRENCES OF '>' IN lv_name WITH ''.
        ENDIF.

        IF lv_name IS NOT INITIAL AND zcl_skylint_ast_util=>is_abap_keyword( lv_name ) = abap_true.
          report_token( is_statement    = is_statement
                        is_token        = <ls_token>
                        iv_finding_code = c_finding_codes-keyword_name ).
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
