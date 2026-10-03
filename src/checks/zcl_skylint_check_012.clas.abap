CLASS zcl_skylint_check_012 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        exit_outside_loop TYPE zif_skylint_types=>ty_finding_code VALUE 'EXITOUTLP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EXIT_OUTSIDE_LOOP'.

ENDCLASS.


CLASS zcl_skylint_check_012 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer RETURN over EXIT outside loop constructs'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-exit_outside_loop
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Use RETURN instead of EXIT when leaving a procedure'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    lv_loop_depth = 0.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth = lv_loop_depth + 1.

        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_loop_depth > 0.
            lv_loop_depth = lv_loop_depth - 1.
          ENDIF.

        WHEN 'EXIT'.
          IF lv_loop_depth = 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-exit_outside_loop ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
