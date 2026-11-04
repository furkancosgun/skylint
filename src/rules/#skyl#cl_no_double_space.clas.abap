CLASS /skyl/cl_no_double_space DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        double_space TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DBL_SPC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DOUBLE_SPACE'.

ENDCLASS.


CLASS /skyl/cl_no_double_space IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid consecutive whitespace between tokens on the same line'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-double_space
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Use exactly one space between tokens on the same line'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA ls_prev_token   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_curr_token   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_expected_col TYPE i.
    DATA lv_idx          TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CLEAR ls_prev_token.

      LOOP AT <ls_statement>-tokens INTO ls_curr_token.
        lv_idx = sy-tabix.
        IF lv_idx = 1.
          ls_prev_token = ls_curr_token.
          CONTINUE.
        ENDIF.

        IF ls_curr_token-position-line = ls_prev_token-position-line.
          lv_expected_col = ls_prev_token-position-column + strlen( ls_prev_token-lexeme ) + 1.
          IF ls_curr_token-position-column > lv_expected_col.
            report_token( is_statement    = <ls_statement>
                          is_token        = ls_curr_token
                          iv_finding_code = c_finding_codes-double_space ).
            EXIT.
          ENDIF.
        ENDIF.

        ls_prev_token = ls_curr_token.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
