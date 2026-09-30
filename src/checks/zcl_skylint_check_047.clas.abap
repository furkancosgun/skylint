CLASS zcl_skylint_check_047 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'METHOD_LENGTH'.

    DATA mv_max_statements TYPE i VALUE 5.

ENDCLASS.


CLASS zcl_skylint_check_047 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Method Length Limit (excessive statement count)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-method_length
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Method length exceeds maximum allowed statement limit'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'MAX_STATEMENTS'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_max_statements ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max   TYPE i.
    DATA lv_count TYPE i.
    FIELD-SYMBOLS <ls_statement>  TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_first_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_STATEMENTS'
                   IMPORTING ev_value = lv_max ).
    IF lv_max <= 0.
      lv_max = mv_max_statements.
    ENDIF.

    lv_count = 0.
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword <> 'METHOD'
         AND <ls_statement>-keyword <> 'ENDMETHOD'
         AND <ls_statement>-keyword <> 'FORM'
         AND <ls_statement>-keyword <> 'ENDFORM'
         AND <ls_statement>-keyword <> 'FUNCTION'
         AND <ls_statement>-keyword <> 'ENDFUNCTION'.
        lv_count += 1.
      ENDIF.
    ENDLOOP.

    IF lv_count > lv_max.
      ASSIGN is_procedure-statements[ 1 ] TO <ls_first_stmt>.
      IF sy-subrc = 0.
        report_statement( is_statement    = <ls_first_stmt>
                          iv_finding_code = c_finding_codes-method_length ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
