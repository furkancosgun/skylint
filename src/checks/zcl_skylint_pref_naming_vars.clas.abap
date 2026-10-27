CLASS zcl_skylint_pref_naming_vars DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        local_variable TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_NAMVR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_NAMING_VARS'.

    DATA mv_local_data     TYPE string VALUE '^L._.+$'.
    DATA mv_local_constant TYPE string VALUE '^LC_.+$'.
    DATA mv_local_fs       TYPE string VALUE '^<L._.+>$'.
    DATA mv_local_statics  TYPE string VALUE '^S._.+$'.

    METHODS matches_pattern
      IMPORTING iv_text           TYPE string
                iv_pattern        TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    METHODS get_stmt_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

    METHODS check_var_name
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pattern      TYPE string
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code.

    METHODS check_decl_name
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pattern      TYPE string
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_pref_naming_vars IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Local Variable and Field-Symbol Naming Conventions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-local_variable
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Local variable or field-symbol name does not match configured pattern'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                              ( name  = 'LOCAL_DATA'
                                                value = REF #( mv_local_data ) )
                                              ( name  = 'LOCAL_CONST'
                                                value = REF #( mv_local_constant ) )
                                              ( name  = 'LOCAL_FS'
                                                value = REF #( mv_local_fs ) )
                                              ( name  = 'LOCAL_STATICS'
                                                value = REF #( mv_local_statics ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'DATA'.
          check_var_name( is_statement    = <ls_statement>
                          iv_pattern      = mv_local_data
                          iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'STATICS'.
          check_var_name( is_statement    = <ls_statement>
                          iv_pattern      = mv_local_statics
                          iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'CONSTANTS'.
          check_var_name( is_statement    = <ls_statement>
                          iv_pattern      = mv_local_constant
                          iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'FIELD-SYMBOLS'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_local_fs
                           iv_finding_code = c_finding_codes-local_variable ).

        WHEN OTHERS.
          check_inline_declarations( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD matches_pattern.
    rv_matches = zcl_skylint_ast_util=>matches_regex(
        iv_text    = iv_text
        iv_pattern = iv_pattern ).
  ENDMETHOD.

  METHOD get_stmt_name.
    rv_name = zcl_skylint_ast_util=>get_declaration_name( is_statement ).
  ENDMETHOD.

  METHOD check_decl_name.
    check_var_name( is_statement    = is_statement
                    iv_pattern      = iv_pattern
                    iv_finding_code = iv_finding_code ).
  ENDMETHOD.

  METHOD check_var_name.
    DATA lv_name TYPE string.

    lv_name = get_stmt_name( is_statement ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = iv_pattern ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = iv_finding_code ).
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

        CASE <ls_ref>-usage_mode.
          WHEN if_ci_atc_source_code_provider=>usage_modes-definition_with_write.
            lv_name = zcl_skylint_ast_util=>extract_name_from_paren( <ls_token>-lexeme ).
            IF matches_pattern( iv_text    = lv_name
                                iv_pattern = mv_local_data ) = abap_false.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-local_variable ).
              RETURN.
            ENDIF.

          WHEN if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
            lv_name = zcl_skylint_ast_util=>extract_name_from_paren( <ls_token>-lexeme ).
            IF matches_pattern( iv_text    = lv_name
                                iv_pattern = mv_local_fs ) = abap_false.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-local_variable ).
              RETURN.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
