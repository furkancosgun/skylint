CLASS zcl_skylint_check_062 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_loop_control TYPE if_ci_atc_check=>ty_finding_code VALUE 'OBS_L_CTRL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_LOOP_CTRL'.

ENDCLASS.


CLASS zcl_skylint_check_062 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_loop_control
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete control statements in LOOP; use modern grouping'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_tok2 TYPE string.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SUM'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-obsolete_loop_control ).
        WHEN 'ON'.
          IF lines( <ls_statement>-tokens ) >= 2.
            ASSIGN <ls_statement>-tokens[ 2 ] TO <ls_token>.
            IF sy-subrc = 0 AND to_upper( <ls_token>-lexeme ) = 'CHANGE'.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-obsolete_loop_control ).
            ENDIF.
          ENDIF.
        WHEN 'AT'.
          IF lines( <ls_statement>-tokens ) >= 2.
            ASSIGN <ls_statement>-tokens[ 2 ] TO <ls_token>.
            IF sy-subrc = 0.
              lv_tok2 = to_upper( <ls_token>-lexeme ).
              IF lv_tok2 = 'NEW' OR lv_tok2 = 'END' OR lv_tok2 = 'FIRST' OR lv_tok2 = 'LAST'.
                report_statement( is_statement    = <ls_statement>
                                  iv_finding_code = c_finding_codes-obsolete_loop_control ).
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
