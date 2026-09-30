CLASS zcl_skylint_check_024 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_xsdbool TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFERXSDBOOL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_XSDBOOL'.

    METHODS is_boolean_assignment
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_target    TYPE string
                ev_is_bool   TYPE abap_bool.

    METHODS is_boolean_value
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_024 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural kontrol edilmesi cok zor bir yapi boolc ifadesi varsa xsdbool cevirmek daha dogru olabilir
    "TODO yine de kalsin gercekten calistigina eminsek refactoring yapip kullanalim
    super->constructor(
        VALUE #( description       = 'Prefer xsdbool( ) expression over manual IF-ELSE assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_xsdbool
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer xsdbool( ... ) instead of manual IF-ELSE boolean assignment'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx            TYPE i.
    DATA lv_max            TYPE i.
    DATA lv_idx_then       TYPE i.
    DATA lv_idx_else       TYPE i.
    DATA lv_idx_body       TYPE i.
    DATA lv_idx_endif      TYPE i.
    DATA ls_stmt_if        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_then      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_else      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_else_body TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_endif     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_target_1       TYPE string.
    DATA lv_target_2       TYPE string.
    DATA lv_is_bool_1      TYPE abap_bool.
    DATA lv_is_bool_2      TYPE abap_bool.
    DATA lv_found_then     TYPE abap_bool.
    DATA lv_found_else     TYPE abap_bool.
    DATA lv_found_body     TYPE abap_bool.
    DATA lv_found_endif    TYPE abap_bool.

    lv_max = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements INTO ls_stmt_if WHERE keyword = 'IF'.
      lv_idx = sy-tabix.
      IF lv_idx + 4 > lv_max.
        CONTINUE.
      ENDIF.

      lv_idx_then = lv_idx + 1.
      lv_idx_else = lv_idx + 2.
      lv_idx_body = lv_idx + 3.
      lv_idx_endif = lv_idx + 4.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index       = lv_idx_then
                          IMPORTING es_statement   = ls_stmt_then
                                    ev_found       = lv_found_then ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index       = lv_idx_else
                          IMPORTING es_statement   = ls_stmt_else
                                    ev_found       = lv_found_else ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index       = lv_idx_body
                          IMPORTING es_statement   = ls_stmt_else_body
                                    ev_found       = lv_found_body ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index       = lv_idx_endif
                          IMPORTING es_statement   = ls_stmt_endif
                                    ev_found       = lv_found_endif ).
      IF lv_found_then = abap_false OR lv_found_else = abap_false
         OR lv_found_body = abap_false OR lv_found_endif = abap_false.
        CONTINUE.
      ENDIF.

      IF ls_stmt_else-keyword <> 'ELSE' OR ls_stmt_endif-keyword <> 'ENDIF'.
        CONTINUE.
      ENDIF.

      is_boolean_assignment( EXPORTING is_statement = ls_stmt_then
                             IMPORTING ev_target    = lv_target_1
                                       ev_is_bool   = lv_is_bool_1 ).

      is_boolean_assignment( EXPORTING is_statement = ls_stmt_else_body
                             IMPORTING ev_target    = lv_target_2
                                       ev_is_bool   = lv_is_bool_2 ).

      IF lv_is_bool_1 = abap_true AND lv_is_bool_2 = abap_true AND lv_target_1 = lv_target_2.
        report_statement( is_statement    = ls_stmt_if
                          iv_finding_code = c_finding_codes-prefer_xsdbool ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_assignment.
    DATA ls_tok_target TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_eq     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_val    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found1     TYPE abap_bool.
    DATA lv_found2     TYPE abap_bool.
    DATA lv_found3     TYPE abap_bool.

    ev_is_bool = abap_false.
    CLEAR ev_target.

    IF lines( is_statement-tokens ) <> 3.
      RETURN.
    ENDIF.

    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 1
                    IMPORTING es_token     = ls_tok_target
                              ev_found     = lv_found1 ).
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 2
                    IMPORTING es_token     = ls_tok_eq
                              ev_found     = lv_found2 ).
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 3
                    IMPORTING es_token     = ls_tok_val
                              ev_found     = lv_found3 ).
    IF lv_found1 = abap_false OR lv_found2 = abap_false OR lv_found3 = abap_false.
      RETURN.
    ENDIF.

    IF ls_tok_eq-lexeme <> '='.
      RETURN.
    ENDIF.

    IF is_boolean_value( ls_tok_val-lexeme ) = abap_true.
      ev_target  = ls_tok_target-lexeme.
      ev_is_bool = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_boolean_value.
    DATA lv_upper TYPE string.

    lv_upper = to_upper( iv_lexeme ).

    CASE lv_upper.
      WHEN 'ABAP_TRUE' OR 'ABAP_FALSE' OR '''X''' OR ''' ''' OR '''''' OR 'SPACE'.
        rv_res = abap_true.
      WHEN OTHERS.
        rv_res = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
