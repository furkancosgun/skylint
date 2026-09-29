CLASS zcl_skylint_check_052 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_returning TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFER_RET',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_RETURNING'.

    METHODS is_single_exporting_only
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_052 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer RETURNING over single EXPORTING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_returning
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer functional RETURNING parameter over single EXPORTING parameter'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF is_single_exporting_only( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_returning ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_single_exporting_only.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex       TYPE string.
    DATA lv_mode      TYPE string.
    DATA lv_exp_count TYPE i.
    DATA lv_chg_count TYPE i.
    DATA lv_ret_count TYPE i.

    rv_res = abap_false.
    lv_mode = ''.
    lv_exp_count = 0.
    lv_chg_count = 0.
    lv_ret_count = 0.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).

      IF lv_lex = 'FOR' OR lv_lex = 'EVENT' OR lv_lex = 'REDEFINITION'.
        RETURN.
      ENDIF.

      CASE lv_lex.
        WHEN 'IMPORTING'.
          lv_mode = 'IMPORTING'.
        WHEN 'EXPORTING'.
          lv_mode = 'EXPORTING'.
        WHEN 'CHANGING'.
          lv_mode = 'CHANGING'.
        WHEN 'RETURNING'.
          lv_mode = 'RETURNING'.
        WHEN 'RAISING' OR 'EXCEPTIONS'.
          lv_mode = ''.
        WHEN 'TYPE' OR 'LIKE'.
          CASE lv_mode.
            WHEN 'EXPORTING'.
              lv_exp_count += 1.
            WHEN 'CHANGING'.
              lv_chg_count += 1.
            WHEN 'RETURNING'.
              lv_ret_count += 1.
          ENDCASE.
      ENDCASE.
    ENDLOOP.

    IF lv_exp_count = 1 AND lv_chg_count = 0 AND lv_ret_count = 0.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
