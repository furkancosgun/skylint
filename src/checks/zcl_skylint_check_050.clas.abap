CLASS zcl_skylint_check_050 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        multiple_output_params TYPE if_ci_atc_check=>ty_finding_code VALUE 'OUT_PARAM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OUTPUT_PARAMS'.

    DATA mv_max_output_params TYPE i VALUE 1.

    METHODS count_output_parameters
      IMPORTING
        is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_skylint_check_050 IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid Multiple Output Parameters (prefer single RETURNING)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-multiple_output_params
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Method has multiple output parameters; prefer single RETURNING'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_OUTPUT_PARAMS'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_output_params ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_OUTPUT_PARAMS'
                   IMPORTING ev_value = lv_max ).
    IF lv_max <= 0.
      lv_max = mv_max_output_params.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF count_output_parameters( <ls_statement> ) > lv_max.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-multiple_output_params ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_output_parameters.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex TYPE string.
    DATA lv_mode TYPE string.

    rv_count = 0.
    lv_mode = ''.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).

      CASE lv_lex.
        WHEN 'IMPORTING'.
          lv_mode = 'IMPORTING'.
        WHEN 'EXPORTING'.
          lv_mode = 'EXPORTING'.
        WHEN 'CHANGING'.
          lv_mode = 'CHANGING'.
        WHEN 'RETURNING'.
          lv_mode = 'RETURNING'.
        WHEN 'RAISING' OR 'EXCEPTIONS' OR 'FOR' OR 'REDEFINITION'.
          lv_mode = ''.
        WHEN 'TYPE' OR 'LIKE'.
          IF lv_mode = 'EXPORTING' OR lv_mode = 'CHANGING' OR lv_mode = 'RETURNING'.
            rv_count = rv_count + 1.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
