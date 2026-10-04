CLASS zcl_skylint_check_076 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prod_assert TYPE zif_skylint_types=>ty_finding_code VALUE 'PROD_ASSRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_076 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect native ASSERT in production code; use exceptions instead'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prod_assert
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid native ASSERT in production logic; raise an exception instead'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'ASSERT'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prod_assert ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
