CLASS zcl_skylint_no_empty_proc DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_procedure TYPE if_ci_atc_check=>ty_finding_code VALUE 'EMPTY_PROC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EMPTY_PROC'.

    DATA mv_check_methods TYPE abap_bool VALUE abap_true.
    DATA mv_check_forms   TYPE abap_bool VALUE abap_true.
    DATA mv_check_funcs   TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_empty_proc IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid empty procedures (methods, forms, functions)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-empty_procedure
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Procedure is empty; implement logic or remove procedure'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                     ( name  = 'CHECK_METHODS'
                       value = REF #( mv_check_methods ) )
                     ( name  = 'CHECK_FORMS'
                       value = REF #( mv_check_forms ) )
                     ( name  = 'CHECK_FUNCS'
                       value = REF #( mv_check_funcs ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_is_checked TYPE abap_bool.

    lv_is_checked = abap_false.

    CASE is_procedure-id-kind.
      WHEN if_ci_atc_source_code_provider=>procedure_kinds-method.
        IF mv_check_methods = abap_true.
          lv_is_checked = abap_true.
        ENDIF.
      WHEN if_ci_atc_source_code_provider=>procedure_kinds-form_routine.
        IF mv_check_forms = abap_true.
          lv_is_checked = abap_true.
        ENDIF.
      WHEN if_ci_atc_source_code_provider=>procedure_kinds-function.
        IF mv_check_funcs = abap_true.
          lv_is_checked = abap_true.
        ENDIF.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    IF lv_is_checked = abap_false.
      RETURN.
    ENDIF.

    IF lines( is_procedure-statements ) <= 2.
      READ TABLE is_procedure-statements INDEX 1 INTO ls_first_stmt.
      IF sy-subrc = 0 AND ls_first_stmt-keyword IS NOT INITIAL.
        report_statement(
            is_statement    = ls_first_stmt
            iv_finding_code = c_finding_codes-empty_procedure ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
