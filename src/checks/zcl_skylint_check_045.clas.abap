CLASS zcl_skylint_check_045 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_auth_check TYPE zif_skylint_types=>ty_finding_code VALUE 'AUTH_CHECK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CALL_TRANSACTION'.

    METHODS is_call_transaction
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS has_inline_auth_check
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_045 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Call Transaction Authority Check'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-missing_auth_check
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'CALL TRANSACTION must be protected with AUTHORITY-CHECK'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CALL'.
      IF     is_call_transaction( <ls_statement> )   = abap_true
         AND has_inline_auth_check( <ls_statement> ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-missing_auth_check ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_call_transaction.
    rv_res = xsdbool( zcl_skylint_ast_util=>find_token_sequence(
                          is_statement = is_statement
                          it_expected  = VALUE #( ( `CALL` ) ( `TRANSACTION` ) ) ) > 0 ).
  ENDMETHOD.

  METHOD has_inline_auth_check.
    rv_res = xsdbool( zcl_skylint_ast_util=>find_token_sequence(
                          is_statement = is_statement
                          it_expected  = VALUE #( ( `WITH` ) ( `AUTHORITY-CHECK` ) ) ) > 0 ).
  ENDMETHOD.
ENDCLASS.
