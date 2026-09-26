CLASS zcl_skylint_check_018 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_assert TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOASSERT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MISSING_ASSERT'.

    METHODS has_assertion
      IMPORTING
        is_procedure  TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_018 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect unit test methods missing assertions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-missing_assert
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Test method contains no assertion verification (cl_abap_unit_assert)'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_proc_name TYPE string.
    FIELD-SYMBOLS <ls_first_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-method.
      RETURN.
    ENDIF.

    lv_proc_name = to_upper( is_procedure-id-name ).
    IF lv_proc_name NP 'TEST*' AND lv_proc_name NP '*TEST*' AND lv_proc_name NP 'WITHOUT*' AND lv_proc_name NP 'WITH*'.
      RETURN.
    ENDIF.

    READ TABLE is_procedure-statements ASSIGNING <ls_first_stmt> INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF has_assertion( is_procedure ) = abap_false.
      report_statement( is_statement    = <ls_first_stmt>
                        iv_finding_code = c_finding_codes-missing_assert ).
    ENDIF.
  ENDMETHOD.

  METHOD has_assertion.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_lexeme = to_upper( <ls_token>-lexeme ).
        IF lv_lexeme CP '*ASSERT*' OR lv_lexeme CP '*FAIL*' OR lv_lexeme = 'ASSERT'.
          rv_has = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
