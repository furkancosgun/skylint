CLASS zcl_skylint_check_002 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        call_method TYPE if_ci_atc_check=>ty_finding_code VALUE 'CALLMETHOD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CALL_METHOD'.

    DATA mv_allow_dynamic TYPE abap_bool VALUE abap_true.

    METHODS is_dynamic_call
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_dynamic) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_002 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid static CALL METHOD statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-call_method
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid static CALL METHOD; use functional method call instead'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'ALLOW_DYNAMIC'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_allow_dynamic ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_allow_dyn TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'ALLOW_DYNAMIC'
                   IMPORTING ev_value = lv_allow_dyn ).

    "TODO: SONUC OLMAMASI DA BIR SONUCTUR allow_dynamic false ise bostur bu dogru degil gibi if gereksiz
    IF lv_allow_dyn IS INITIAL.
      lv_allow_dyn = mv_allow_dynamic.
    ENDIF.

    "TODO: COMPILER seviyesinde bur bir fonksion cagrisi mi diye bakalim daha basit match_token_sequence gayey iyi
    "allow dynamic daha duzgun yazilabilir
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CALL'.
      IF match_token_sequence( is_statement = <ls_statement>
                               it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) = abap_false.
        CONTINUE.
      ENDIF.

      IF lv_allow_dyn = abap_true AND is_dynamic_call( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-call_method ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dynamic_call.
    DATA lv_token_idx TYPE i.
    DATA lv_lexeme    TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_dynamic = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_token_idx = sy-tabix.
      lv_lexeme = to_upper( <ls_token>-lexeme ).

      IF lv_lexeme = 'PARAMETER-TABLE' OR lv_lexeme = 'EXCEPTION-TABLE'.
        rv_dynamic = abap_true.
        RETURN.
      ENDIF.

      IF lv_token_idx = 3 AND ( lv_lexeme CP '(*' OR lv_lexeme CP '*->(*' OR lv_lexeme CP '*=>(*' ).
        rv_dynamic = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
