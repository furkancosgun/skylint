CLASS zcl_skylint_pref_final_cls DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_not_final  TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FCLS',
        method_not_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FMETH',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_final TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADDFINAL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_pseudo_comments,
        final_cls  TYPE string VALUE 'PREF_FINAL_CLASS',
        final_meth TYPE string VALUE 'PREF_FINAL_METHOD',
      END OF c_pseudo_comments.

    DATA mv_check_classes TYPE abap_bool VALUE abap_true.
    DATA mv_check_methods TYPE abap_bool VALUE abap_true.

    METHODS is_class_missing_final
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_final_cls IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer FINAL classes and methods by default'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-class_not_final
                       text           = 'Classes should be marked FINAL by default unless designed for inheritance'
                       pseudo_comment = c_pseudo_comments-final_cls )
                     ( code           = c_finding_codes-method_not_final
                       text           = 'Declare method as FINAL if it is not intended to be redefined'
                       pseudo_comment = c_pseudo_comments-final_meth ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_final
                                                short_text = 'Add FINAL' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_CLASSES'
                                                value = REF #( mv_check_classes ) )
                                              ( name  = 'CHECK_METHODS'
                                                value = REF #( mv_check_methods ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx       TYPE i.
    DATA lv_line           TYPE string.
    DATA ls_quickfix       TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lv_is_class_final TYPE abap_bool.
    DATA ls_meth_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_meth_idx       TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_is_class_final = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CLASS'.
        CONTINUE.
      ENDIF.
      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'FINAL' ) = abap_true.
        lv_is_class_final = abap_true.
      ELSEIF mv_check_classes = abap_true AND is_class_missing_final( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-class_not_final ).
      ENDIF.
    ENDLOOP.

    IF lv_is_class_final = abap_true OR mv_check_methods = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'METHODS'.
        CONTINUE.
      ENDIF.
      IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'FINAL' )        = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'ABSTRACT' )     = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'REDEFINITION' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'FOR' )          = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'CONSTRUCTOR' )  = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'DEFAULT' )      = abap_true.
        CONTINUE.
      ENDIF.

      ls_meth_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                           iv_lexeme    = 'METHODS' ).
      IF ls_meth_tok-lexeme IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_meth_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                      iv_lexeme    = ls_meth_tok-lexeme ).
      IF lv_meth_idx <= 0.
        CONTINUE.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement(
                    is_statement = <ls_statement>
                    it_overrides = VALUE #( ( index  = lv_meth_idx
                                              lexeme = |{ ls_meth_tok-lexeme } FINAL| ) )
                    iv_suffix    = `.` ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_final
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line ) ) ).
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-method_not_final
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_class_missing_final.
    DATA ls_tok         TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex         TYPE string.
    DATA lv_is_def      TYPE abap_bool.
    DATA lv_is_final    TYPE abap_bool.
    DATA lv_is_abstract TYPE abap_bool.
    DATA lv_is_test     TYPE abap_bool.

    rv_res = abap_false.
    lv_is_def = abap_false.
    lv_is_final = abap_false.
    lv_is_abstract = abap_false.
    lv_is_test = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok WHERE references IS INITIAL.
      lv_lex = ls_tok-lexeme.
      CASE lv_lex.
        WHEN 'DEFINITION'.
          lv_is_def = abap_true.
        WHEN 'FINAL'.
          lv_is_final = abap_true.
        WHEN 'ABSTRACT'.
          lv_is_abstract = abap_true.
        WHEN 'TESTING'.
          lv_is_test = abap_true.
      ENDCASE.
    ENDLOOP.

    IF     lv_is_def      = abap_true  AND lv_is_final = abap_false
       AND lv_is_abstract = abap_false AND lv_is_test  = abap_false.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
