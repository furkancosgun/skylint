CLASS zcl_skylint_no_unnec_return DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unnecessary_return TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_UNN_RET',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_return TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REMOVE_RET',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_UNNEC_RETURN'.

ENDCLASS.


CLASS zcl_skylint_no_unnec_return IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Omit unnecessary RETURN at end of routine'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unnecessary_return
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit optional RETURN at end of routine; routines return automatically'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_return
                                                short_text = 'Remove unnecessary RETURN' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword = 'RETURN' AND sy-tabix = lines( is_procedure-statements ) - 1.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_return
                                        iv_statement_from = sy-tabix
                                        it_new_code       = VALUE #( ) ).
        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-unnecessary_return
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
