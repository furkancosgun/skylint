CLASS zcl_skylint_check_051 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_based_exceptions TYPE if_ci_atc_check=>ty_finding_code VALUE 'CLASS_EXC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CLASS_EXCEPTIONS'.

    METHODS has_classic_exceptions
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_051 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer Class-Based Exceptions over Classic EXCEPTIONS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-class_based_exceptions
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer class-based exceptions (RAISING) over classic EXCEPTIONS'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF has_classic_exceptions( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-class_based_exceptions ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_classic_exceptions.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      IF to_upper( ls_tok-lexeme ) = 'EXCEPTIONS'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
