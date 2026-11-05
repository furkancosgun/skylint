CLASS /skyl/cl_no_dup_subexp DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dup_subexpr TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUPSBX',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DUP_SUBEXPR'.

    TYPES:
      BEGIN OF ty_subexpr,
        key   TYPE string,
        token TYPE if_ci_atc_source_code_provider=>ty_token,
      END OF ty_subexpr,
      ty_subexprs TYPE STANDARD TABLE OF ty_subexpr WITH EMPTY KEY.

    METHODS extract_subexpressions
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_subexprs) TYPE ty_subexprs.

    METHODS extract_bracket_subexpr
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from_idx  TYPE i
      EXPORTING ev_key       TYPE string
                ev_end_idx   TYPE i.

    METHODS extract_call_subexpr
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from_idx  TYPE i
      EXPORTING ev_key       TYPE string
                ev_end_idx   TYPE i.

ENDCLASS.


CLASS /skyl/cl_no_dup_subexp IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid duplicate subexpressions in the same statement'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-dup_subexpr
                       severity       = if_ci_atc_check=>finding_severities-note
                       text           = 'Avoid repeating duplicate subexpressions; evaluate once into a variable'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lt_subexprs TYPE ty_subexprs.
    DATA lt_seen     TYPE string_table.
    DATA ls_sub      TYPE ty_subexpr.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lt_subexprs = extract_subexpressions( <ls_statement> ).
      IF lines( lt_subexprs ) < 2.
        CONTINUE.
      ENDIF.

      CLEAR lt_seen.
      LOOP AT lt_subexprs INTO ls_sub.
        IF line_exists( lt_seen[ table_line = ls_sub-key ] ).
          report_token( is_token        = ls_sub-token
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-dup_subexpr ).
        ELSE.
          INSERT ls_sub-key INTO TABLE lt_seen.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_subexpressions.
    DATA lv_tok_count TYPE i.
    DATA lv_i         TYPE i.
    DATA lv_key       TYPE string.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_tok_count = lines( is_statement-tokens ).
    lv_i = 1.

    WHILE lv_i <= lv_tok_count.
      ls_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = lv_i ).
      IF ls_tok-lexeme IS INITIAL.
        EXIT.
      ENDIF.

      " Skip literal strings and string templates
      IF    ls_tok-lexeme(1) = ''''
         OR ls_tok-lexeme(1) = '`'
         OR ls_tok-lexeme(1) = '|'.
        lv_i += 1.
        CONTINUE.
      ENDIF.

      CLEAR lv_key.

      IF ls_tok-lexeme CS '['.
        extract_bracket_subexpr( EXPORTING is_statement = is_statement
                                           iv_from_idx  = lv_i
                                 IMPORTING ev_key       = lv_key ).
      ELSEIF     ( ls_tok-lexeme CS '->' OR ls_tok-lexeme CS '=>' )
             AND ls_tok-lexeme CS '('.
        extract_call_subexpr( EXPORTING is_statement = is_statement
                                        iv_from_idx  = lv_i
                              IMPORTING ev_key       = lv_key ).
      ENDIF.

      IF lv_key IS NOT INITIAL.
        APPEND VALUE #( key   = lv_key
                        token = ls_tok ) TO rt_subexprs.
      ENDIF.

      lv_i += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD extract_bracket_subexpr.
    DATA lv_depth     TYPE i.
    DATA lv_j         TYPE i.
    DATA lv_count     TYPE i.
    DATA lv_open      TYPE i.
    DATA lv_close     TYPE i.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_first     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_last      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_open_pos  TYPE i.
    DATA lv_close_pos TYPE i.
    DATA lv_part      TYPE string.
    DATA lv_k         TYPE i.

    CLEAR: ev_key,
           ev_end_idx.
    lv_count = lines( is_statement-tokens ).
    lv_depth = 0.
    lv_j     = iv_from_idx.

    WHILE lv_j <= lv_count.
      ls_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = lv_j ).
      IF ls_tok-lexeme IS INITIAL.
        EXIT.
      ENDIF.

      lv_open  = count( val = ls_tok-lexeme
                        sub = '[' ).
      lv_close = count( val = ls_tok-lexeme
                        sub = ']' ).
      lv_depth += lv_open - lv_close.
      IF lv_depth <= 0.
        ev_end_idx = lv_j.
        EXIT.
      ENDIF.
      lv_j += 1.
    ENDWHILE.

    IF ev_end_idx = 0.
      RETURN.
    ENDIF.

    ls_first = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_from_idx ).
    ls_last  = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = ev_end_idx ).

    IF iv_from_idx = ev_end_idx.
      lv_close_pos = find( val = ls_first-lexeme
                           sub = ']' ).
      IF lv_close_pos >= 0.
        ev_key = to_upper( substring( val = ls_first-lexeme
                                      off = 0
                                      len = lv_close_pos + 1 ) ).
      ENDIF.
      RETURN.
    ENDIF.

    lv_open_pos = find( val = ls_first-lexeme
                        sub = '[' ).
    IF lv_open_pos >= 0.
      lv_part = substring( val = ls_first-lexeme
                           off = 0
                           len = lv_open_pos + 1 ).
      ev_key = lv_part.
    ENDIF.

    lv_k = iv_from_idx + 1.
    WHILE lv_k < ev_end_idx.
      ls_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = lv_k ).
      ev_key = |{ ev_key } { ls_tok-lexeme }|.
      lv_k += 1.
    ENDWHILE.

    lv_close_pos = find( val = ls_last-lexeme
                         sub = ']' ).
    IF lv_close_pos >= 0.
      lv_part = substring( val = ls_last-lexeme
                           off = 0
                           len = lv_close_pos + 1 ).
      ev_key = |{ ev_key } { lv_part }|.
    ENDIF.

    ev_key = to_upper( ev_key ).
  ENDMETHOD.

  METHOD extract_call_subexpr.
    DATA lv_depth     TYPE i.
    DATA lv_j         TYPE i.
    DATA lv_count     TYPE i.
    DATA lv_open      TYPE i.
    DATA lv_close     TYPE i.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_first     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_last      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_close_pos TYPE i.
    DATA lv_part      TYPE string.
    DATA lv_k         TYPE i.

    CLEAR: ev_key,
           ev_end_idx.
    lv_count = lines( is_statement-tokens ).
    lv_depth = 0.
    lv_j     = iv_from_idx.

    WHILE lv_j <= lv_count.
      ls_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = lv_j ).
      IF ls_tok-lexeme IS INITIAL.
        EXIT.
      ENDIF.

      lv_open  = count( val = ls_tok-lexeme
                        sub = '(' ).
      lv_close = count( val = ls_tok-lexeme
                        sub = ')' ).
      lv_depth += lv_open - lv_close.
      IF lv_depth <= 0.
        ev_end_idx = lv_j.
        EXIT.
      ENDIF.
      lv_j += 1.
    ENDWHILE.

    IF ev_end_idx = 0.
      RETURN.
    ENDIF.

    ls_first = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_from_idx ).
    ls_last  = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = ev_end_idx ).

    IF iv_from_idx = ev_end_idx.
      lv_close_pos = find( val = ls_first-lexeme
                           sub = ')' ).
      IF lv_close_pos >= 0.
        ev_key = to_upper( substring( val = ls_first-lexeme
                                      off = 0
                                      len = lv_close_pos + 1 ) ).
      ENDIF.
      RETURN.
    ENDIF.

    ev_key = ls_first-lexeme.

    lv_k = iv_from_idx + 1.
    WHILE lv_k < ev_end_idx.
      ls_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = lv_k ).
      ev_key = |{ ev_key } { ls_tok-lexeme }|.
      lv_k += 1.
    ENDWHILE.

    lv_close_pos = find( val = ls_last-lexeme
                         sub = ')' ).
    IF lv_close_pos >= 0.
      lv_part = substring( val = ls_last-lexeme
                           off = 0
                           len = lv_close_pos + 1 ).
      ev_key = |{ ev_key } { lv_part }|.
    ENDIF.

    ev_key = to_upper( ev_key ).
  ENDMETHOD.
ENDCLASS.
