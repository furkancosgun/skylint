CLASS zcl_skylint_no_redundant_final DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        redundant_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'REDUN_FIN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_final TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REMOVFINAL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_REDUNDANT_FINAL'.

ENDCLASS.


CLASS zcl_skylint_no_redundant_final IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Avoid redundant FINAL on methods in FINAL classes'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-redundant_final
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Redundant FINAL on method; enclosing class is already FINAL'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_final
                                                                short_text = 'Remove redundant FINAL' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_cls_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_final_idx TYPE i.
    DATA lv_new_line  TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_cls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                       iv_index      = 1 ).
    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = ls_cls_stmt
                                               iv_lexeme    = 'FINAL' ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'METHODS' AND <ls_stmt>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.

      lv_final_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_stmt>
                                                       iv_lexeme    = 'FINAL' ).
      IF lv_final_idx <= 0.
        CONTINUE.
      ENDIF.

      lv_new_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_stmt>
                                                             it_deletions = VALUE #( ( lv_final_idx ) )
                                                             iv_suffix    = '.' ).

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_final
                                      iv_statement_from = sy-tabix
                                      it_new_code       = VALUE #( ( lv_new_line ) ) ).

      report_statement( is_statement    = <ls_stmt>
                        iv_finding_code = c_finding_codes-redundant_final
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
