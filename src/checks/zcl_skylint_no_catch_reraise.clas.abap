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
    DATA lv_idx   TYPE i.
    DATA ls_next1 TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next2 TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CATCH'.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.

      ls_next1 = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                      iv_index      = lv_idx + 1 ).
      IF ls_next1-keyword <> 'RAISE'.
        CONTINUE.
      ENDIF.

      ls_next2 = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                      iv_index      = lv_idx + 2 ).
      IF     ls_next2-keyword <> 'CATCH'
         AND ls_next2-keyword <> 'CLEANUP'
         AND ls_next2-keyword <> 'ENDTRY'.
        CONTINUE.
      ENDIF.

      IF is_bare_reraise( is_catch = <ls_statement>
                          is_raise = ls_next1 ) = abap_true.
        report_statement( is_statement    = ls_next1
                          iv_finding_code = c_finding_codes-redundant_handler ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_bare_reraise.
    DATA ls_into        TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_exc         TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_raised_type TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok         TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_caught_var  TYPE string.
    DATA lv_idx         TYPE i.

    rv_yes = abap_false.

    ls_into = zcl_skylint_ast_util=>get_token_after( is_statement = is_catch
                                                     iv_lexeme    = 'INTO' ).
    IF ls_into-lexeme IS NOT INITIAL.
      lv_caught_var = zcl_skylint_ast_util=>extract_name_from_paren( ls_into-lexeme ).
    ENDIF.

    ls_exc = zcl_skylint_ast_util=>get_token_after( is_statement = is_raise
                                                    iv_lexeme    = 'EXCEPTION' ).
    IF ls_exc IS INITIAL.
      RETURN.
    ENDIF.

    IF     ls_exc-references IS NOT INITIAL
       AND ls_exc-lexeme     <> 'TYPE'
       AND ls_exc-lexeme     <> 'NEW'.
      rv_yes = xsdbool( lv_caught_var IS NOT INITIAL AND ls_exc-lexeme = lv_caught_var ).
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_raise
                                                  iv_lexeme    = 'EXPORTING' ) = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_raise
                                                  iv_lexeme    = 'MESSAGE' )   = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_raise
                                                  iv_lexeme    = 'PREVIOUS' )  = abap_true.
      RETURN.
    ENDIF.

    ls_raised_type = zcl_skylint_ast_util=>get_token_after( is_statement = is_raise
                                                            iv_lexeme    = ls_exc-lexeme ).
    IF ls_raised_type IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_raised_type-lexeme CA '()'.
      REPLACE ALL OCCURRENCES OF '(' IN ls_raised_type-lexeme WITH ''.
      REPLACE ALL OCCURRENCES OF ')' IN ls_raised_type-lexeme WITH ''.
    ENDIF.

    lv_idx = 2.
    DO.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_catch
                                                iv_index     = lv_idx ).

      IF ls_tok-lexeme IS INITIAL OR ls_tok-lexeme = 'INTO'.
        EXIT.
      ENDIF.

      IF ls_tok-lexeme = ls_raised_type-lexeme.
        rv_yes = abap_true.
        RETURN.
      ENDIF.

      lv_idx += 1.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
