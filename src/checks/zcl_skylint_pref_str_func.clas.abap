CLASS zcl_skylint_pref_str_func DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        condense_stmt  TYPE if_ci_atc_check=>ty_finding_code VALUE 'CONDENSE_S',
        translate_stmt TYPE if_ci_atc_check=>ty_finding_code VALUE 'TRANSLATE_',
        shift_stmt     TYPE if_ci_atc_check=>ty_finding_code VALUE 'SHIFT_STMT',
        search_stmt    TYPE if_ci_atc_check=>ty_finding_code VALUE 'SEARCH_STM',
        overlay_stmt   TYPE if_ci_atc_check=>ty_finding_code VALUE 'OVERLAY_ST',
        replace_stmt   TYPE if_ci_atc_check=>ty_finding_code VALUE 'REPLACE_ST',
        describe_field TYPE if_ci_atc_check=>ty_finding_code VALUE 'DESCRIBE_F',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        condense_stmt  TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CONDENSE',
        translate_stmt TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TRANSLATE',
        shift_stmt     TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'SHIFT',
        replace_stmt   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLACE',
        describe_field TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DESCRIBE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'STR_FUNC'.

    DATA mv_check_condense  TYPE abap_bool VALUE abap_true.
    DATA mv_check_translate TYPE abap_bool VALUE abap_true.
    DATA mv_check_shift     TYPE abap_bool VALUE abap_true.
    DATA mv_check_search    TYPE abap_bool VALUE abap_true.
    DATA mv_check_overlay   TYPE abap_bool VALUE abap_true.
    DATA mv_check_replace   TYPE abap_bool VALUE abap_true.
    DATA mv_check_describe  TYPE abap_bool VALUE abap_true.

    METHODS quickfix_translate_using
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_var         TYPE string
      RETURNING VALUE(rv_line) TYPE string.

    METHODS quickfix_shift
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_var         TYPE string
      RETURNING VALUE(rv_line) TYPE string.

    METHODS quickfix_replace_stmt
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

    METHODS quickfix_describe_field
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.
ENDCLASS.


CLASS zcl_skylint_pref_str_func IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect obsolete string statements; prefer built-in functions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-condense_stmt
                                       text = 'Use modern built-in string function condense( ... ) instead' )
                                     ( code = c_finding_codes-translate_stmt
                                       text = 'Use modern string functions to_upper() or to_lower() instead' )
                                     ( code = c_finding_codes-shift_stmt
                                       text = 'Use modern string function shift_left( ) or shift_right( ) instead' )
                                     ( code = c_finding_codes-search_stmt
                                       text = 'SEARCH statement is obsolete; prefer find( ) or contains( )' )
                                     ( code = c_finding_codes-overlay_stmt
                                       text = 'OVERLAY statement is obsolete; prefer string functions or templates' )
                                     ( code = c_finding_codes-replace_stmt
                                       text = 'Obsolete REPLACE statement; prefer replace( ) function' )
                                     ( code = c_finding_codes-describe_field
                                       text = 'Use strlen( ... ) instead of DESCRIBE FIELD ... LENGTH' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-condense_stmt
                                                                short_text = 'Use condense( ) function' )
                                                              ( code       = c_quickfix_codes-translate_stmt
                                                                short_text = 'Use to_upper( )/to_lower( )' )
                                                              ( code       = c_quickfix_codes-shift_stmt
                                                                short_text = 'Use shift_left( )/shift_right( )' )
                                                              ( code       = c_quickfix_codes-replace_stmt
                                                                short_text = 'Use replace( ) function' )
                                                              ( code       = c_quickfix_codes-describe_field
                                                                short_text = 'Use strlen( ) function' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_CONDENSE'
                                                                value = REF #( mv_check_condense ) )
                                                              ( name  = 'CHECK_TRANSLATE'
                                                                value = REF #( mv_check_translate ) )
                                                              ( name  = 'CHECK_SHIFT'
                                                                value = REF #( mv_check_shift ) )
                                                              ( name  = 'CHECK_SEARCH'
                                                                value = REF #( mv_check_search ) )
                                                              ( name  = 'CHECK_OVERLAY'
                                                                value = REF #( mv_check_overlay ) )
                                                              ( name  = 'CHECK_REPLACE'
                                                                value = REF #( mv_check_replace ) )
                                                              ( name  = 'CHECK_DESCRIBE'
                                                                value = REF #( mv_check_describe ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_var      TYPE string.
    DATA lv_line     TYPE string.
    DATA lv_code     TYPE if_ci_atc_check=>ty_finding_code.
    DATA lv_fix_code TYPE cl_ci_atc_quickfixes=>ty_quickfix_code.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.
      CLEAR lv_line.
      CLEAR lv_code.
      CLEAR lv_fix_code.
      CASE <ls_statement>-keyword.
        WHEN 'CONDENSE'.
          IF mv_check_condense = abap_false.
            CONTINUE.
          ENDIF.
          ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                          iv_lexeme    = 'CONDENSE' ).
          lv_var = ls_tok-lexeme.
          lv_code = c_finding_codes-condense_stmt.
          lv_fix_code = c_quickfix_codes-condense_stmt.
          IF zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                               iv_lexeme    = 'NO-GAPS' ) > 0.
            lv_line = |{ lv_var } = condense( val = { lv_var } from = ` ` to = `` ).|.
          ELSE.
            lv_line = |{ lv_var } = condense( { lv_var } ).|.
          ENDIF.

        WHEN 'TRANSLATE'.
          IF mv_check_translate = abap_false.
            CONTINUE.
          ENDIF.
          ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                          iv_lexeme    = 'TRANSLATE' ).
          lv_var = ls_tok-lexeme.
          lv_code = c_finding_codes-translate_stmt.
          lv_fix_code = c_quickfix_codes-translate_stmt.
          IF zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                               iv_lexeme    = 'UPPER' ) > 0.
            lv_line = |{ lv_var } = to_upper( { lv_var } ).|.
          ELSEIF zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'LOWER' ) > 0.
            lv_line = |{ lv_var } = to_lower( { lv_var } ).|.
          ELSE.
            lv_line = quickfix_translate_using( is_statement = <ls_statement>
                                                iv_var       = lv_var ).
          ENDIF.

        WHEN 'SHIFT'.
          IF mv_check_shift = abap_false.
            CONTINUE.
          ENDIF.
          ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                          iv_lexeme    = 'SHIFT' ).
          lv_var = ls_tok-lexeme.
          lv_code = c_finding_codes-shift_stmt.
          lv_fix_code = c_quickfix_codes-shift_stmt.
          lv_line = quickfix_shift( is_statement = <ls_statement>
                                    iv_var       = lv_var ).

        WHEN 'SEARCH'.
          IF mv_check_search = abap_false.
            CONTINUE.
          ENDIF.
          lv_code = c_finding_codes-search_stmt.

        WHEN 'OVERLAY'.
          IF mv_check_overlay = abap_false.
            CONTINUE.
          ENDIF.
          lv_code = c_finding_codes-overlay_stmt.

        WHEN 'REPLACE'.
          IF mv_check_replace = abap_false.
            CONTINUE.
          ENDIF.
          IF     zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'INTO' )       > 0
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'IN' )         = 0.
            lv_code = c_finding_codes-replace_stmt.
            lv_fix_code = c_quickfix_codes-replace_stmt.
            lv_line = quickfix_replace_stmt( <ls_statement> ).
          ENDIF.

        WHEN 'DESCRIBE'.
          IF mv_check_describe = abap_false.
            CONTINUE.
          ENDIF.
          IF     zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'FIELD' )      > 0
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'LENGTH' )     > 0.
            lv_code = c_finding_codes-describe_field.
            lv_fix_code = c_quickfix_codes-describe_field.
            lv_line = quickfix_describe_field( <ls_statement> ).
          ENDIF.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      IF lv_code IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_line IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = lv_fix_code
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = lv_code
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD quickfix_translate_using.
    DATA ls_mask TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_raw  TYPE string.
    DATA lv_len  TYPE i.
    DATA lv_from TYPE string.
    DATA lv_to   TYPE string.
    DATA lv_idx  TYPE i VALUE 1.

    CLEAR rv_line.
    ls_mask = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                     iv_lexeme    = 'USING' ).
    IF zcl_skylint_ast_util=>token_is_literal( ls_mask ) = abap_false.
      RETURN.
    ENDIF.

    lv_raw = ls_mask-lexeme.
    lv_len = strlen( lv_raw ) - 2.
    IF lv_len <= 0 OR lv_len MOD 2 <> 0.
      RETURN.
    ENDIF.

    WHILE lv_idx <= lv_len.
      lv_from = |{ lv_from }{ lv_raw+lv_idx(1) }|.
      lv_idx += 1.
      lv_to   = |{ lv_to }{ lv_raw+lv_idx(1) }|.
      lv_idx += 1.
    ENDWHILE.

    IF    contains( val = lv_from
                    sub = '`' )
       OR contains( val = lv_to
                    sub = '`' ).
      RETURN.
    ENDIF.

    rv_line = |{ iv_var } = translate( val = { iv_var } from = `{ lv_from }` to = `{ lv_to }` ).|.
  ENDMETHOD.

  METHOD quickfix_shift.
    DATA ls_mask     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_places   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_is_right TYPE abap_bool.

    CLEAR rv_line.
    IF    zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                            iv_lexeme    = 'CIRCULAR' ) > 0
       OR zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                            iv_lexeme    = 'UP' )       > 0.
      RETURN.
    ENDIF.

    lv_is_right = xsdbool( zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                             iv_lexeme    = 'RIGHT' ) > 0 ).

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `DELETING` ) ( `LEADING` ) ) ) > 0.
      ls_mask = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'LEADING' ).
      IF ls_mask-lexeme IS NOT INITIAL.
        rv_line = |{ iv_var } = shift_left( val = { iv_var } sub = { ls_mask-lexeme } ).|.
      ENDIF.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `DELETING` ) ( `TRAILING` ) ) ) > 0.
      ls_mask = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'TRAILING' ).
      IF ls_mask-lexeme IS NOT INITIAL.
        rv_line = |{ iv_var } = shift_right( val = { iv_var } sub = { ls_mask-lexeme } ).|.
      ENDIF.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                         iv_lexeme    = 'BY' ) > 0.
      ls_places = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                         iv_lexeme    = 'BY' ).
      IF ls_places-lexeme IS NOT INITIAL.
        IF lv_is_right = abap_true.
          rv_line = |{ iv_var } = shift_right( val = { iv_var } places = { ls_places-lexeme } ).|.
        ELSE.
          rv_line = |{ iv_var } = shift_left( val = { iv_var } places = { ls_places-lexeme } ).|.
        ENDIF.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_is_right = abap_true.
      rv_line = |{ iv_var } = shift_right( { iv_var } ).|.
    ELSE.
      rv_line = |{ iv_var } = shift_left( { iv_var } ).|.
    ENDIF.
  ENDMETHOD.

  METHOD quickfix_replace_stmt.
    DATA ls_sub  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_with TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_into TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_line.
    ls_sub = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = 'REPLACE' ).
    ls_with = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                     iv_lexeme    = 'WITH' ).
    ls_into = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                     iv_lexeme    = 'INTO' ).
    IF ls_sub-lexeme IS NOT INITIAL AND ls_with-lexeme IS NOT INITIAL AND ls_into-lexeme IS NOT INITIAL.
      rv_line = |{ ls_into-lexeme } = replace( val = { ls_into-lexeme } sub = { ls_sub-lexeme } with = { ls_with-lexeme } ).|.
    ENDIF.
  ENDMETHOD.

  METHOD quickfix_describe_field.
    DATA ls_field TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_len   TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_line.
    ls_field = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'FIELD' ).
    ls_len = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = 'LENGTH' ).
    IF ls_field-lexeme IS NOT INITIAL AND ls_len-lexeme IS NOT INITIAL.
      rv_line = |{ ls_len-lexeme } = strlen( { ls_field-lexeme } ).|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
