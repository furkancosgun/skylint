CLASS zcl_skylint_check_043 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_based_exceptions TYPE zif_skylint_types=>ty_finding_code VALUE 'CLASS_EXC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS has_classic_exceptions
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_043 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer Class-Based Exceptions over Classic EXCEPTIONS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-class_based_exceptions
                       severity = zif_skylint_types=>severities-warning
                       text     = 'Prefer class-based exceptions (RAISING) over classic EXCEPTIONS' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF has_classic_exceptions( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-class_based_exceptions ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_classic_exceptions.
    DATA ls_tok TYPE zif_skylint_types=>ty_token.

    rv_res = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      IF to_upper( ls_tok-lexeme ) = 'EXCEPTIONS' AND ls_tok-references IS INITIAL.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
