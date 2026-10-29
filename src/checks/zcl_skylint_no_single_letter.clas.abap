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
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_declaration_token( is_statement ).

    IF ls_tok IS NOT INITIAL AND is_single_letter( ls_tok-lexeme ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-single_letter ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lt_inlines TYPE zcl_skylint_ast_util=>ty_inline_declarations.
    FIELD-SYMBOLS <ls_decl> TYPE zcl_skylint_ast_util=>ty_inline_declaration.

    lt_inlines = zcl_skylint_ast_util=>get_inline_declarations( is_statement ).
    LOOP AT lt_inlines ASSIGNING <ls_decl>.
      IF <ls_decl>-name IS NOT INITIAL AND is_single_letter( <ls_decl>-name ) = abap_true.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-single_letter ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_single_letter.
    DATA lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_clean TYPE string.
    DATA lv_core  TYPE string.

    lv_clean = condense( iv_name ).
    REPLACE ALL OCCURRENCES OF '<' IN lv_clean WITH ''.
    REPLACE ALL OCCURRENCES OF '>' IN lv_clean WITH ''.

    SPLIT lv_clean AT '_' INTO TABLE lt_parts.

    lv_core = VALUE #( lt_parts[ lines( lt_parts ) ] DEFAULT lv_clean ).

    rv_is = xsdbool( strlen( lv_core ) < mv_min_name_len ).
  ENDMETHOD.
ENDCLASS.
