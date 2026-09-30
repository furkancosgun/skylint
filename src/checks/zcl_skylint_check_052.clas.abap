CLASS zcl_skylint_check_052 DEFINITION
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


CLASS zcl_skylint_check_052 IMPLEMENTATION.
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

    "TODO hypnated keywordler ayrı ayrı gelmez SYNTAX-CHECK gibi
    "TODO matches token at yerine match_token_sequence kullan olabildiğince peş peşe gelen keywordlerde
    IF ( matches_token_at( is_statement = is_statement
                           iv_index = 1
                           iv_expected = `SYNTAX` ) = abap_true
         AND matches_token_at( is_statement = is_statement
                               iv_index = 2
                               iv_expected = `CHECK` ) = abap_true )
        OR ( matches_token_at( is_statement = is_statement
                               iv_index = 1
                               iv_expected = `SYSTEM` ) = abap_true
         AND matches_token_at( is_statement = is_statement
                               iv_index = 2
                               iv_expected = `CALL` ) = abap_true )
        OR ( matches_token_at( is_statement = is_statement
                               iv_index = 1
                               iv_expected = `GENERATE` ) = abap_true
         AND matches_token_at( is_statement = is_statement
                               iv_index = 2
                               iv_expected = `SUBROUTINE` ) = abap_true )
        OR ( matches_token_at( is_statement = is_statement
                               iv_index = 1
                               iv_expected = `INSERT` ) = abap_true
         AND matches_token_at( is_statement = is_statement
                               iv_index = 2
                               iv_expected = `REPORT` ) = abap_true )
        OR ( matches_token_at( is_statement = is_statement
                               iv_index = 1
                               iv_expected = `DELETE` ) = abap_true
         AND matches_token_at( is_statement = is_statement
                               iv_index = 2
                               iv_expected = `REPORT` ) = abap_true )
        OR ( matches_token_at( is_statement = is_statement
                               iv_index = 1
                               iv_expected = `READ` ) = abap_true
         AND matches_token_at( is_statement = is_statement
                               iv_index = 2
                               iv_expected = `REPORT` ) = abap_true ).
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
