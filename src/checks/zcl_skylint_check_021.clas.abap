CLASS zcl_skylint_check_021 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_operator TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFEROP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_operator TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'PREFEROP',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_legacy_operator
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS map_to_symbol
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_op) TYPE string.

    METHODS is_declaration_keyword
      IMPORTING iv_keyword   TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_021 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-prefer_operator
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Prefer modern comparison operators (=, <>, <, >, <=, >=) over legacy keywords' ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_operator
                                                short_text = 'Replace with symbolic operator' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_tok_idx   TYPE i.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF is_declaration_keyword( <ls_statement>-keyword ) = abap_true.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_tok_idx = sy-tabix.
        IF     <ls_token>-references                   IS INITIAL
           AND is_legacy_operator( <ls_token>-lexeme )  = abap_true.
          lt_overrides = VALUE #( ( index  = lv_tok_idx
                                    lexeme = map_to_symbol( <ls_token>-lexeme ) ) ).
          lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                             it_overrides = lt_overrides ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_operator
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-prefer_operator
                            is_quickfix     = ls_quickfix ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_legacy_operator.
    CASE iv_lexeme.
      WHEN 'EQ' OR 'NE' OR 'GT' OR 'LT' OR 'GE' OR 'LE'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD map_to_symbol.
    rv_op = iv_lexeme.
    CASE iv_lexeme.
      WHEN 'EQ'.
        rv_op = '='.
      WHEN 'NE'.
        rv_op = '<>'.
      WHEN 'GT'.
        rv_op = '>'.
      WHEN 'LT'.
        rv_op = '<'.
      WHEN 'GE'.
        rv_op = '>='.
      WHEN 'LE'.
        rv_op = '<='.
    ENDCASE.
  ENDMETHOD.

  METHOD is_declaration_keyword.
    CASE iv_keyword.
      WHEN 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS'
        OR 'PARAMETERS' OR 'FIELD-SYMBOLS' OR 'METHODS' OR 'CLASS-METHODS'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
