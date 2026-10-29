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

    ls_token = zcl_skylint_ast_util=>get_declaration_token( is_statement ).

    IF zcl_skylint_ast_util=>is_abap_keyword( ls_token-lexeme ) = abap_true.
      report_token( is_statement    = is_statement
                    is_token        = ls_token
                    iv_finding_code = c_finding_codes-keyword_name ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lt_inlines TYPE zcl_skylint_ast_util=>ty_inline_declarations.
    FIELD-SYMBOLS <ls_decl> TYPE zcl_skylint_ast_util=>ty_inline_declaration.

    lt_inlines = zcl_skylint_ast_util=>get_inline_declarations( is_statement ).
    LOOP AT lt_inlines ASSIGNING <ls_decl>.
      IF zcl_skylint_ast_util=>is_abap_keyword( <ls_decl>-name ) = abap_true.
        report_token( is_statement    = is_statement
                      is_token        = <ls_decl>-token
                      iv_finding_code = c_finding_codes-keyword_name ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
