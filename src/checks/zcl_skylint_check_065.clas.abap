CLASS zcl_skylint_check_065 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_form TYPE zif_skylint_types=>ty_finding_code VALUE 'AVOID_FORM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_FORM_ROUTINE'.
ENDCLASS.


CLASS zcl_skylint_check_065 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid obsolete FORM routines; use modern methods in ABAP Cloud'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-avoid_form
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Avoid obsolete FORM/PERFORM subroutines; use methods instead'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'PERFORM' OR keyword = 'FORM'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-avoid_form ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
