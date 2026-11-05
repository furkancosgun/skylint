CLASS /skyl/cl_pref_clamp DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        pref_clamp TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CLAMP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        to_nminmax TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TO_NMINMAX',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CLAMP'.

    TYPES:
      BEGIN OF ty_clamp_branch,
        var    TYPE string,
        bound  TYPE string,
        is_min TYPE abap_bool,
      END OF ty_clamp_branch.

    METHODS get_clamp_branch
      IMPORTING is_cond          TYPE if_ci_atc_source_code_provider=>ty_statement
                is_body          TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_branch) TYPE ty_clamp_branch.

ENDCLASS.


CLASS /skyl/cl_pref_clamp IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer nmin/nmax over manual IF clamp'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-pref_clamp
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Manual range clamping detected; consider using nmin( ) and nmax( )'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-to_nminmax
                                                short_text = 'Use nmin( ) and nmax( )' ) ) ) ).
  ENDMETHOD.

  METHOD get_clamp_branch.
    DATA lv_is_assign  TYPE abap_bool.
    DATA lv_var        TYPE string.
    DATA lv_bound      TYPE string.
    DATA lv_from       TYPE i.
    DATA lv_to         TYPE i.
    DATA lv_op_idx     TYPE i.
    DATA lv_op         TYPE string.
    DATA lv_left_from  TYPE i.
    DATA lv_left_to    TYPE i.
    DATA lv_right_from TYPE i.
    DATA lv_right_to   TYPE i.
    DATA lv_left       TYPE string.
    DATA lv_right      TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_branch.

    /skyl/cl_ast_util=>parse_assignment( EXPORTING is_statement     = is_body
                                         IMPORTING ev_target        = lv_var
                                                   ev_expr          = lv_bound
                                                   ev_is_assignment = lv_is_assign ).
    IF lv_is_assign = abap_false.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lines( is_cond-tokens ).
    IF lv_from > lv_to.
      RETURN.
    ENDIF.

    /skyl/cl_ast_util=>strip_outer_parens( EXPORTING is_statement = is_cond
                                           CHANGING  cv_from      = lv_from
                                                     cv_to        = lv_to ).

    LOOP AT is_cond-tokens ASSIGNING <ls_token> FROM lv_from TO lv_to.
      IF     <ls_token>-references IS INITIAL
         AND /skyl/cl_ast_util=>is_comparison_operator( <ls_token>-lexeme )  = abap_true.
        lv_op_idx = sy-tabix.
        lv_op     = to_upper( <ls_token>-lexeme ).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_op_idx <= lv_from OR lv_op_idx >= lv_to.
      RETURN.
    ENDIF.

    lv_left_from = lv_from.
    lv_left_to   = lv_op_idx - 1.
    /skyl/cl_ast_util=>strip_outer_parens( EXPORTING is_statement = is_cond
                                           CHANGING  cv_from      = lv_left_from
                                                     cv_to        = lv_left_to ).
    lv_left = /skyl/cl_ast_util=>extract_tokens_text( is_statement = is_cond
                                                      iv_from_idx  = lv_left_from
                                                      iv_to_idx    = lv_left_to ).

    lv_right_from = lv_op_idx + 1.
    lv_right_to   = lv_to.
    /skyl/cl_ast_util=>strip_outer_parens( EXPORTING is_statement = is_cond
                                           CHANGING  cv_from      = lv_right_from
                                                     cv_to        = lv_right_to ).
    lv_right = /skyl/cl_ast_util=>extract_tokens_text( is_statement = is_cond
                                                       iv_from_idx  = lv_right_from
                                                       iv_to_idx    = lv_right_to ).

    IF to_upper( lv_var ) = to_upper( lv_left ) AND to_upper( lv_bound ) = to_upper( lv_right ).
      CASE lv_op.
        WHEN '<' OR 'LT' OR '<=' OR 'LE'.
          rs_branch = VALUE #( var    = lv_var
                               bound  = lv_bound
                               is_min = abap_true ).
        WHEN '>' OR 'GT' OR '>=' OR 'GE'.
          rs_branch = VALUE #( var    = lv_var
                               bound  = lv_bound
                               is_min = abap_false ).
      ENDCASE.
    ELSEIF to_upper( lv_var ) = to_upper( lv_right ) AND to_upper( lv_bound ) = to_upper( lv_left ).
      CASE lv_op.
        WHEN '>' OR 'GT' OR '>=' OR 'GE'.
          rs_branch = VALUE #( var    = lv_var
                               bound  = lv_bound
                               is_min = abap_true ).
        WHEN '<' OR 'LT' OR '<=' OR 'LE'.
          rs_branch = VALUE #( var    = lv_var
                               bound  = lv_bound
                               is_min = abap_false ).
      ENDCASE.
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    DATA lv_idx       TYPE i.
    DATA ls_body1     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_elseif    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_body2     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_endif     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_b1        TYPE ty_clamp_branch.
    DATA ls_b2        TYPE ty_clamp_branch.
    DATA lv_min_bound TYPE string.
    DATA lv_max_bound TYPE string.
    DATA lv_indent    TYPE string.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE /skyl/cl_rule_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_idx = sy-tabix.
      IF <ls_stmt>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      ls_body1  = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = lv_idx + 1 ).
      ls_elseif = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = lv_idx + 2 ).
      ls_body2  = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = lv_idx + 3 ).
      ls_endif  = /skyl/cl_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = lv_idx + 4 ).

      IF ls_elseif-keyword <> 'ELSEIF' OR ls_endif-keyword <> 'ENDIF'.
        CONTINUE.
      ENDIF.

      ls_b1 = get_clamp_branch( is_cond = <ls_stmt>
                                is_body = ls_body1 ).
      ls_b2 = get_clamp_branch( is_cond = ls_elseif
                                is_body = ls_body2 ).

      IF    ls_b1                 IS INITIAL
         OR ls_b2                 IS INITIAL
         OR to_upper( ls_b1-var ) <> to_upper( ls_b2-var )
         OR ls_b1-is_min           = ls_b2-is_min.
        CONTINUE.
      ENDIF.

      IF ls_b1-is_min = abap_true.
        lv_min_bound = ls_b1-bound.
        lv_max_bound = ls_b2-bound.
      ELSE.
        lv_min_bound = ls_b2-bound.
        lv_max_bound = ls_b1-bound.
      ENDIF.

      lv_indent = repeat( val = ` `
                          occ = <ls_stmt>-position-column ).

      lv_line = |{ lv_indent }{ ls_b1-var } = nmin( val1 = { lv_max_bound } val2 = nmax( val1 = { lv_min_bound } val2 = { ls_b1-var } ) ).|.

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-to_nminmax
                                      iv_statement_from = lv_idx
                                      iv_statement_to   = lv_idx + 4
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_stmt>
                        iv_finding_code = c_finding_codes-pref_clamp
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
