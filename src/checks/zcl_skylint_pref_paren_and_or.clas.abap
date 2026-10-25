CLASS zcl_skylint_pref_paren_and_or DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        parenthesize_and_or TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_PAREN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_PAREN_AND_OR'.

    TYPES:
      BEGIN OF ty_depth_state,
        depth   TYPE i,
        has_and TYPE abap_bool,
        has_or  TYPE abap_bool,
        between TYPE abap_bool,
      END OF ty_depth_state,
      ty_depth_states TYPE STANDARD TABLE OF ty_depth_state WITH EMPTY KEY.

    METHODS is_conditional_statement
      IMPORTING iv_keyword    TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS has_mixed_and_or
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_paren_and_or IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Parenthesize Combinations of AND and OR'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-parenthesize_and_or
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Parenthesize combinations of AND and OR to eliminate ambiguity'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_conditional_statement( <ls_statement>-keyword ) = abap_false.
        CONTINUE.
      ENDIF.

      IF has_mixed_and_or( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-parenthesize_and_or ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_conditional_statement.
    rv_yes = abap_false.
    IF    iv_keyword = 'IF'
       OR iv_keyword = 'ELSEIF'
       OR iv_keyword = 'CHECK'
       OR iv_keyword = 'WHILE'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_mixed_and_or.
    DATA lv_tok_cnt TYPE i.
    DATA lv_idx     TYPE i.
    DATA lv_depth   TYPE i.
    DATA lv_delta   TYPE i.
    DATA lt_states  TYPE ty_depth_states.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_state> TYPE ty_depth_state.

    rv_yes = abap_false.
    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_depth = 0.
    lv_idx = 1.

    WHILE lv_idx <= lv_tok_cnt.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      lv_delta = zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
      IF lv_delta > 0.
        lv_depth += lv_delta.
      ENDIF.

      ASSIGN lt_states[ depth = lv_depth ] TO <ls_state>.
      IF sy-subrc <> 0.
        APPEND VALUE #( depth = lv_depth ) TO lt_states ASSIGNING <ls_state>.
      ENDIF.

      IF ls_tok-references IS INITIAL.
        CASE ls_tok-lexeme.
          WHEN 'BETWEEN'.
            <ls_state>-between = abap_true.

          WHEN 'AND'.
            IF <ls_state>-between = abap_true.
              <ls_state>-between = abap_false.
            ELSE.
              <ls_state>-has_and = abap_true.
              IF <ls_state>-has_or = abap_true.
                rv_yes = abap_true.
                RETURN.
              ENDIF.
            ENDIF.

          WHEN 'OR' OR 'EQUIV'.
            <ls_state>-has_or = abap_true.
            IF <ls_state>-has_and = abap_true.
              rv_yes = abap_true.
              RETURN.
            ENDIF.
        ENDCASE.
      ENDIF.

      IF lv_delta < 0.
        lv_depth += lv_delta.
        IF lv_depth < 0.
          lv_depth = 0.
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
