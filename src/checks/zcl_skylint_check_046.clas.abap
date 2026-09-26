CLASS zcl_skylint_check_046 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        local_tables TYPE if_ci_atc_check=>ty_finding_code VALUE 'LOCALTAB',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LOCAL_TABLES'.

ENDCLASS.


CLASS zcl_skylint_check_046 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
      VALUE #( description       = 'Avoid local TABLES declaration'
               remote_enablement = abap_true
               finding_codes     = VALUE #(
                   ( code           = c_finding_codes-local_tables
                     severity       = if_ci_atc_check=>finding_severities-warning
                     text           = 'TABLES declaration is obsolete; use explicit local structures'
                     pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'TABLES'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-local_tables ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
