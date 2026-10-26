CLASS zcl_skylint_no_dead_code DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dead_code TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DEAD_CD',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        delete_dead TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DELDEAD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DEAD_CODE'.

    METHODS is_constant_false_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS strip_outer_parens
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  cv_from      TYPE i
                cv_to        TYPE i.

    METHODS is_literal_or_constant
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_dead_pair
      IMPORTING iv_left        TYPE string
                iv_operator    TYPE string
                iv_right       TYPE string
      RETURNING VALUE(rv_dead) TYPE abap_bool.

    METHODS is_dead_between
      IMPORTING iv_operand     TYPE string
                iv_low         TYPE string
                iv_high        TYPE string
      RETURNING VALUE(rv_dead) TYPE abap_bool.

    METHODS is_number
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_string_literal
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS literal_value
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_val) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_dead_code IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect Dead Code with Constant Condition'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-dead_code
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Condition is always false, creating dead code'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-delete_dead
                                                short_text = 'Delete statement with dead code condition' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          IF is_constant_false_condition( <ls_statement> ) = abap_true.
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-delete_dead
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = VALUE #( ) ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dead_code
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_literal_or_constant.
    DATA lv_lexeme TYPE string.

    rv_yes = abap_false.
    lv_lexeme = is_token-lexeme.

    IF lv_lexeme = 'ABAP_TRUE' OR lv_lexeme = 'ABAP_FALSE'.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF lv_lexeme = 'SPACE' AND is_token-references IS INITIAL.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF is_number( lv_lexeme ) = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF is_string_literal( lv_lexeme ) = abap_true.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_dead_pair.
    DATA lv_num1 TYPE decfloat34.
    DATA lv_num2 TYPE decfloat34.
    DATA lv_str1 TYPE string.
    DATA lv_str2 TYPE string.

    rv_dead = abap_false.

    IF is_number( iv_left ) = abap_true AND is_number( iv_right ) = abap_true.
      lv_num1 = CONV decfloat34( iv_left ).
      lv_num2 = CONV decfloat34( iv_right ).

      CASE iv_operator.
        WHEN '=' OR 'EQ'.
          rv_dead = xsdbool( lv_num1 <> lv_num2 ).
        WHEN '<>' OR 'NE'.
          rv_dead = xsdbool( lv_num1 = lv_num2 ).
        WHEN '<' OR 'LT'.
          rv_dead = xsdbool( lv_num1 >= lv_num2 ).
        WHEN '>' OR 'GT'.
          rv_dead = xsdbool( lv_num1 <= lv_num2 ).
        WHEN '<=' OR 'LE'.
          rv_dead = xsdbool( lv_num1 > lv_num2 ).
        WHEN '>=' OR 'GE'.
          rv_dead = xsdbool( lv_num1 < lv_num2 ).
      ENDCASE.
      RETURN.
    ENDIF.

    IF is_string_literal( iv_left ) = abap_false OR is_string_literal( iv_right ) = abap_false.
      RETURN.
    ENDIF.

    lv_str1 = literal_value( iv_left ).
    lv_str2 = literal_value( iv_right ).

    CASE iv_operator.
      WHEN '=' OR 'EQ'.
        rv_dead = xsdbool( lv_str1 <> lv_str2 ).
      WHEN '<>' OR 'NE'.
        rv_dead = xsdbool( lv_str1 = lv_str2 ).
    ENDCASE.
  ENDMETHOD.

  METHOD is_dead_between.
    DATA lv_num  TYPE decfloat34.
    DATA lv_low  TYPE decfloat34.
    DATA lv_high TYPE decfloat34.
    DATA lv_str  TYPE string.
    DATA lv_min  TYPE string.
    DATA lv_max  TYPE string.

    rv_dead = abap_false.

    IF     is_number( iv_operand ) = abap_true
       AND is_number( iv_low )     = abap_true
       AND is_number( iv_high )    = abap_true.
      lv_num  = CONV decfloat34( iv_operand ).
      lv_low  = CONV decfloat34( iv_low ).
      lv_high = CONV decfloat34( iv_high ).
      rv_dead = xsdbool( lv_num < lv_low OR lv_num > lv_high ).
      RETURN.
    ENDIF.

    IF    is_string_literal( iv_operand ) = abap_false
       OR is_string_literal( iv_low )     = abap_false
       OR is_string_literal( iv_high )    = abap_false.
      RETURN.
    ENDIF.

    lv_str = literal_value( iv_operand ).
    lv_min = literal_value( iv_low ).
    lv_max = literal_value( iv_high ).
    rv_dead = xsdbool( lv_str < lv_min OR lv_str > lv_max ).
  ENDMETHOD.

  METHOD is_constant_false_condition.
    DATA lv_tok_cnt TYPE i.
    DATA lv_from    TYPE i.
    DATA lv_to      TYPE i.
    DATA ls_t1      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t2      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t3      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t4      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t5      TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_tok_cnt < 2.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_tok_cnt.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    IF lv_from = lv_to.
      ls_t1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from ).
      IF ls_t1-lexeme = 'ABAP_FALSE'.
        rv_res = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_to = lv_from + 2.
      ls_t1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from ).
      ls_t2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from + 1 ).
      ls_t3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_to ).

      IF is_literal_or_constant( ls_t1 ) = abap_false OR is_literal_or_constant( ls_t3 ) = abap_false.
        RETURN.
      ENDIF.

      rv_res = is_dead_pair( iv_left     = ls_t1-lexeme
                             iv_operator = ls_t2-lexeme
                             iv_right    = ls_t3-lexeme ).
      RETURN.
    ENDIF.

    IF lv_to = lv_from + 4.
      ls_t1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from ).
      ls_t2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from + 1 ).
      ls_t3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from + 2 ).
      ls_t4 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_from + 3 ).
      ls_t5 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_to ).

      IF ls_t2-lexeme = 'BETWEEN' AND ls_t4-lexeme = 'AND'.
        IF     is_literal_or_constant( ls_t1 ) = abap_true
           AND is_literal_or_constant( ls_t3 ) = abap_true
           AND is_literal_or_constant( ls_t5 ) = abap_true.
          rv_res = is_dead_between( iv_operand = ls_t1-lexeme
                                    iv_low     = ls_t3-lexeme
                                    iv_high    = ls_t5-lexeme ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD strip_outer_parens.
    DATA lv_depth TYPE i.
    DATA lv_idx   TYPE i.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.

    WHILE cv_from < cv_to.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = cv_from ).
      IF ls_tok-lexeme <> '('.
        EXIT.
      ENDIF.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = cv_to ).
      IF ls_tok-lexeme <> ')'.
        EXIT.
      ENDIF.

      lv_depth = 0.
      lv_idx   = cv_from.
      DO cv_to - cv_from TIMES.
        ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
        lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
        IF lv_depth = 0.
          EXIT.
        ENDIF.
        lv_idx += 1.
      ENDDO.

      IF lv_depth = 1.
        cv_from += 1.
        cv_to   -= 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_number.
    rv_yes = xsdbool( matches( val   = iv_lexeme
                               regex = '^[+-]?\d+(\.\d+)?$' ) ).
  ENDMETHOD.

  METHOD is_string_literal.
    rv_yes = xsdbool(    matches( val   = iv_lexeme
                                  regex = '^''.*''$' )
                      OR matches( val   = iv_lexeme
                                  regex = '^`.*`$' ) ).
  ENDMETHOD.

  METHOD literal_value.
    DATA lv_len TYPE i.

    rv_val = iv_lexeme.
    lv_len = strlen( iv_lexeme ).
    IF lv_len < 2.
      RETURN.
    ENDIF.
    IF is_string_literal( iv_lexeme ) = abap_true.
      rv_val = substring( val = iv_lexeme
                          off = 1
                          len = lv_len - 2 ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
