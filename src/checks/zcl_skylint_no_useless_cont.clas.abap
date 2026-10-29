CLASS zcl_skylint_no_useless_cont DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        useless_continue TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_USE_CNT',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_continue TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'RMCONT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_USELESS_CONT'.

    METHODS is_loop_end_keyword
      IMPORTING iv_keyword    TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_useless_cont IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid Redundant CONTINUE at End of Loop'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-useless_continue
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'CONTINUE immediately before loop end is redundant'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_continue
                                                                short_text = 'Remove redundant CONTINUE' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx      TYPE i.
    DATA ls_next     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'CONTINUE'.
        CONTINUE.
      ENDIF.

      ls_next = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                          iv_current_index = lv_idx ).
      IF is_loop_end_keyword( ls_next-keyword ) = abap_true.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_continue
                                        iv_statement_from = lv_idx
                                        it_new_code       = VALUE #( ) ).

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-useless_continue
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_loop_end_keyword.
    rv_yes = abap_false.
    IF    iv_keyword = 'ENDLOOP'
       OR iv_keyword = 'ENDWHILE'
       OR iv_keyword = 'ENDDO'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
