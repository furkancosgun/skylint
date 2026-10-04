CLASS zcl_skylint_check_051 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_insert TYPE zif_skylint_types=>ty_finding_code VALUE 'PREF_INSRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_051 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer INSERT ... INTO TABLE over APPEND for table safety'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #( ( code     = c_finding_codes-prefer_insert
                                                                severity = zif_skylint_types=>severities-warning
                                                                text     = 'Prefer INSERT ... INTO TABLE over APPEND' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'APPEND'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_insert ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
