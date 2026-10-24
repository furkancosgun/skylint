CLASS zcl_skylint_no_rfc_err DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        rfc_error TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RFC_ERR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RFC_ERR'.

    METHODS has_exception
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_exc_name   TYPE string
                iv_exc_idx    TYPE i
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_rfc_err IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'RFC calls must handle system failures'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-rfc_error
                                       severity       = if_ci_atc_check=>finding_severities-error
                                       text           = 'RFC call must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_is_rfc   TYPE abap_bool.
    DATA lv_is_group TYPE abap_bool.
    DATA lv_exc_idx  TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'CALL'.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_stmt>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `FUNCTION` ) ) ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_is_rfc = xsdbool(    zcl_skylint_ast_util=>find_token( is_statement = <ls_stmt>
                                                                iv_lexeme    = 'DESTINATION' ) > 0
                           OR zcl_skylint_ast_util=>find_token( is_statement = <ls_stmt>
                                                                iv_lexeme    = 'STARTING' )    > 0 ).
      IF lv_is_rfc = abap_false.
        CONTINUE.
      ENDIF.

      lv_is_group = xsdbool( zcl_skylint_ast_util=>match_token_sequence(
                                 is_statement = <ls_stmt>
                                 it_expected  = VALUE #( ( `IN` ) ( `GROUP` ) ) ) = abap_true ).

      lv_exc_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_stmt>
                                                     iv_lexeme    = 'EXCEPTIONS' ).

      IF    lv_exc_idx = 0
         OR has_exception( is_statement = <ls_stmt>
                           iv_exc_name  = 'SYSTEM_FAILURE'
                           iv_exc_idx   = lv_exc_idx )            = abap_false
         OR has_exception( is_statement = <ls_stmt>
                           iv_exc_name  = 'COMMUNICATION_FAILURE'
                           iv_exc_idx   = lv_exc_idx )            = abap_false
         OR (     lv_is_group = abap_true
              AND has_exception( is_statement = <ls_stmt>
                                 iv_exc_name  = 'RESOURCE_FAILURE'
                                 iv_exc_idx   = lv_exc_idx )       = abap_false ).

        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-rfc_error ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD has_exception.
    rv_has = xsdbool( zcl_skylint_ast_util=>find_token( is_statement   = is_statement
                                                        iv_lexeme      = iv_exc_name
                                                        iv_start_index = iv_exc_idx ) > 0 ).
  ENDMETHOD.
ENDCLASS.
