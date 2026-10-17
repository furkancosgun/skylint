CLASS zcl_skylint_pref_final_cls DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_not_final  TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOT_FINAL',
        method_not_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FINAL',
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
        final_cls  TYPE string VALUE 'FINAL_CLS',
        final_meth TYPE string VALUE 'FINAL_METHOD',
      END OF c_pseudo_comments.

    METHODS is_class_missing_final
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_final_cls IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer FINAL classes and methods by default'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-class_not_final
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Classes should be marked FINAL by default unless designed for inheritance'
                       pseudo_comment = c_pseudo_comments-final_cls )
                     ( code           = c_finding_codes-method_not_final
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Declare method as FINAL if it is not intended to be redefined'
                       pseudo_comment = c_pseudo_comments-final_meth ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_final
                                                short_text = 'Add FINAL' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx       TYPE i.
    DATA lv_line           TYPE string.
    DATA ls_quickfix       TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lv_is_class_final TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_is_class_final = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CLASS'.
      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'FINAL' ) = abap_true.
        lv_is_class_final = abap_true.
      ELSEIF is_class_missing_final( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-class_not_final ).
      ENDIF.
    ENDLOOP.

    IF lv_is_class_final = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS'.
      lv_stmt_idx = sy-tabix.
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

      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                         iv_suffix    = ' FINAL' ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_final
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
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
