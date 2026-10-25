CLASS zcl_skylint_pref_class_exc DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_based_exceptions TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CLEXC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CLASS_EXC'.

    METHODS has_classic_exceptions
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_class_exc IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer Class-Based Exceptions over Classic EXCEPTIONS'
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

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.
      IF has_classic_exceptions( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-class_based_exceptions ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_classic_exceptions.
    rv_res = zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'EXCEPTIONS' ).
  ENDMETHOD.
ENDCLASS.
