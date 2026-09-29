CLASS zcl_skylint_check_094 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        translate_stmt TYPE if_ci_atc_check=>ty_finding_code VALUE 'TRANSLATE_',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TRANSLATE_STMT'.
ENDCLASS.


CLASS zcl_skylint_check_094 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect TRANSLATE statement; suggest to_upper() / to_lower()'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-translate_stmt
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use modern string functions to_upper() or to_lower() instead of TRANSLATE'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'TRANSLATE'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-translate_stmt ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
