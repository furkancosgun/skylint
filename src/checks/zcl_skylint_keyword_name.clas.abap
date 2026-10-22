CLASS zcl_skylint_keyword_name DEFINITION
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

ENDCLASS.


CLASS zcl_skylint_keyword_name IMPLEMENTATION.
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
    DATA lv_name  TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_inner TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'CONSTANTS' OR 'STATICS' OR 'TYPES'.
          ls_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                      iv_index     = 2 ).
          lv_name = to_upper( ls_token-lexeme ).
          IF lv_name = 'BEGIN'.
            ls_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                        iv_index     = 4 ).
            lv_name = to_upper( ls_token-lexeme ).
          ENDIF.

          IF lv_name IS NOT INITIAL AND is_abap_keyword( lv_name ) = abap_true.
            report_token( is_statement    = <ls_statement>
                          is_token        = ls_token
                          iv_finding_code = c_finding_codes-keyword_name ).
          ENDIF.

        WHEN 'FIELD-SYMBOLS'.
          ls_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                      iv_index     = 2 ).
          lv_name = to_upper( ls_token-lexeme ).
          REPLACE ALL OCCURRENCES OF '<' IN lv_name WITH ''.
          REPLACE ALL OCCURRENCES OF '>' IN lv_name WITH ''.
          IF lv_name IS NOT INITIAL AND is_abap_keyword( lv_name ) = abap_true.
            report_token( is_statement    = <ls_statement>
                          is_token        = ls_token
                          iv_finding_code = c_finding_codes-keyword_name ).
          ENDIF.

        WHEN OTHERS.
          LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
            lv_name = to_upper( <ls_token>-lexeme ).
            IF matches( val   = lv_name
                        regex = '^DATA\(.+\)$' ).
              lv_inner = substring( val = lv_name
                                    off = 5
                                    len = strlen( lv_name ) - 6 ).
              IF is_abap_keyword( lv_inner ) = abap_true.
                report_token( is_statement    = <ls_statement>
                              is_token        = <ls_token>
                              iv_finding_code = c_finding_codes-keyword_name ).
              ENDIF.
            ELSEIF matches( val   = lv_name
                            regex = '^FIELD-SYMBOL\(<.+>\)$' ).
              lv_inner = substring( val = lv_name
                                    off = 14
                                    len = strlen( lv_name ) - 16 ).
              IF is_abap_keyword( lv_inner ) = abap_true.
                report_token( is_statement    = <ls_statement>
                              is_token        = <ls_token>
                              iv_finding_code = c_finding_codes-keyword_name ).
              ENDIF.
            ENDIF.
          ENDLOOP.
      ENDCASE.
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
ENDCLASS.
