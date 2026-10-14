CLASS zcl_skylint_check_077 DEFINITION
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

    METHODS has_of_block
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_opener     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_check_077 IMPLEMENTATION.
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
    DATA lv_uses         TYPE i.
    DATA lv_struct_depth TYPE i.
    FIELD-SYMBOLS <ls_decl> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_decl>
         WHERE keyword = 'DATA' OR keyword = 'FIELD-SYMBOLS'.
      IF has_of_block( is_statement = <ls_decl>
                       iv_opener    = 'BEGIN' ) = abap_true.
        lv_struct_depth += 1.
        CONTINUE.
      ENDIF.
      IF has_of_block( is_statement = <ls_decl>
                       iv_opener    = 'END' ) = abap_true.
        IF lv_struct_depth > 0.
          lv_struct_depth -= 1.
        ENDIF.
        CONTINUE.
      ENDIF.
      IF lv_struct_depth > 0.
        CONTINUE.
      ENDIF.
      lv_var_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_decl>
                                                            iv_index     = 2 ).
      IF lv_var_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_uses = 0.
      LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
        LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
          IF     <ls_tok>-lexeme = lv_var_name
             AND zcl_skylint_ast_util=>has_compiler_reference(
                     is_token = <ls_tok>
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ) = abap_false
             AND zcl_skylint_ast_util=>has_compiler_reference(
                     is_token = <ls_tok>
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type )   = abap_false.
            lv_uses += 1.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF lv_uses <= 1.
        report_statement( is_statement    = <ls_decl>
                          iv_finding_code = c_finding_codes-unused_var ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_of_block.
    DATA lv_idx  TYPE i.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    LOOP AT is_statement-tokens INTO ls_tok.
      IF ls_tok-lexeme <> iv_opener.
        CONTINUE.
      ENDIF.
      lv_idx = sy-tabix + 1.
      READ TABLE is_statement-tokens INTO ls_next INDEX lv_idx.
      IF sy-subrc = 0 AND ls_next-lexeme = 'OF'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
