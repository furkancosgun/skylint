CLASS zcl_skylint_check_024 DEFINITION
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
      IMPORTING
        iv_str       TYPE string
      RETURNING
        VALUE(rv_is) TYPE abap_bool.

    METHODS is_comparison_operator
      IMPORTING
        iv_str       TYPE string
      RETURNING
        VALUE(rv_is) TYPE abap_bool.

    METHODS is_identifier
      IMPORTING
        iv_str       TYPE string
      RETURNING
        VALUE(rv_is) TYPE abap_bool.

    METHODS has_yoda_condition
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_024 IMPLEMENTATION.
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
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA lv_tok1  TYPE string.
    DATA lv_tok2  TYPE string.
    DATA lv_tok3  TYPE string.
    FIELD-SYMBOLS <ls_t1> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_t2> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_t3> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    lv_total = lines( is_statement-tokens ).
    IF lv_total < 3.
      RETURN.
    ENDIF.

    lv_idx = 1.
    WHILE lv_idx <= lv_total - 2.
      READ TABLE is_statement-tokens ASSIGNING <ls_t1> INDEX lv_idx.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      READ TABLE is_statement-tokens ASSIGNING <ls_t2> INDEX lv_idx + 1.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      READ TABLE is_statement-tokens ASSIGNING <ls_t3> INDEX lv_idx + 2.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_tok1 = <ls_t1>-lexeme.
      lv_tok2 = <ls_t2>-lexeme.
      lv_tok3 = <ls_t3>-lexeme.

      IF is_literal( lv_tok1 ) = abap_true
         AND is_comparison_operator( lv_tok2 ) = abap_true
         AND is_identifier( lv_tok3 ) = abap_true
         AND is_literal( lv_tok3 ) = abap_false.
        rv_has = abap_true.
        RETURN.
      ENDIF.

      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_literal.
    DATA lv_len   TYPE i.
    DATA lv_first TYPE c LENGTH 1.
    DATA lv_last  TYPE c LENGTH 1.
    DATA lv_rest  TYPE string.

    rv_is = abap_false.
    lv_len = strlen( iv_str ).
    IF lv_len = 0.
      RETURN.
    ENDIF.

    lv_first = iv_str(1).
    lv_last = substring( val = iv_str
                         off = lv_len - 1
                         len = 1 ).

    IF ( lv_first = `'` AND lv_last = `'` )
       OR ( lv_first = '`' AND lv_last = '`' )
       OR ( lv_first = '|' AND lv_last = '|' ).
      rv_is = abap_true.
      RETURN.
    ENDIF.

    IF iv_str CO '0123456789'.
      rv_is = abap_true.
      RETURN.
    ENDIF.

    IF ( lv_first = '+' OR lv_first = '-' ) AND lv_len > 1.
      lv_rest = substring( val = iv_str
                           off = 1 ).
      IF lv_rest CO '0123456789'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_comparison_operator.
    DATA lv_op TYPE string.

    lv_op = to_upper( iv_str ).
    CASE lv_op.
      WHEN '=' OR '<>' OR '<' OR '>' OR '<=' OR '>='
        OR 'EQ' OR 'NE' OR 'LT' OR 'GT' OR 'LE' OR 'GE'
        OR 'CS' OR 'CP' OR 'NS' OR 'NP'
        OR 'CO' OR 'CN' OR 'CA' OR 'NA'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
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
