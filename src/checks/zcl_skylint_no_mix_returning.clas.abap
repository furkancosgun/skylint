CLASS zcl_skylint_no_mix_returning DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        mix_returning TYPE if_ci_atc_check=>ty_finding_code VALUE 'MIX_RET',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_MIX_RETURNING'.

    METHODS is_mix_returning
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_mix_returning IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Do not mix RETURNING with EXPORTING or CHANGING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-mix_returning
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Do not mix RETURNING with EXPORTING or CHANGING parameters in a single method'
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
      IF is_mix_returning( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-mix_returning ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_mix_returning.
    rv_yes = abap_false.

    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'RETURNING' ) = abap_false.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'EXPORTING' ) = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'CHANGING' )  = abap_true.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
