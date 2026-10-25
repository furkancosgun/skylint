CLASS zcl_skylint_max_params DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_parameters TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAMCOUNT',
        multiple_params     TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAM_LINE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment      TYPE string VALUE 'MAX_PARAMS'.
    CONSTANTS c_pseudo_comment_line TYPE string VALUE 'MAX_PARAM_LINE'.

    DATA mv_max_parameters   TYPE i         VALUE 8.
    DATA mv_check_param_line TYPE abap_bool VALUE abap_true.

    METHODS count_parameters
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

    METHODS has_multiple_params_per_line
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_max_params IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Method parameter limits (count and lines)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-too_many_parameters
                       text           = 'Method signature has too many parameters; consider grouping into structures'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-multiple_params
                       text           = 'Keep max one method parameter definition per line'
                       pseudo_comment = c_pseudo_comment_line ) )
                 attributes        = VALUE #( ( name  = 'MAX_PARAMETERS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_parameters ) )
                                              ( name  = 'CHECK_PARAM_LINE'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_check_param_line ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.

      IF count_parameters( <ls_statement> ) > mv_max_parameters.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-too_many_parameters ).
      ENDIF.

      IF mv_check_param_line = abap_true AND has_multiple_params_per_line( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-multiple_params ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_parameters.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_count = 0.
    LOOP AT is_statement-tokens INTO ls_tok WHERE references IS INITIAL.
      IF ls_tok-lexeme = 'TYPE' OR ls_tok-lexeme = 'LIKE'.
        rv_count += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_multiple_params_per_line.
    DATA lv_prev_line TYPE i VALUE 0.
    DATA lv_line      TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>
         WHERE references IS INITIAL.
      IF <ls_tok>-lexeme <> 'TYPE' AND <ls_tok>-lexeme <> 'LIKE'.
        CONTINUE.
      ENDIF.

      lv_line = <ls_tok>-position-line.
      IF lv_prev_line > 0 AND lv_line = lv_prev_line.
        rv_yes = abap_true.
        RETURN.
      ENDIF.

      lv_prev_line = lv_line.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
