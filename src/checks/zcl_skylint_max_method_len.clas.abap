CLASS zcl_skylint_max_method_len DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        method_length     TYPE if_ci_atc_check=>ty_finding_code VALUE 'METHOD_LEN',
        constructor_logic TYPE if_ci_atc_check=>ty_finding_code VALUE 'CTOR_LOGIC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment      TYPE string VALUE 'METHOD_LEN'.
    CONSTANTS c_pseudo_comment_ctor TYPE string VALUE 'CLEAN_CTOR'.

    DATA mv_max_statements      TYPE i VALUE 5.
    DATA mv_max_ctor_statements TYPE i VALUE 10.

ENDCLASS.


CLASS zcl_skylint_max_method_len IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Method and Constructor Length Limits'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-method_length
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Method length exceeds maximum allowed statement limit'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-constructor_logic
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid heavy business logic/loops in constructor; use injection only'
                       pseudo_comment = c_pseudo_comment_ctor ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_STATEMENTS'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_statements ) )
                     ( name  = 'MAX_CTOR_STATEMENTS'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_ctor_statements ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_count      TYPE i.
    DATA lv_total      TYPE i.
    DATA lv_stmt_count TYPE i.
    DATA ls_first      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_last       TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-name CP '*=>CONSTRUCTOR' OR is_procedure-id-name = 'CONSTRUCTOR'.
      lv_stmt_count = 0.
      LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
        IF <ls_statement>-keyword = 'METHOD' OR <ls_statement>-keyword = 'ENDMETHOD'.
          CONTINUE.
        ENDIF.

        lv_stmt_count += 1.
        IF lv_stmt_count > mv_max_ctor_statements.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-constructor_logic ).
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

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
