CLASS zcl_skylint_pref_filter DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_filter TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FILTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_FILTER'.

    METHODS is_simple_filter
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_index      TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS parse_loop_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_source    TYPE string
                ev_work_area TYPE string
                ev_valid     TYPE abap_bool.

    METHODS parse_append_statement
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_source      TYPE string
                ev_destination TYPE string
                ev_valid       TYPE abap_bool.

    METHODS has_dynamic_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_filter IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer FILTER for simple LOOP/IF/APPEND'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_filter
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Replace the simple filter loop with FILTER'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      IF is_simple_filter( it_statements = is_procedure-statements
                           iv_index      = lv_idx ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_filter ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_simple_filter.
    DATA lv_source       TYPE string.
    DATA lv_work_area    TYPE string.
    DATA lv_append_src   TYPE string.
    DATA lv_destination  TYPE string.
    DATA lv_loop_valid   TYPE abap_bool.
    DATA lv_append_valid TYPE abap_bool.
    DATA ls_loop         TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_if           TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_append       TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_endif        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_endloop      TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_yes = abap_false.
    IF iv_index + 4 > lines( it_statements ).
      RETURN.
    ENDIF.

    ls_loop    = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                      iv_index      = iv_index ).
    ls_if      = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                      iv_index      = iv_index + 1 ).
    ls_append  = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                      iv_index      = iv_index + 2 ).
    ls_endif   = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                      iv_index      = iv_index + 3 ).
    ls_endloop = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                      iv_index      = iv_index + 4 ).

    IF ls_if-keyword <> 'IF' OR ls_endif-keyword <> 'ENDIF' OR ls_endloop-keyword <> 'ENDLOOP'.
      RETURN.
    ENDIF.

    IF has_dynamic_condition( ls_if ) = abap_true.
      RETURN.
    ENDIF.

    parse_loop_statement( EXPORTING is_statement = ls_loop
                          IMPORTING ev_source    = lv_source
                                    ev_work_area = lv_work_area
                                    ev_valid     = lv_loop_valid ).
    IF lv_loop_valid = abap_false.
      RETURN.
    ENDIF.

    parse_append_statement( EXPORTING is_statement   = ls_append
                            IMPORTING ev_source      = lv_append_src
                                      ev_destination = lv_destination
                                      ev_valid       = lv_append_valid ).
    IF lv_append_valid = abap_false.
      RETURN.
    ENDIF.

    IF lv_work_area CS '('.
      RETURN.
    ENDIF.

    IF lv_append_src <> lv_work_area.
      RETURN.
    ENDIF.

    IF lv_source = lv_destination.
      RETURN.
    ENDIF.

    rv_yes = abap_true.
  ENDMETHOD.

  METHOD parse_loop_statement.
    DATA ls_target TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_valid = abap_false.
    CLEAR: ev_source,
           ev_work_area.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `LOOP` ) ( `AT` ) ) ) = abap_false.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'GROUP' )    = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'FROM' )     = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'TO' )       = abap_true.
      RETURN.
    ENDIF.

    ls_target = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'INTO' ).
    IF ls_target-lexeme IS INITIAL.
      ls_target = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                         iv_lexeme    = 'ASSIGNING' ).
    ENDIF.

    IF ls_target-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    ev_source = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'AT' )-lexeme.
    ev_work_area = ls_target-lexeme.

    IF ev_source IS NOT INITIAL AND ev_work_area IS NOT INITIAL.
      ev_valid = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD parse_append_statement.
    DATA ls_dest TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_valid = abap_false.
    CLEAR: ev_source,
           ev_destination.

    IF is_statement-keyword <> 'APPEND'.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'INITIAL' )   = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'ASSIGNING' ) = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'SORTED' )    = abap_true.
      RETURN.
    ENDIF.

    ls_dest = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                     iv_lexeme    = 'TO' ).
    IF ls_dest-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    ev_source = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'APPEND' )-lexeme.
    ev_destination = ls_dest-lexeme.

    IF ev_source IS NOT INITIAL AND ev_destination IS NOT INITIAL.
      ev_valid = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_dynamic_condition.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme CP 'SY-*' OR <ls_token>-lexeme CP 'SYST-*'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
      IF    zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                    iv_lexeme = 'OR' )     = abap_true
         OR zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                    iv_lexeme = 'NOT' )    = abap_true
         OR zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                    iv_lexeme = 'EQUIV' )  = abap_true.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
