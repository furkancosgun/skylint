CLASS zcl_skylint_check_017 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_catch TYPE if_ci_atc_check=>ty_finding_code VALUE 'EMPTYCATCH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_HANDLER'.

    METHODS is_empty_catch
      IMPORTING
        iv_next_kw   TYPE string
      RETURNING
        VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_017 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect empty CATCH blocks swallowing exceptions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-empty_catch
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Empty CATCH block swallowing exception; handle, log or re-raise'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_total    TYPE i.
    DATA lv_idx      TYPE i.
    DATA lv_next_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = lines( is_procedure-statements ).

    DO lv_total TIMES.
      lv_idx = sy-index.
      READ TABLE is_procedure-statements ASSIGNING <ls_statement> INDEX lv_idx.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      IF <ls_statement>-keyword = 'CATCH'.
        lv_next_idx = lv_idx + 1.
        IF lv_next_idx <= lv_total.
          READ TABLE is_procedure-statements ASSIGNING <ls_next_stmt> INDEX lv_next_idx.
          IF sy-subrc = 0.
            IF is_empty_catch( <ls_next_stmt>-keyword ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-empty_catch ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD is_empty_catch.
    rv_is = abap_false.

    CASE iv_next_kw.
      WHEN 'CATCH' OR 'CLEANUP' OR 'ENDTRY' OR 'ENDCATCH'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
