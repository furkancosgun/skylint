CLASS zcl_skylint_no_loop_into DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        loop_copy TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_LOOPIN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_LOOP_INTO'.

ENDCLASS.


CLASS zcl_skylint_no_loop_into IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer ASSIGNING over LOOP INTO copy targets'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-loop_copy
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Loop copies each row; use ASSIGNING with a field symbol'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      IF     zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'AT' )         = abap_true
         AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'INTO' )       = abap_true
         AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'ASSIGNING' )  = abap_false
         AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'REFERENCE' )  = abap_false.

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-loop_copy ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
