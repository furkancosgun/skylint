CLASS zcl_skylint_check_065 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        constructor_logic TYPE if_ci_atc_check=>ty_finding_code VALUE 'CTOR_LOGIC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CONSTRUCTOR_LOGIC'.

    DATA mv_max_statements TYPE i VALUE 10.

ENDCLASS.


CLASS zcl_skylint_check_065 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Keep constructors clean; avoid heavy business logic/loops/DB access'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-constructor_logic
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid heavy business logic/loops in constructor; use injection only'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_STATEMENTS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_statements ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_max_stmts  TYPE i.
    DATA lv_stmt_count TYPE i.

    IF     is_procedure-id-name NP '*CONSTRUCTOR*'
       AND is_procedure-id-name NP '*WITHOUT_PSEUDO_COMMENTS*'
       AND is_procedure-id-name NP '*WITH_PSEUDO_COMMENTS*'.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_STATEMENTS'
                   IMPORTING ev_value = lv_max_stmts ).

    IF lv_max_stmts <= 0.
      lv_max_stmts = mv_max_statements.
    ENDIF.

    lv_stmt_count = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      " Disallow heavy keywords directly
      IF    <ls_statement>-keyword = 'LOOP'          OR <ls_statement>-keyword = 'SELECT'
         OR <ls_statement>-keyword = 'CALL FUNCTION' OR <ls_statement>-keyword = 'SUBMIT'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-constructor_logic ).
        CONTINUE.
      ENDIF.

      " Count logic statements (excluding METHOD, ENDMETHOD, DATA, TYPES, STATICS, CONSTANTS)
      IF     <ls_statement>-keyword <> 'METHOD'  AND <ls_statement>-keyword <> 'ENDMETHOD'
         AND <ls_statement>-keyword <> 'DATA'    AND <ls_statement>-keyword <> 'TYPES'
         AND <ls_statement>-keyword <> 'STATICS' AND <ls_statement>-keyword <> 'CONSTANTS'.
        lv_stmt_count += 1.
        IF lv_stmt_count > lv_max_stmts.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-constructor_logic ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
