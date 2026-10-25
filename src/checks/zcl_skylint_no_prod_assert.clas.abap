CLASS zcl_skylint_no_prod_assert DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prod_assert TYPE if_ci_atc_check=>ty_finding_code VALUE 'PROD_ASSRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PROD_ASSERT'.

ENDCLASS.


CLASS zcl_skylint_no_prod_assert IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Native ASSERT in Production Logic'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prod_assert
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid native ASSERT in production logic; raise an exception instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'ASSERT'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prod_assert ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
