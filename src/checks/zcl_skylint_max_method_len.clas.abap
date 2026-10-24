CLASS zcl_skylint_max_method_len DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        method_length TYPE if_ci_atc_check=>ty_finding_code VALUE 'METHOD_LEN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'METHOD_LEN'.

    DATA mv_max_statements TYPE i VALUE 5.

ENDCLASS.


CLASS zcl_skylint_max_method_len IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Method Length Limit (excessive statement count)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-method_length
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Method length exceeds maximum allowed statement limit'
                                                pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_STATEMENTS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_statements ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_count TYPE i.
    DATA lv_total TYPE i.
    DATA ls_first TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_last  TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = lines( is_procedure-statements ).
    IF lv_total < 2.
      RETURN.
    ENDIF.

    ls_first = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = 1 ).
    ls_last  = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = lv_total ).

    IF     ls_first-keyword <> 'METHOD'
       AND ls_first-keyword <> 'FORM'
       AND ls_first-keyword <> 'FUNCTION'.
      RETURN.
    ENDIF.

    IF     ls_last-keyword <> 'ENDMETHOD'
       AND ls_last-keyword <> 'ENDFORM'
       AND ls_last-keyword <> 'ENDFUNCTION'.
      RETURN.
    ENDIF.

    lv_count = lv_total - 2.
    IF lv_count <= mv_max_statements.
      RETURN.
    ENDIF.

    report_statement( is_statement    = ls_first
                      iv_finding_code = c_finding_codes-method_length ).
  ENDMETHOD.
ENDCLASS.
