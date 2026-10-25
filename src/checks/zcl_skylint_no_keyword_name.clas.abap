CLASS zcl_skylint_no_keyword_name DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        keyword_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'KEYWORDNM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'KEYWORD_NAME'.

    METHODS is_abap_keyword
      IMPORTING iv_name      TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_decl_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS extract_name_from_paren
      IMPORTING iv_lexeme      TYPE string
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_keyword_name IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid Using ABAP Keywords as Identifier Names'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-keyword_name
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Identifier name matches an ABAP keyword'
                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'CONSTANTS' OR 'STATICS' OR 'TYPES' OR 'FIELD-SYMBOLS'.
          check_decl_statement( <ls_statement> ).

        WHEN OTHERS.
          check_inline_declarations( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_statement.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name  TYPE string.

    IF zcl_skylint_ast_util=>find_token_sequence(
           is_statement = is_statement
           it_expected  = VALUE #( ( `BEGIN` ) ( `OF` ) ) ) > 0.
      ls_token = zcl_skylint_ast_util=>get_token_after(
          is_statement = is_statement
          iv_lexeme    = 'OF' ).
    ELSEIF zcl_skylint_ast_util=>find_token_sequence(
               is_statement = is_statement
               it_expected  = VALUE #( ( `END` ) ( `OF` ) ) ) > 0.
      RETURN.
    ELSE.
      ls_token = zcl_skylint_ast_util=>get_token_after(
          is_statement = is_statement
          iv_lexeme    = is_statement-keyword ).
    ENDIF.

    lv_name = to_upper( ls_token-lexeme ).
    IF lv_name CS '<'.
      REPLACE ALL OCCURRENCES OF '<' IN lv_name WITH ''.
    ENDIF.
    IF lv_name CS '>'.
      REPLACE ALL OCCURRENCES OF '>' IN lv_name WITH ''.
    ENDIF.

    IF lv_name IS NOT INITIAL AND is_abap_keyword( lv_name ) = abap_true.
      report_token( is_statement    = is_statement
                    is_token        = ls_token
                    iv_finding_code = c_finding_codes-keyword_name ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          CONTINUE.
        ENDIF.

        IF    <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
           OR <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
          lv_name = extract_name_from_paren( <ls_token>-lexeme ).
          IF lv_name CS '<'.
            REPLACE ALL OCCURRENCES OF '<' IN lv_name WITH ''.
          ENDIF.
          IF lv_name CS '>'.
            REPLACE ALL OCCURRENCES OF '>' IN lv_name WITH ''.
          ENDIF.

          IF lv_name IS NOT INITIAL AND is_abap_keyword( lv_name ) = abap_true.
            report_token( is_statement    = is_statement
                          is_token        = <ls_token>
                          iv_finding_code = c_finding_codes-keyword_name ).
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_abap_keyword.
    DATA lv_upper TYPE string.

    lv_upper = to_upper( iv_name ).

    CASE lv_upper.
      WHEN 'CLASS' OR 'METHOD' OR 'TYPE' OR 'DATA' OR 'TABLE' OR 'SELECT' OR 'UPDATE'
        OR 'INSERT' OR 'DELETE' OR 'MODIFY' OR 'CHECK' OR 'CLEAR' OR 'LOOP' OR 'IF'
        OR 'CASE' OR 'WHEN' OR 'DO' OR 'WHILE' OR 'RETURN' OR 'EXIT' OR 'CONTINUE'
        OR 'TRY' OR 'CATCH' OR 'CLEANUP' OR 'RAISE' OR 'PERFORM' OR 'FORM' OR 'CALL'
        OR 'ASSIGN' OR 'CONSTANTS' OR 'STATICS' OR 'INTERFACE' OR 'FUNCTION' OR 'READ'
        OR 'WRITE' OR 'APPEND' OR 'SORT' OR 'SPLIT' OR 'CONCATENATE' OR 'REPLACE'
        OR 'TRANSLATE' OR 'CONDENSE' OR 'COLLECT' OR 'DESCRIBE' OR 'FIND' OR 'COMMIT'
        OR 'ROLLBACK'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.

  METHOD extract_name_from_paren.
    DATA lv_len TYPE i.
    DATA lv_pos TYPE i.

    rv_name = iv_lexeme.
    lv_pos = find( val = iv_lexeme
                   sub = '(' ).
    IF lv_pos < 0.
      RETURN.
    ENDIF.

    lv_pos += 1.
    lv_len = strlen( iv_lexeme ) - lv_pos.
    IF     lv_len > 0
       AND substring( val = iv_lexeme
                      off = strlen( iv_lexeme ) - 1
                      len = 1 ) = ')'.
      lv_len -= 1.
    ENDIF.

    IF lv_len > 0.
      rv_name = substring( val = iv_lexeme
                           off = lv_pos
                           len = lv_len ).
    ENDIF.
    rv_name = condense( rv_name ).
  ENDMETHOD.
ENDCLASS.
