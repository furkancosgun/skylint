CLASS zcl_skylint_max_method_len DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        method_length     TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_METH_L',
        constructor_logic TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_CTOR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment      TYPE string VALUE 'MAX_METHOD_LEN'.
    CONSTANTS c_pseudo_comment_ctor TYPE string VALUE 'MAX_CTOR_LOGIC'.

    DATA mv_max_statements      TYPE i VALUE 5.
    DATA mv_max_ctor_statements TYPE i VALUE 10.

ENDCLASS.


CLASS zcl_skylint_max_method_len IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Method and Constructor Length Limits'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-method_length
                       text           = 'Method length exceeds maximum allowed statement limit'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-constructor_logic
                       text           = 'Avoid heavy business logic/loops in constructor; use injection only'
                       pseudo_comment = c_pseudo_comment_ctor ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                              ( name  = 'MAX_STATEMENTS'
                                                value = REF #( mv_max_statements ) )
                                              ( name  = 'MAX_CTOR_STATEMENTS'
                                                value = REF #( mv_max_ctor_statements ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_total      TYPE i.
    DATA lv_stmt_count TYPE i.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ASSIGN is_procedure-statements[ 1 ] TO <ls_statement>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_total = lines( is_procedure-statements ).
    lv_stmt_count = lv_total - 2.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-method
       AND ( is_procedure-id-name CP '*=>CONSTRUCTOR' OR is_procedure-id-name = 'CONSTRUCTOR' ).
      IF lv_stmt_count > mv_max_ctor_statements.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-constructor_logic ).
      ENDIF.
    ELSEIF lv_stmt_count > mv_max_statements.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-method_length ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
