CLASS zcl_skylint_no_useless_cont DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        useless_continue TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_USE_CNT',
      END OF c_finding_codes.

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
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx  TYPE i.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CONTINUE'.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.
      ls_next = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                          iv_current_index = lv_idx ).
      IF is_loop_end_keyword( ls_next-keyword ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-useless_continue ).
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
