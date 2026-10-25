CLASS zcl_skylint_max_returns DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_returns TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_RETURN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_RETURNS'.

    DATA mv_max_returns TYPE i VALUE 6.

ENDCLASS.


CLASS zcl_skylint_max_returns IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Limit number of RETURN statements (PLR0911)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-too_many_returns
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Method has too many RETURN statements; consider refactoring'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                     ( name  = 'MAX_RETURNS'
                                       value = REF #( mv_max_returns ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_returns_count TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_returns_count = 0.
    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword = 'RETURN'.
        lv_returns_count += 1.
      ENDIF.
    ENDLOOP.

    IF lv_returns_count > mv_max_returns.
      ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = 1 ).
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-too_many_returns ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
