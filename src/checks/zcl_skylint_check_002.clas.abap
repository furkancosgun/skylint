CLASS zcl_skylint_check_002 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        call_method TYPE zif_skylint_types=>ty_finding_code VALUE 'CALLMETHOD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CALL_METHOD'.

    METHODS is_dynamic_call
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_dynamic) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_check_002 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid static CALL METHOD statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-call_method
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Avoid static CALL METHOD; use functional method call instead'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CALL'.
      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) = abap_false.
        CONTINUE.
      ENDIF.

      IF is_dynamic_call( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-call_method ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dynamic_call.
    DATA ls_third TYPE zif_skylint_types=>ty_token.

    rv_dynamic = abap_false.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'PARAMETER-TABLE' ) = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'EXCEPTION-TABLE' ) = abap_true.
      rv_dynamic = abap_true.
      RETURN.
    ENDIF.

    ls_third = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 3 ).
    IF to_upper( ls_third-lexeme ) CP '(*)'.
      rv_dynamic = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
