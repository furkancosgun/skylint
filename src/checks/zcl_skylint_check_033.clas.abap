CLASS zcl_skylint_check_033 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        scope_leak TYPE if_ci_atc_check=>ty_finding_code VALUE 'SCOPELEAK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SCOPE_OF_VAR'.

    TYPES:
      BEGIN OF ty_scoped_var,
        name     TYPE string,
        block_id TYPE i,
      END OF ty_scoped_var,
      ty_scoped_vars TYPE STANDARD TABLE OF ty_scoped_var WITH EMPTY KEY.

    METHODS extract_declared_vars
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_block_id    TYPE i
      RETURNING VALUE(rt_vars) TYPE ty_scoped_vars.

    METHODS is_block_active
      IMPORTING iv_block_id   TYPE i
                it_stack      TYPE string_table
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_033 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural mutlaka compiler seviyesinde olmali manuel data(* olmamali
    "TODO scope ici data tanimlamlarda verebilirz
    "TODO ayrica daha temiz yazilmali
    super->constructor(
        VALUE #( description       = 'Scope of variable (avoid variable leaking outside control blocks)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-scope_leak
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Variable declared in inner block is referenced outside its scope'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_block_counter    TYPE i.
    DATA lt_block_stack      TYPE string_table.
    DATA lt_scoped_vars      TYPE ty_scoped_vars.
    DATA lt_new_vars         TYPE ty_scoped_vars.
    DATA lv_current_block_id TYPE i.
    DATA lv_reported         TYPE abap_bool.
    DATA lv_token_str        TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_var>       TYPE ty_scoped_var.

    lv_block_counter = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      " 1. Update block stack on block openers and closers
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'CASE' OR 'TRY'.
          lv_block_counter += 1.
          INSERT |{ lv_block_counter }| INTO lt_block_stack INDEX 1.

        WHEN 'ELSE' OR 'ELSEIF' OR 'WHEN' OR 'CATCH' OR 'CLEANUP'.
          IF lines( lt_block_stack ) > 0.
            DELETE lt_block_stack INDEX 1.
          ENDIF.
          lv_block_counter += 1.
          INSERT |{ lv_block_counter }| INTO lt_block_stack INDEX 1.

        WHEN 'ENDIF' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDCASE' OR 'ENDTRY'.
          IF lines( lt_block_stack ) > 0.
            DELETE lt_block_stack INDEX 1.
          ENDIF.
      ENDCASE.

      " 2. Check if statement references any variable outside its defining block
      lv_reported = abap_false.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_token_str = to_upper( <ls_token>-lexeme ).
        LOOP AT lt_scoped_vars ASSIGNING <ls_var> WHERE name = lv_token_str.
          IF is_block_active( iv_block_id = <ls_var>-block_id
                              it_stack    = lt_block_stack ) = abap_false.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-scope_leak ).
            lv_reported = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_reported = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      " 3. Register newly declared variables if inside a block
      IF lines( lt_block_stack ) = 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_block_stack INTO lv_token_str INDEX 1.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lv_current_block_id = lv_token_str.
      lt_new_vars = extract_declared_vars( is_statement = <ls_statement>
                                           iv_block_id  = lv_current_block_id ).
      APPEND LINES OF lt_new_vars TO lt_scoped_vars.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_declared_vars.
    DATA lv_lex TYPE string.
    DATA ls_var TYPE ty_scoped_var.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_is_decl TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_var-block_id = iv_block_id.
    lv_is_decl = abap_false.

    CASE is_statement-keyword.
      WHEN 'DATA' OR 'FIELD-SYMBOLS'.
        lv_is_decl = abap_true.
      WHEN OTHERS.
        lv_is_decl = abap_false.
    ENDCASE.

    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 2
                    IMPORTING es_token     = ls_tok2
                              ev_found     = lv_found2 ).
    IF lv_is_decl = abap_true AND lv_found2 = abap_true
       AND ls_tok2-lexeme <> 'BEGIN' AND ls_tok2-lexeme <> 'END'.
      ls_var-name = to_upper( ls_tok2-lexeme ).
      APPEND ls_var TO rt_vars.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lex = to_upper( <ls_token>-lexeme ).
      IF lv_lex CP 'DATA(*)' OR lv_lex CP '@DATA(*)'.
        REPLACE FIRST OCCURRENCE OF '@DATA(' IN lv_lex WITH ''.
        REPLACE FIRST OCCURRENCE OF 'DATA(' IN lv_lex WITH ''.
        REPLACE FIRST OCCURRENCE OF ')' IN lv_lex WITH ''.
        lv_lex = condense( lv_lex ).
        IF lv_lex IS NOT INITIAL.
          ls_var-name = lv_lex.
          APPEND ls_var TO rt_vars.
        ENDIF.
      ELSEIF lv_lex CP 'FIELD-SYMBOLS(*)' OR lv_lex CP '@FIELD-SYMBOLS(*)'.
        REPLACE FIRST OCCURRENCE OF '@FIELD-SYMBOLS(' IN lv_lex WITH ''.
        REPLACE FIRST OCCURRENCE OF 'FIELD-SYMBOLS(' IN lv_lex WITH ''.
        REPLACE FIRST OCCURRENCE OF ')' IN lv_lex WITH ''.
        lv_lex = condense( lv_lex ).
        IF lv_lex IS NOT INITIAL.
          ls_var-name = lv_lex.
          APPEND ls_var TO rt_vars.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_block_active.
    DATA lv_id_str TYPE string.

    rv_res = abap_false.
    lv_id_str = |{ iv_block_id }|.
    IF line_exists( it_stack[ table_line = lv_id_str ] ).
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
