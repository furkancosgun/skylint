CLASS zcl_skylint_check_068 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        full_modify TYPE zif_skylint_types=>ty_finding_code VALUE 'FULL_MODIF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_FULL_MODIFY'.
ENDCLASS.


CLASS zcl_skylint_check_068 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-full_modify
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Specify TRANSPORTING fields in MODIFY itab inside loop for performance'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_loop          TYPE i VALUE 0.
    DATA lv_has_transporting TYPE abap_bool.
    DATA lv_is_itab_modify   TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP'.
          lv_in_loop = lv_in_loop + 1.

        WHEN 'ENDLOOP'.
          IF lv_in_loop > 0.
            lv_in_loop = lv_in_loop - 1.
          ENDIF.

        WHEN 'MODIFY'.
          IF lv_in_loop > 0.
            lv_has_transporting = abap_false.
            lv_is_itab_modify = abap_false.

            LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
              IF to_upper( <ls_token>-lexeme ) = 'TRANSPORTING'.
                lv_has_transporting = abap_true.
              ENDIF.
              IF to_upper( <ls_token>-lexeme ) = 'FROM' OR to_upper( <ls_token>-lexeme ) = 'INDEX'.
                lv_is_itab_modify = abap_true.
              ENDIF.
            ENDLOOP.

            IF lv_is_itab_modify = abap_true AND lv_has_transporting = abap_false.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-full_modify ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
