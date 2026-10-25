CLASS zcl_skylint_no_select_star DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        select_star TYPE if_ci_atc_check=>ty_finding_code VALUE 'SELECTSTAR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SELECT_STAR'.

    METHODS is_select_star
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_select_star IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Avoid SELECT * (specify columns explicitly)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-select_star
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid SELECT *; specify required columns explicitly'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'SELECT' AND is_select_star( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-select_star ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_select_star.
    DATA lv_paren_depth TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-references IS INITIAL.
        CASE <ls_token>-lexeme.
          WHEN '('.
            lv_paren_depth += 1.
          WHEN ')'.
            IF lv_paren_depth > 0.
              lv_paren_depth -= 1.
            ENDIF.
          WHEN 'FROM'.
            IF lv_paren_depth = 0.
              EXIT.
            ENDIF.
        ENDCASE.
      ENDIF.

      IF lv_paren_depth = 0 AND ( <ls_token>-lexeme = '*' OR <ls_token>-lexeme CP '*~#**' ).
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
