CLASS /skyl/cl_pref_xsdbool DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_xsdbool TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_XSDBL',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_xsdbool TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOXSDBOOL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_XSDBOOL'.

    METHODS get_bool_assignment
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_target    TYPE string
                ev_is_true   TYPE abap_bool
                ev_valid     TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_pref_xsdbool IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer xsdbool( ) expression over manual IF-ELSE assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_xsdbool
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Prefer xsdbool( ) over manual IF-ELSE assignment'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_xsdbool
                                                short_text = 'Use xsdbool( )' ) ) ) ).
  ENDMETHOD.

  METHOD get_bool_assignment.
    DATA lv_is_assign TYPE abap_bool.
    DATA lv_expr      TYPE string.
    DATA ls_first_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_last_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR: ev_target,
           ev_is_true,
           ev_valid.

    /skyl/cl_ast_util=>parse_assignment( EXPORTING is_statement     = is_statement
                                            IMPORTING ev_target        = ev_target
                                                      ev_expr          = lv_expr
                                                      ev_is_assignment = lv_is_assign ).
    IF lv_is_assign = abap_false.
      RETURN.
    ENDIF.

    ls_first_tok = /skyl/cl_ast_util=>get_token_before( is_statement = is_statement
                                                           iv_lexeme    = '=' ).
    ls_last_tok = /skyl/cl_ast_util=>get_token_after( is_statement = is_statement
                                                         iv_lexeme    = '=' ).
    IF ls_first_tok IS INITIAL OR ls_last_tok IS INITIAL.
      RETURN.
    ENDIF.

    CASE lv_expr.
      WHEN 'ABAP_TRUE'.
        ev_is_true = abap_true.
        ev_valid   = abap_true.
      WHEN 'ABAP_FALSE'.
        ev_is_true = abap_false.
        ev_valid   = abap_true.
    ENDCASE.
  ENDMETHOD.

  METHOD execute.
    DATA lv_idx         TYPE i.
    DATA ls_then_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_else_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_else_body   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_endif_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_target_then TYPE string.
    DATA lv_target_else TYPE string.
    DATA lv_true_then   TYPE abap_bool.
    DATA lv_true_else   TYPE abap_bool.
    DATA lv_valid_then  TYPE abap_bool.
    DATA lv_valid_else  TYPE abap_bool.
    DATA lv_cond        TYPE string.
    DATA lv_line        TYPE string.
    DATA lv_indent      TYPE string.
    DATA ls_quickfix    TYPE /skyl/cl_rule_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_idx = sy-tabix.
      IF <ls_stmt>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      ls_then_stmt  = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = lv_idx + 1 ).
      ls_else_stmt  = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = lv_idx + 2 ).
      ls_else_body  = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = lv_idx + 3 ).
      ls_endif_stmt = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = lv_idx + 4 ).

      IF ls_else_stmt-keyword <> 'ELSE' OR ls_endif_stmt-keyword <> 'ENDIF'.
        CONTINUE.
      ENDIF.

      get_bool_assignment( EXPORTING is_statement = ls_then_stmt
                           IMPORTING ev_target    = lv_target_then
                                     ev_is_true   = lv_true_then
                                     ev_valid     = lv_valid_then ).

      get_bool_assignment( EXPORTING is_statement = ls_else_body
                           IMPORTING ev_target    = lv_target_else
                                     ev_is_true   = lv_true_else
                                     ev_valid     = lv_valid_else ).

      IF    lv_valid_then   = abap_false
         OR lv_valid_else   = abap_false
         OR lv_target_then <> lv_target_else
         OR lv_true_then    = lv_true_else.
        CONTINUE.
      ENDIF.

      lv_cond = /skyl/cl_ast_util=>extract_tokens_text( is_statement = <ls_stmt>
                                                           iv_from_idx  = 2
                                                           iv_to_idx    = lines( <ls_stmt>-tokens ) ).

      lv_indent = repeat( val = ` `
                          occ = <ls_stmt>-position-column ).

      IF lv_true_then = abap_true.
        lv_line = |{ lv_indent }{ lv_target_then } = xsdbool( { lv_cond } ).|.
      ELSE.
        lv_line = |{ lv_indent }{ lv_target_then } = xsdbool( NOT ( { lv_cond } ) ).|.
      ENDIF.

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_xsdbool
                                      iv_statement_from = lv_idx
                                      iv_statement_to   = lv_idx + 4
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_stmt>
                        iv_finding_code = c_finding_codes-prefer_xsdbool
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
