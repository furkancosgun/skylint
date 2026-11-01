CLASS zcl_skylint_max_sql_joins DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        max_joins TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_SQLJN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_SQL_JOINS'.

    DATA mv_max_joins TYPE i VALUE 4.

ENDCLASS.


CLASS zcl_skylint_max_sql_joins IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit number of JOINs in OpenSQL queries'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-max_joins
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Too many table JOINs in SQL query; consider CDS View or query decomposition'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_JOINS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_joins ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_joins TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      lv_joins = 0.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token> WHERE lexeme = 'JOIN'.
        IF <ls_token>-references IS INITIAL.
          lv_joins += 1.
        ENDIF.
      ENDLOOP.

      IF lv_joins > mv_max_joins.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-max_joins ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
