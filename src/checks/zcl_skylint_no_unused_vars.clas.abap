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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NEEDED'.

    METHODS is_variable_used
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_var_name    TYPE string
                is_def_ref     TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_used) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_unused_vars IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect unused local variables and field symbols'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unused_var
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Local variable or field symbol is declared but never used'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_var_name     TYPE string.
    DATA lv_struct_depth TYPE i.
    DATA ls_def_ref      TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_decl>  TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_decl>.
      IF <ls_decl>-keyword <> 'DATA' AND <ls_decl>-keyword <> 'FIELD-SYMBOLS'.
        CONTINUE.
      ENDIF.

      " Track structure depth to avoid checking inner structure fields
      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_decl>
                                                 iv_lexeme    = 'BEGIN' ) = abap_true.
        lv_struct_depth += 1.
        CONTINUE.
      ELSEIF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_decl>
                                                     iv_lexeme    = 'END' ) = abap_true.
        IF lv_struct_depth > 0.
          lv_struct_depth -= 1.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_struct_depth > 0.
        CONTINUE.
      ENDIF.

      " Resolve the defined variable and compiler definition reference
      CLEAR: lv_var_name,
             ls_def_ref.
      LOOP AT <ls_decl>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references INTO ls_def_ref
             WHERE     kind        = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                   AND usage_grade = if_ci_atc_source_code_provider=>usage_grades-definition.
          lv_var_name = <ls_token>-lexeme.
          EXIT.
        ENDLOOP.
        IF lv_var_name IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_var_name IS INITIAL.
        CONTINUE.
      ENDIF.

      IF is_variable_used( it_statements = is_procedure-statements
                           iv_var_name   = lv_var_name
                           is_def_ref    = ls_def_ref ) = abap_false.
        report_statement( is_statement    = <ls_decl>
                          iv_finding_code = c_finding_codes-unused_var ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_variable_used.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.
    " TODO: variable is assigned but never used (ABAP cleaner)
    FIELD-SYMBOLS <ls_ref>  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_used = abap_false.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword = 'DATA' OR <ls_stmt>-keyword = 'FIELD-SYMBOLS'.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        " 1. Compiler reference matching symbol full_name (usage access)
        IF is_def_ref-full_name IS NOT INITIAL.
          LOOP AT <ls_tok>-references ASSIGNING <ls_ref>
               WHERE     kind         = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                     AND full_name    = is_def_ref-full_name
                     AND usage_grade <> if_ci_atc_source_code_provider=>usage_grades-definition.
            rv_used = abap_true.
            RETURN.
          ENDLOOP.
        ENDIF.

        " 2. Direct identifier or component access (e.g. ls_data-comp1)
        IF     ( <ls_tok>-lexeme = iv_var_name OR <ls_tok>-lexeme CP |{ iv_var_name }-*| )
           AND zcl_skylint_ast_util=>has_compiler_reference(
                   is_token = <ls_tok>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ) = abap_false
           AND zcl_skylint_ast_util=>has_compiler_reference(
                   is_token = <ls_tok>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type )   = abap_false.
          rv_used = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
