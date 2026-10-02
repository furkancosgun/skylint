CLASS zcl_skylint_check_066 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        client_spec TYPE zif_skylint_types=>ty_finding_code VALUE 'CLIENT_SPEC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_CLIENT_SPEC'.
ENDCLASS.


CLASS zcl_skylint_check_066 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-client_spec
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Avoid explicit client specification in ABAP SQL'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE    keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'MODIFY'
               OR keyword = 'DELETE' OR keyword = 'INSERT'.
      IF    zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                       it_expected  = VALUE #( ( `USING` ) ( `CLIENT` ) ) )     > 0
         OR zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                       it_expected  = VALUE #( ( `CLIENT` ) ( `SPECIFIED` ) ) ) > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-client_spec ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
