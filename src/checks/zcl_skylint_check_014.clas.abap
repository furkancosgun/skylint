CLASS zcl_skylint_check_014 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_control_block TYPE zif_skylint_types=>ty_finding_code VALUE 'EMPTYCTRL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EMPTY_CONTROL_BLOCK'.

    METHODS is_empty_control_block
      IMPORTING iv_current_kw TYPE string
                iv_next_kw    TYPE string
      RETURNING VALUE(rv_is)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_014 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect empty control blocks (IF, CASE, LOOP, TRY, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-empty_control_block
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Empty control block detected; remove redundant control statement'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_next_stmt TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_code_block-statements
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
