CLASS zcl_skylint_param_one_line DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        multiple_params_on_line TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAM_1LIN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PARAM_ONE_LINE'.

    METHODS has_multiple_params_on_line
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_param_one_line IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Parameters and structure fields must be on separate lines'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-multiple_params_on_line
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Multiple parameters or fields on the same line; place each on a separate line'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF has_multiple_params_on_line( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-multiple_params_on_line ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_multiple_params_on_line.
    DATA lv_depth     TYPE i.
    DATA lv_last_line TYPE i.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    lv_depth = 0.
    lv_last_line = 0.

    LOOP AT is_statement-tokens INTO ls_token.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).

      IF lv_depth > 0 AND ls_token-lexeme = '='.
        IF lv_last_line = ls_token-position-line.
          rv_has = abap_true.
          RETURN.
        ENDIF.
        lv_last_line = ls_token-position-line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
