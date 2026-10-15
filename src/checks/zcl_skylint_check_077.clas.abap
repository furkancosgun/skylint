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

    METHODS get_struct_depth_delta
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_delta) TYPE i.

    METHODS has_of_block
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_opener     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS count_usages
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_var_name     TYPE string
      RETURNING VALUE(rv_count) TYPE i.
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
    DATA lv_struct_depth TYPE i.
    DATA lv_delta        TYPE i.
    FIELD-SYMBOLS <ls_decl> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_decl>
         WHERE keyword = 'DATA' OR keyword = 'FIELD-SYMBOLS'.

      lv_delta = get_struct_depth_delta( <ls_decl> ).
      IF lv_delta <> 0.
        lv_struct_depth += lv_delta.
        IF lv_struct_depth < 0.
          lv_struct_depth = 0.
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

      IF count_usages( it_statements = is_procedure-statements
                       iv_var_name   = lv_var_name ) <= 1.
        report_statement( is_statement    = <ls_decl>
                          iv_finding_code = c_finding_codes-unused_var ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_struct_depth_delta.
    rv_delta = 0.
    IF has_of_block( is_statement = is_statement
                     iv_opener    = 'BEGIN' ) = abap_true.
      rv_delta = 1.
    ELSEIF has_of_block( is_statement = is_statement
                         iv_opener    = 'END' ) = abap_true.
      rv_delta = -1.
    ENDIF.
  ENDMETHOD.

  METHOD has_of_block.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_next> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-lexeme <> iv_opener.
        CONTINUE.
      ENDIF.
      lv_idx = sy-tabix + 1.
      ASSIGN is_statement-tokens[ lv_idx ] TO <ls_next>.
      IF sy-subrc = 0 AND <ls_next>-lexeme = 'OF'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_usages.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_count = 0.
    LOOP AT it_statements ASSIGNING <ls_stmt>.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        IF     <ls_tok>-lexeme = iv_var_name
           AND zcl_skylint_ast_util=>has_compiler_reference(
                   is_token = <ls_tok>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ) = abap_false
           AND zcl_skylint_ast_util=>has_compiler_reference(
                   is_token = <ls_tok>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type )   = abap_false.
          rv_count += 1.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
