CLASS zcl_skylint_no_hungarian DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        hungarian TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_HUNGAR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_HUNGARIAN'.

    DATA mv_check_attributes TYPE abap_bool VALUE abap_true.
    DATA mv_check_locals     TYPE abap_bool VALUE abap_true.
    DATA mv_check_params     TYPE abap_bool VALUE abap_true.

    METHODS is_hungarian
      IMPORTING iv_name      TYPE string
                iv_type      TYPE string DEFAULT ''
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_decl_name
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_parameters
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_hungarian IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid Hungarian notation and encoding prefixes'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-hungarian
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid Hungarian notation and encoding prefixes in names'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_ATTR'
                                                                value = REF #( mv_check_attributes ) )
                                                              ( name  = 'CHECK_LOCAL'
                                                                value = REF #( mv_check_locals ) )
                                                              ( name  = 'CHECK_PARAM'
                                                                value = REF #( mv_check_params ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'DATA' OR 'CLASS-DATA' OR 'STATICS' OR 'CONSTANTS' OR 'FIELD-SYMBOLS'.
          IF mv_check_attributes = abap_true OR mv_check_locals = abap_true.
            check_decl_name( <ls_stmt> ).
          ENDIF.

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          IF mv_check_params = abap_true.
            check_method_parameters( <ls_stmt> ).
          ENDIF.

        WHEN OTHERS.
          IF mv_check_locals = abap_true.
            check_inline_declarations( <ls_stmt> ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_name.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_type_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name     TYPE string.
    DATA lv_type     TYPE string.

    ls_tok = zcl_skylint_ast_util=>get_declaration_token( is_statement ).
    IF ls_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.
    lv_name = ls_tok-lexeme.

    ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                         iv_lexeme    = 'TYPE' ).
    IF ls_type_tok-lexeme IS INITIAL.
      ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                           iv_lexeme    = 'LIKE' ).
    ENDIF.
    lv_type = ls_type_tok-lexeme.

    IF lv_name IS NOT INITIAL AND is_hungarian( iv_name = lv_name
                                                iv_type = lv_type ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-hungarian ).
    ENDIF.
  ENDMETHOD.

  METHOD check_method_parameters.
    DATA lt_params TYPE zcl_skylint_ast_util=>ty_method_parameters.
    FIELD-SYMBOLS <ls_param> TYPE zcl_skylint_ast_util=>ty_method_parameter.

    lt_params = zcl_skylint_ast_util=>get_method_parameters( is_statement ).
    LOOP AT lt_params ASSIGNING <ls_param>.
      IF is_hungarian( iv_name = <ls_param>-name
                       iv_type = <ls_param>-type_name ) = abap_true.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-hungarian ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lt_inlines TYPE zcl_skylint_ast_util=>ty_inline_declarations.
    FIELD-SYMBOLS <ls_decl> TYPE zcl_skylint_ast_util=>ty_inline_declaration.

    lt_inlines = zcl_skylint_ast_util=>get_inline_declarations( is_statement ).
    LOOP AT lt_inlines ASSIGNING <ls_decl>.
      IF <ls_decl>-name IS NOT INITIAL AND is_hungarian( <ls_decl>-name ) = abap_true.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-hungarian ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_hungarian.
    DATA lv_clean TYPE string.

    rv_is = abap_false.
    lv_clean = condense( iv_name ).

    IF lv_clean CS '<'.
      REPLACE ALL OCCURRENCES OF '<' IN lv_clean WITH ''.
    ENDIF.
    IF lv_clean CS '>'.
      REPLACE ALL OCCURRENCES OF '>' IN lv_clean WITH ''.
    ENDIF.

    IF lv_clean CP 'IS_*' AND iv_type = 'ABAP_BOOL'.
      RETURN.
    ENDIF.

    IF    matches( val   = lv_clean
                   regex = '^[LMSGICER][VSTROCF]?_.*' )
       OR matches( val   = lv_clean
                   regex = '^FS_.*' ).
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
