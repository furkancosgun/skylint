CLASS zcl_skylint_check_024 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_xsdbool TYPE zif_skylint_types=>ty_finding_code VALUE 'PREFERXSDBOOL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_boolean_assignment
      IMPORTING is_statement TYPE zif_skylint_types=>ty_statement
      EXPORTING ev_target    TYPE string
                ev_is_bool   TYPE abap_bool.

    METHODS is_boolean_value
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_024 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer xsdbool( ) expression over manual IF-ELSE assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-prefer_xsdbool
                       severity = zif_skylint_types=>severities-warning
                       text     = 'Prefer xsdbool( ... ) instead of manual IF-ELSE boolean assignment' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max            TYPE i.
    DATA lv_idx            TYPE i.
    DATA ls_stmt_then      TYPE zif_skylint_types=>ty_statement.
    DATA ls_stmt_else      TYPE zif_skylint_types=>ty_statement.
    DATA ls_stmt_else_body TYPE zif_skylint_types=>ty_statement.
    DATA ls_stmt_endif     TYPE zif_skylint_types=>ty_statement.
    DATA lv_target_1       TYPE string.
    DATA lv_target_2       TYPE string.
    DATA lv_is_bool_1      TYPE abap_bool.
    DATA lv_is_bool_2      TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt_if> TYPE zif_skylint_types=>ty_statement.

    lv_max = zcl_skylint_ast_util=>statement_count( is_code_block-statements ).

    LOOP AT is_code_block-statements ASSIGNING <ls_stmt_if>.
      IF <ls_stmt_if>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.
      IF lv_idx + 4 > lv_max.
        CONTINUE.
      ENDIF.

      ls_stmt_then = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                          iv_index      = lv_idx + 1 ).
      ls_stmt_else = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                          iv_index      = lv_idx + 2 ).
      ls_stmt_else_body = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                               iv_index      = lv_idx + 3 ).
      ls_stmt_endif = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                           iv_index      = lv_idx + 4 ).
      IF    ls_stmt_then-keyword      IS INITIAL OR ls_stmt_else-keyword  IS INITIAL
         OR ls_stmt_else_body-keyword IS INITIAL OR ls_stmt_endif-keyword IS INITIAL.
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
        report_statement( is_statement    = <ls_stmt_if>
                          iv_finding_code = c_finding_codes-prefer_xsdbool ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_assignment.
    DATA ls_tok_target TYPE zif_skylint_types=>ty_token.
    DATA ls_tok_eq     TYPE zif_skylint_types=>ty_token.
    DATA ls_tok_val    TYPE zif_skylint_types=>ty_token.

    ev_is_bool = abap_false.
    CLEAR ev_target.

    IF zcl_skylint_ast_util=>token_count( is_statement ) <> 3.
      RETURN.
    ENDIF.

    ls_tok_target = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = 1 ).
    ls_tok_eq = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = 2 ).
    ls_tok_val = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = 3 ).
    IF    ls_tok_target-lexeme IS INITIAL OR ls_tok_eq-lexeme IS INITIAL
       OR ls_tok_val-lexeme    IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok_eq-lexeme <> '='.
      RETURN.
    ENDIF.

    IF is_boolean_value( ls_tok_val-lexeme ) = abap_true.
      ev_target  = to_upper( ls_tok_target-lexeme ).
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
