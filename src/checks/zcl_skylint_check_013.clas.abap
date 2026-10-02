CLASS zcl_skylint_check_013 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_in_loop TYPE zif_skylint_types=>ty_finding_code VALUE 'CHKINLOOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHECK_IN_LOOP'.

ENDCLASS.


CLASS zcl_skylint_check_013 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-check_in_loop
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Avoid CHECK inside loop; use IF ... CONTINUE instead'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    lv_loop_depth = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth = lv_loop_depth + 1.

        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_loop_depth > 0.
            lv_loop_depth = lv_loop_depth - 1.
          ENDIF.

        WHEN 'CHECK'.
          IF lv_loop_depth > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-check_in_loop ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
