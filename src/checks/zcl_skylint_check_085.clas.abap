CLASS zcl_skylint_check_085 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        client_spec TYPE if_ci_atc_check=>ty_finding_code VALUE 'CLIENT_SPEC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_CLIENT_SPEC'.
ENDCLASS.


CLASS zcl_skylint_check_085 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-client_spec
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid explicit client specification in ABAP SQL'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_prev_tok TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE    keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'MODIFY'
               OR keyword = 'DELETE' OR keyword = 'INSERT'.
      CLEAR lv_prev_tok.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF    ( lv_prev_tok = 'USING'  AND to_upper( <ls_token>-lexeme ) = 'CLIENT' )
           OR ( lv_prev_tok = 'CLIENT' AND to_upper( <ls_token>-lexeme ) = 'SPECIFIED' ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-client_spec ).
          EXIT.
        ENDIF.
        lv_prev_tok = to_upper( <ls_token>-lexeme ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
