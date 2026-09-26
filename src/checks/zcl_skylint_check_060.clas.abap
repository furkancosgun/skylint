CLASS zcl_skylint_check_060 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_shortdump TYPE if_ci_atc_check=>ty_finding_code VALUE 'SHORTDUMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_SHORTDUMP'.

    METHODS is_raise_shortdump
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_060 IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid RAISE SHORTDUMP (prefer graceful exceptions)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-raise_shortdump
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'RAISE'.
      IF is_raise_shortdump( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-raise_shortdump ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_shortdump.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    IF lines( is_statement-tokens ) >= 2.
      READ TABLE is_statement-tokens INDEX 2 INTO ls_tok2.
      IF sy-subrc = 0 AND to_upper( ls_tok2-lexeme ) = 'SHORTDUMP'.
        rv_res = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
