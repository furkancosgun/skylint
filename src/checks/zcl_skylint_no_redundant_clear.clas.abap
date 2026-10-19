CLASS zcl_skylint_no_redundant_clear DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        redundant_clear TYPE if_ci_atc_check=>ty_finding_code VALUE 'REDUNCLEAR',
        clear_at_end    TYPE if_ci_atc_check=>ty_finding_code VALUE 'CLEAR_END',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_clear TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'RMV_CLEAR',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_variable_decl,
        full_name TYPE string,
        stmt_idx  TYPE i,
        has_value TYPE abap_bool,
      END OF ty_variable_decl,
      ty_variable_decls TYPE STANDARD TABLE OF ty_variable_decl WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'REDUNDANT_CLEAR'.

    DATA mv_check_before_write TYPE abap_bool VALUE abap_true.
    DATA mv_check_without_read TYPE abap_bool VALUE abap_true.

    METHODS collect_declarations
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rt_decls) TYPE ty_variable_decls.

    METHODS is_variable_written
      IMPORTING it_statements     TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_from_idx       TYPE i
                iv_to_idx         TYPE i
                iv_full_name      TYPE string
      RETURNING VALUE(rv_written) TYPE abap_bool.

    METHODS is_variable_read
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_from_idx    TYPE i
                iv_to_idx      TYPE i
                iv_full_name   TYPE string
      RETURNING VALUE(rv_read) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_redundant_clear IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Do not CLEAR or FREE variables redundantly'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity       = if_ci_atc_check=>finding_severities-warning
                     pseudo_comment = c_pseudo_comment
                     ( code = c_finding_codes-redundant_clear
                       text = 'Do not CLEAR or FREE variables after declaration; they are already initial' )
                     ( code = c_finding_codes-clear_at_end
                       text = 'Variable is CLEARed or FREEd but never read again before procedure ends' ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_clear
                                                short_text = 'Remove redundant statement' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_BEFORE_WRITE'
                                                value = REF #( mv_check_before_write ) )
                                              ( name  = 'CHECK_WITHOUT_READ'
                                                value = REF #( mv_check_without_read ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_loop_depth TYPE i.
    DATA lt_decls      TYPE ty_variable_decls.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_decl> TYPE ty_variable_decl.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lt_decls = collect_declarations( is_procedure-statements ).
    IF lt_decls IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_stmt>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth += 1.
        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_loop_depth > 0.
            lv_loop_depth -= 1.
          ENDIF.
      ENDCASE.

      IF <ls_stmt>-keyword <> 'CLEAR' AND <ls_stmt>-keyword <> 'FREE'.
        CONTINUE.
      ENDIF.

      IF lv_loop_depth > 0.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                 iv_lexeme    = 'WITH' ) = abap_true.
        CONTINUE.
      ENDIF.

      ls_ref = zcl_skylint_ast_util=>statement_get_reference(
                   is_statement = <ls_stmt>
                   iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF ls_ref-full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN lt_decls[ full_name = ls_ref-full_name ] TO <ls_decl>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF lv_stmt_idx <= <ls_decl>-stmt_idx.
        CONTINUE.
      ENDIF.

      IF     mv_check_before_write = abap_true
         AND <ls_decl>-has_value = abap_false
         AND is_variable_written( it_statements = is_procedure-statements
                                  iv_from_idx   = <ls_decl>-stmt_idx + 1
                                  iv_to_idx     = lv_stmt_idx - 1
                                  iv_full_name  = <ls_decl>-full_name )   = abap_false.

        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_clear
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ) ).

        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-redundant_clear
                          is_quickfix     = ls_quickfix ).
        CONTINUE.
      ENDIF.

      IF     mv_check_without_read = abap_true
         AND is_variable_read( it_statements = is_procedure-statements
                               iv_from_idx   = lv_stmt_idx + 1
                               iv_to_idx     = lines( is_procedure-statements )
                               iv_full_name  = <ls_decl>-full_name )            = abap_false.

        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_clear
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ) ).

        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-clear_at_end
                          is_quickfix     = ls_quickfix ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_declarations.
    DATA lv_stmt_idx     TYPE i.
    DATA lv_struct_depth TYPE i.
    DATA ls_decl         TYPE ty_variable_decl.
    DATA lt_refs         TYPE if_ci_atc_source_code_provider=>ty_compiler_references.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_ref>  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      lv_stmt_idx = sy-tabix.

      IF <ls_stmt>-keyword <> 'DATA'.
        CONTINUE.
      ENDIF.

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

      lt_refs = zcl_skylint_ast_util=>statement_get_references(
                    is_statement = <ls_stmt>
                    iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      LOOP AT lt_refs ASSIGNING <ls_ref>.
        IF zcl_skylint_ast_util=>is_data_definition( <ls_ref> ) = abap_false.
          CONTINUE.
        ENDIF.

        IF <ls_ref>-full_name IS INITIAL.
          CONTINUE.
        ENDIF.

        IF line_exists( rt_decls[ full_name = <ls_ref>-full_name ] ).
          CONTINUE.
        ENDIF.

        CLEAR ls_decl.
        ls_decl-full_name = <ls_ref>-full_name.
        ls_decl-stmt_idx  = lv_stmt_idx.
        ls_decl-has_value = zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                                    iv_lexeme    = 'VALUE' ).
        APPEND ls_decl TO rt_decls.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_variable_written.
    rv_written = zcl_skylint_ast_util=>has_data_write_usage( it_statements = it_statements
                                                             iv_full_name  = iv_full_name
                                                             iv_from_idx   = iv_from_idx
                                                             iv_to_idx     = iv_to_idx ).
  ENDMETHOD.

  METHOD is_variable_read.
    rv_read = zcl_skylint_ast_util=>has_data_read_usage( it_statements = it_statements
                                                         iv_full_name  = iv_full_name
                                                         iv_from_idx   = iv_from_idx
                                                         iv_to_idx     = iv_to_idx ).
  ENDMETHOD.
ENDCLASS.
