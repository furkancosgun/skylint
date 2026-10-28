CLASS zcl_skylint_no_catch_reraise DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        redundant_handler TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RETHROW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CATCH_RERAISE'.

    METHODS is_bare_reraise
      IMPORTING is_catch      TYPE if_ci_atc_source_code_provider=>ty_statement
                is_raise      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_catch_reraise IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect CATCH blocks that only re-raise the same exception'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-redundant_handler
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'CATCH block only re-raises the same exception; remove it'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx         TYPE i.
    DATA lv_total       TYPE i.
    DATA lv_body_count  TYPE i.
    DATA ls_single_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_body        TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement> WHERE keyword = 'CATCH'.
      lv_idx = sy-tabix + 1.
      lv_body_count = 0.
      CLEAR ls_single_stmt.

      WHILE lv_idx <= lv_total.
        ls_body = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                       iv_index      = lv_idx ).

        CASE ls_body-keyword.
          WHEN 'CATCH' OR 'CLEANUP' OR 'ENDTRY'.
            EXIT.
          WHEN OTHERS.
            lv_body_count += 1.
            IF lv_body_count = 1.
              ls_single_stmt = ls_body.
            ENDIF.
        ENDCASE.

        lv_idx += 1.
      ENDWHILE.

      IF     lv_body_count = 1
         AND ls_single_stmt-keyword = 'RAISE'
         AND is_bare_reraise( is_catch = <ls_statement>
                              is_raise = ls_single_stmt ) = abap_true.

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-redundant_handler ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_bare_reraise.
    DATA ls_into_var    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_var         TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_caught_type TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_raised_type TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    " Case 1: CATCH ... INTO lx_err -> RAISE EXCEPTION lx_err.
    ls_into_var = zcl_skylint_ast_util=>get_token_after( is_statement = is_catch
                                                         iv_lexeme    = 'INTO' ).

    ls_var = zcl_skylint_ast_util=>get_token_after( is_statement = is_raise
                                                    iv_lexeme    = 'EXCEPTION' ).

    IF ls_into_var-lexeme IS NOT INITIAL AND ls_into_var-lexeme = ls_var-lexeme.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    " Case 2: CATCH cx_type -> RAISE EXCEPTION TYPE cx_type (without PREVIOUS / EXPORTING)
    IF ls_var-lexeme = 'TYPE'.
      IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_raise
                                                    iv_lexeme    = 'PREVIOUS' )  = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_raise
                                                    iv_lexeme    = 'EXPORTING' ) = abap_true.
        RETURN.
      ENDIF.

      ls_caught_type = zcl_skylint_ast_util=>get_token_after( is_statement = is_catch
                                                              iv_lexeme    = 'CATCH' ).

      ls_raised_type = zcl_skylint_ast_util=>get_token_after( is_statement = is_raise
                                                              iv_lexeme    = 'TYPE' ).

      IF ls_caught_type-lexeme IS NOT INITIAL AND ls_caught_type-lexeme = ls_raised_type-lexeme.
        rv_yes = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
