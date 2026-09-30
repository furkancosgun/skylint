CLASS zcl_skylint_check_014 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EMPTY_CONTROL_BLOCK'.

    METHODS is_empty_control_block
      IMPORTING iv_current_kw TYPE string
                iv_next_kw    TYPE string
      RETURNING VALUE(rv_is)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_014 IMPLEMENTATION.
  METHOD constructor.
    "TODO: genel olarak basarili daha anlasilir ve compact yazilabilir
    "017 ile benziyor kontrol edelim ayrica if case loop try gibi yapilari parametrik yapalim
    "ayri ayri kullanici atc den secim yapabilsin
    super->constructor(
        VALUE #( description       = 'Detect empty control blocks (IF, CASE, LOOP, TRY, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-empty_control_block
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Empty control block detected; remove redundant control statement'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_total TYPE i.
    DATA lv_idx TYPE i.
    DATA lv_next_idx TYPE i.
    DATA ls_statement TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_found TYPE abap_bool.
    DATA lv_found_next TYPE abap_bool.

    lv_total = lines( is_procedure-statements ).

    DO lv_total TIMES.
      lv_idx = sy-index.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index       = lv_idx
                          IMPORTING es_statement   = ls_statement
                                    ev_found       = lv_found ).
      IF lv_found = abap_false.
        EXIT.
      ENDIF.

      lv_next_idx = lv_idx + 1.
      IF lv_next_idx <= lv_total.
        get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                      iv_index       = lv_next_idx
                            IMPORTING es_statement   = ls_next_stmt
                                      ev_found       = lv_found_next ).
        IF lv_found_next = abap_true.
          IF is_empty_control_block( iv_current_kw = ls_statement-keyword
                                     iv_next_kw    = ls_next_stmt-keyword ) = abap_true.
            report_statement( is_statement    = ls_statement
                              iv_finding_code = c_finding_codes-empty_control_block ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.
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
