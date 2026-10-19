CLASS zcl_skylint_no_unused_vars DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unused_var TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNUSED_VAR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_variable_decl,
        full_name TYPE string,
        statement TYPE if_ci_atc_source_code_provider=>ty_statement,
        token     TYPE if_ci_atc_source_code_provider=>ty_token,
        is_inline TYPE abap_bool,
      END OF ty_variable_decl,
      ty_variable_decls TYPE STANDARD TABLE OF ty_variable_decl WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'NEEDED'.

    METHODS collect_declarations
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rt_decls) TYPE ty_variable_decls.

    METHODS is_variable_read
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name   TYPE string
      RETURNING VALUE(rv_read) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_unused_vars IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect unused local variables and field symbols'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unused_var
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Local variable or field symbol is declared but never read'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_decls TYPE ty_variable_decls.
    FIELD-SYMBOLS <ls_decl> TYPE ty_variable_decl.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lt_decls = collect_declarations( is_procedure-statements ).

    LOOP AT lt_decls ASSIGNING <ls_decl>.
      IF is_variable_read( it_statements = is_procedure-statements
                           iv_full_name  = <ls_decl>-full_name ) = abap_false.
        IF <ls_decl>-is_inline = abap_true.
          report_token( is_statement    = <ls_decl>-statement
                        is_token        = <ls_decl>-token
                        iv_finding_code = c_finding_codes-unused_var ).
        ELSE.
          report_statement( is_statement    = <ls_decl>-statement
                            iv_finding_code = c_finding_codes-unused_var ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_declarations.
    DATA lv_struct_depth TYPE i.
    DATA ls_decl         TYPE ty_variable_decl.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword = 'DATA' OR <ls_stmt>-keyword = 'FIELD-SYMBOLS'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                   iv_lexeme    = 'BEGIN' ) = abap_true.
          lv_struct_depth += 1.
          IF lv_struct_depth > 1.
            CONTINUE.
          ENDIF.
        ELSEIF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                       iv_lexeme    = 'END' ) = abap_true.
          IF lv_struct_depth > 0.
            lv_struct_depth -= 1.
          ENDIF.
          CONTINUE.
        ELSEIF lv_struct_depth > 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        LOOP AT <ls_tok>-references ASSIGNING <ls_ref>
             WHERE     kind        = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                   AND usage_grade = if_ci_atc_source_code_provider=>usage_grades-definition.

          IF <ls_ref>-full_name IS INITIAL.
            CONTINUE.
          ENDIF.

          IF line_exists( rt_decls[ full_name = <ls_ref>-full_name ] ).
            CONTINUE.
          ENDIF.

          CLEAR ls_decl.
          ls_decl-full_name = <ls_ref>-full_name.
          ls_decl-statement = <ls_stmt>.
          ls_decl-token     = <ls_tok>.

          CASE <ls_ref>-usage_mode.
            WHEN if_ci_atc_source_code_provider=>usage_modes-definition_with_write
              OR if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
              ls_decl-is_inline = abap_true.
            WHEN OTHERS.
              ls_decl-is_inline = xsdbool( <ls_stmt>-keyword <> 'DATA' AND <ls_stmt>-keyword <> 'FIELD-SYMBOLS' ).
          ENDCASE.

          APPEND ls_decl TO rt_decls.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_variable_read.
    rv_read = zcl_skylint_ast_util=>has_data_read_usage(
        it_statements = it_statements
        iv_full_name  = iv_full_name ).
  ENDMETHOD.
ENDCLASS.
