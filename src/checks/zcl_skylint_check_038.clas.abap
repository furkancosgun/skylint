CLASS zcl_skylint_check_038 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_corresponding TYPE zif_skylint_types=>ty_finding_code VALUE 'PREFER_COR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_CORRESPONDING'.
ENDCLASS.


CLASS zcl_skylint_check_038 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer CORRESPONDING Expression over MOVE-CORRESPONDING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_corresponding
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Prefer functional CORRESPONDING #( ... ) over MOVE-CORRESPONDING'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'MOVE-CORRESPONDING'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_corresponding ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
