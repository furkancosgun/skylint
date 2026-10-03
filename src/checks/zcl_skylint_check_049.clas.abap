CLASS zcl_skylint_check_049 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_shortdump TYPE zif_skylint_types=>ty_finding_code VALUE 'SHORTDUMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_SHORTDUMP'.

    METHODS is_raise_shortdump
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_049 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Avoid RAISE SHORTDUMP (prefer graceful exceptions)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-raise_shortdump
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'RAISE'.
      IF is_raise_shortdump( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-raise_shortdump ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_shortdump.
    rv_res = abap_false.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = `SHORTDUMP` ) = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
