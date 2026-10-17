CLASS zcl_skylint_no_bool_compare DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_comparison TYPE if_ci_atc_check=>ty_finding_code VALUE 'BOOLCOMP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        drop_literal TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DROPBOOL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_bool_comp,
        op_idx   TYPE i,
        lit_idx  TYPE i,
        can_drop TYPE abap_bool,
      END OF ty_bool_comp.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'BOOL_COMPARE'.

    METHODS find_boolean_comparison
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_comp) TYPE ty_bool_comp.

    METHODS is_boolean_literal_token
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_bool_compare IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid comparing boolean method calls to boolean literals'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_comparison
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid boolean comparison for method calls; call method directly'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-drop_literal
                                                short_text = 'Drop boolean literal' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA ls_comp     TYPE ty_bool_comp.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          IF zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_true.
            ls_comp = find_boolean_comparison( <ls_statement> ).
            IF ls_comp-op_idx > 0.
              CLEAR ls_quickfix.
              IF ls_comp-can_drop = abap_true.
                lv_line = zcl_skylint_ast_util=>flatten_statement(
                              is_statement = <ls_statement>
                              it_deletions = VALUE #( ( ls_comp-op_idx ) ( ls_comp-lit_idx ) ) ).
                ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-drop_literal
                                                iv_statement_from = lv_stmt_idx
                                                it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
              ENDIF.

              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-bool_comparison
                                is_quickfix     = ls_quickfix ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD find_boolean_comparison.
    DATA lv_tok_idx TYPE i.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_prev    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lit_lex TYPE string.

    CLEAR rs_comp.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_tok_idx = sy-tabix.
      IF ls_tok-references IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      CASE ls_tok-lexeme.
        WHEN '=' OR 'EQ' OR '<>' OR 'NE' OR '><'.
          ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = lv_tok_idx - 1 ).
          IF is_boolean_literal_token( ls_prev ) = abap_true.
            rs_comp-op_idx  = lv_tok_idx.
            rs_comp-lit_idx = lv_tok_idx - 1.
            lv_lit_lex      = ls_prev-lexeme.
          ELSE.
            ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                       iv_index     = lv_tok_idx + 1 ).
            IF is_boolean_literal_token( ls_next ) = abap_true.
              rs_comp-op_idx  = lv_tok_idx.
              rs_comp-lit_idx = lv_tok_idx + 1.
              lv_lit_lex      = ls_next-lexeme.
            ENDIF.
          ENDIF.

          IF rs_comp-op_idx > 0.
            CASE ls_tok-lexeme.
              WHEN '=' OR 'EQ'.
                IF lv_lit_lex = 'ABAP_TRUE' OR lv_lit_lex = '''X''' OR lv_lit_lex = '`X`'.
                  rs_comp-can_drop = abap_true.
                ENDIF.
              WHEN '<>' OR 'NE' OR '><'.
                IF lv_lit_lex = 'ABAP_FALSE' OR lv_lit_lex = '''''' OR lv_lit_lex = '``'.
                  rs_comp-can_drop = abap_true.
                ENDIF.
            ENDCASE.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_literal_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_is = abap_false.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      IF    <ls_ref>-full_name = '\DA:ABAP_TRUE'
         OR <ls_ref>-full_name = '\DA:ABAP_FALSE'
         OR <ls_ref>-full_name = '\DA:ABAP_UNDEFINED'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF is_token-references IS INITIAL.
      CASE is_token-lexeme.
        WHEN 'ABAP_TRUE' OR 'ABAP_FALSE' OR 'ABAP_UNDEFINED' OR 'SPACE'
          OR '''X''' OR '`X`' OR '''''' OR '``'.
          rv_is = abap_true.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
