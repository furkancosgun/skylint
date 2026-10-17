CLASS zcl_skylint_slow_param_pass DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        slow_param_passing TYPE if_ci_atc_check=>ty_finding_code VALUE 'SLOW_PASS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SLOW_PARAM'.

ENDCLASS.


CLASS zcl_skylint_slow_param_pass IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Slow Parameter Passing'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-slow_param_passing
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid pass-by-value for importing method parameters'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_importing TYPE abap_bool.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>       TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.
      lv_in_importing = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_tok>.
        CASE <ls_tok>-lexeme.
          WHEN 'IMPORTING'.
            lv_in_importing = abap_true.
          WHEN 'EXPORTING' OR 'CHANGING' OR 'RETURNING' OR 'RAISING' OR 'EXCEPTIONS' OR 'FOR' OR 'REDEFINITION'.
            lv_in_importing = abap_false.
          WHEN OTHERS.
            IF lv_in_importing = abap_true AND <ls_tok>-lexeme CP 'VALUE(*)'.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-slow_param_passing ).
              EXIT.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
