CLASS zcl_skylint_check_044 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dangerous_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'DANGER_STM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DANGEROUS_STMT'.

    METHODS is_dangerous_statement
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_044 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Dangerous / Unmanaged Dynamic Statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-dangerous_statement
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Dangerous or unmanaged dynamic statement detected'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_dangerous_statement( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dangerous_statement.
    rv_res = abap_false.

    IF is_statement-keyword = 'SYNTAX-CHECK' OR is_statement-keyword = 'SYSTEM-CALL'.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                               it_expected  = VALUE #( ( `GENERATE` ) ( `SUBROUTINE` ) ) ) > 0
       OR zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                               it_expected  = VALUE #( ( `INSERT` ) ( `REPORT` ) ) ) > 0
       OR zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                               it_expected  = VALUE #( ( `DELETE` ) ( `REPORT` ) ) ) > 0
       OR zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                               it_expected  = VALUE #( ( `READ` ) ( `REPORT` ) ) ) > 0.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
