CLASS zcl_skylint_check_020 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        yoda_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'YODACOND',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_YODA_CONDITIONS'.

    METHODS is_literal
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_comparison_operator
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_identifier
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS has_yoda_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_020 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Yoda conditions in comparison expressions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-yoda_condition
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid Yoda conditions; place variable before literal in comparison'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF has_yoda_condition( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-yoda_condition ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_yoda_condition.
    DATA lv_idx    TYPE i.
    DATA lv_total  TYPE i.
    DATA ls_t1     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t2     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t3     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found1 TYPE abap_bool.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_found3 TYPE abap_bool.

    rv_has = abap_false.
    lv_total = lines( is_statement-tokens ).
    IF lv_total < 3.
      RETURN.
    ENDIF.

    lv_idx = 1.
    WHILE lv_idx <= lv_total - 2.
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx
                      IMPORTING es_token     = ls_t1
                                ev_found     = lv_found1 ).
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx + 1
                      IMPORTING es_token     = ls_t2
                                ev_found     = lv_found2 ).
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx + 2
                      IMPORTING es_token     = ls_t3
                                ev_found     = lv_found3 ).
      IF lv_found1 = abap_false OR lv_found2 = abap_false OR lv_found3 = abap_false.
        EXIT.
      ENDIF.

      IF     is_literal( ls_t1-lexeme )             = abap_true
         AND is_comparison_operator( ls_t2-lexeme ) = abap_true
         AND is_identifier( ls_t3-lexeme )          = abap_true
         AND is_literal( ls_t3-lexeme )             = abap_false.
        rv_has = abap_true.
        RETURN.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_literal.
    DATA lv_len   TYPE i.
    DATA lv_first TYPE c LENGTH 1.
    DATA lv_last  TYPE c LENGTH 1.

    rv_is = abap_false.
    lv_len = strlen( iv_str ).
    IF lv_len = 0.
      RETURN.
    ENDIF.

    lv_first = iv_str(1).
    lv_last = substring( val = iv_str
                         off = lv_len - 1
                         len = 1 ).

    IF    ( lv_first = `'` AND lv_last = `'` )
       OR ( lv_first = '`' AND lv_last = '`' )
       OR ( lv_first = '|' AND lv_last = '|' ).
      rv_is = abap_true.
      RETURN.
    ENDIF.

    IF iv_str CO '0123456789'.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_comparison_operator.
    DATA lv_op TYPE string.

    lv_op = to_upper( iv_str ).
    rv_is = xsdbool( lv_op = '=' OR lv_op = '<>' OR lv_op = '<' OR lv_op = '>'
                     OR lv_op = '<=' OR lv_op = '>=' OR lv_op = 'EQ' OR lv_op = 'NE'
                     OR lv_op = 'LT' OR lv_op = 'GT' OR lv_op = 'LE' OR lv_op = 'GE'
                     OR lv_op = 'CS' OR lv_op = 'CP' OR lv_op = 'NS' OR lv_op = 'NP'
                     OR lv_op = 'CO' OR lv_op = 'CN' OR lv_op = 'CA' OR lv_op = 'NA' ).
  ENDMETHOD.

  METHOD is_identifier.
    DATA lv_upper TYPE string.
    DATA lv_first TYPE c LENGTH 1.

    rv_is = abap_false.
    IF iv_str IS INITIAL.
      RETURN.
    ENDIF.

    lv_upper = to_upper( iv_str ).
    lv_first = lv_upper(1).

    IF lv_first NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_'.
      RETURN.
    ENDIF.

    CASE lv_upper.
      WHEN 'AND' OR 'OR' OR 'NOT' OR 'EQUIV' OR 'IS' OR 'INITIAL' OR 'BOUND'
        OR 'ASSIGNED' OR 'REQUESTED' OR 'SUPPLIED' OR 'IN' OR 'BETWEEN'
        OR 'LIKE' OR 'LINES' OR 'TABLE' OR 'LINE_EXISTS' OR 'LINE_INDEX'.
        RETURN.
      WHEN OTHERS.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
