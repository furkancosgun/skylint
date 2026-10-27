CLASS zcl_skylint_no_dummy_auth DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dummy_check TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUMMY_A',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DUMMY_AUTH'.

    METHODS find_dummy_token
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_idx) TYPE i.

ENDCLASS.


CLASS zcl_skylint_no_dummy_auth IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid AUTHORITY-CHECK with the DUMMY addition'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-dummy_check
                       severity       = if_ci_atc_check=>finding_severities-error
                       text           = 'AUTHORITY-CHECK DUMMY never checks the field; supply FIELD and evaluate sy-subrc'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'AUTHORITY-CHECK'.
        CONTINUE.
      ENDIF.
      IF zcl_skylint_ast_util=>match_token_sequence(
             is_statement = <ls_statement>
             it_expected  = VALUE #( ( `AUTHORITY-CHECK` ) ( `OBJECT` ) ) ) = abap_false.
        CONTINUE.
      ENDIF.
      IF find_dummy_token( <ls_statement> ) = 0.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-dummy_check ).
    ENDLOOP.
  ENDMETHOD.

  METHOD find_dummy_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_idx = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                 iv_lexeme = 'DUMMY' ) = abap_true.
        rv_idx = sy-tabix.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
