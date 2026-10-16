CLASS zcl_skylint_no_empty_block DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_control_block TYPE if_ci_atc_check=>ty_finding_code VALUE 'EMPTYCTRL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EMPTY_BLOCK'.
    DATA mv_check_if    TYPE abap_bool VALUE abap_true.
    DATA mv_check_loop  TYPE abap_bool VALUE abap_true.
    DATA mv_check_case  TYPE abap_bool VALUE abap_true.
    DATA mv_check_try   TYPE abap_bool VALUE abap_true.
    DATA mv_check_do    TYPE abap_bool VALUE abap_true.
    DATA mv_check_while TYPE abap_bool VALUE abap_true.

    METHODS is_empty_control_block
      IMPORTING iv_current_kw TYPE string
                iv_next_kw    TYPE string
      RETURNING VALUE(rv_is)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_empty_block IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect empty control blocks (IF, CASE, LOOP, TRY, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-empty_control_block
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Empty control block detected; remove redundant control statement'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_IF'
                                                                value = REF #( mv_check_if ) )
                                                              ( name  = 'CHECK_LOOP'
                                                                value = REF #( mv_check_loop ) )
                                                              ( name  = 'CHECK_CASE'
                                                                value = REF #( mv_check_case ) )
                                                              ( name  = 'CHECK_TRY'
                                                                value = REF #( mv_check_try ) )
                                                              ( name  = 'CHECK_DO'
                                                                value = REF #( mv_check_do ) )
                                                              ( name  = 'CHECK_WHILE'
                                                                value = REF #( mv_check_while ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'ELSE'.
          IF mv_check_if = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'LOOP'.
          IF mv_check_loop = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'CASE' OR 'WHEN'.
          IF mv_check_case = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'TRY'.
          IF mv_check_try = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'DO'.
          IF mv_check_do = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'WHILE'.
          IF mv_check_while = abap_false.
            CONTINUE.
          ENDIF.
      ENDCASE.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = sy-tabix ).
      IF     ls_next_stmt-keyword IS NOT INITIAL
         AND is_empty_control_block( iv_current_kw = <ls_statement>-keyword
                                     iv_next_kw    = ls_next_stmt-keyword )  = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-empty_control_block ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_empty_control_block.
    rv_is = abap_false.

    CASE iv_current_kw.
      WHEN 'IF' OR 'ELSEIF'.
        IF iv_next_kw = 'ENDIF' OR iv_next_kw = 'ELSEIF' OR iv_next_kw = 'ELSE'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'ELSE'.
        IF iv_next_kw = 'ENDIF'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'LOOP'.
        IF iv_next_kw = 'ENDLOOP'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'DO'.
        IF iv_next_kw = 'ENDDO'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'WHILE'.
        IF iv_next_kw = 'ENDWHILE'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'TRY'.
        IF iv_next_kw = 'CATCH' OR iv_next_kw = 'CLEANUP' OR iv_next_kw = 'ENDTRY'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'CASE'.
        IF iv_next_kw = 'ENDCASE'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'WHEN'.
        IF iv_next_kw = 'WHEN' OR iv_next_kw = 'ENDCASE'.
          rv_is = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
