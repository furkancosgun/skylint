CLASS zcl_skylint_check_040 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        superfluous_val TYPE if_ci_atc_check=>ty_finding_code VALUE 'SUPERFLUOUS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SUPERFLUOUS_VAL'.

    METHODS is_superfluous_value
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_empty_value_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS has_nested_value_constructor
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_040 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid Superfluous VALUE Operator'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-superfluous_val
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Superfluous VALUE operator; prefer CLEAR or omit redundant constructor'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_superfluous_value( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-superfluous_val ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_superfluous_value.
    rv_res = xsdbool(    is_empty_value_assignment( is_statement )    = abap_true
                      OR has_nested_value_constructor( is_statement ) = abap_true ).
  ENDMETHOD.

  METHOD is_empty_value_assignment.
    DATA lv_count TYPE i.
    DATA lt_eq_val TYPE ty_token_lexemes.
    DATA ls_tok4 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok5 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok6 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found4 TYPE abap_bool.
    DATA lv_found5 TYPE abap_bool.
    DATA lv_found6 TYPE abap_bool.
    DATA lv_matched TYPE abap_bool.
    DATA lv_tok4_up TYPE string.

    rv_res = abap_false.
    lv_count = lines( is_statement-tokens ).
    lt_eq_val = VALUE #( ( `=` ) ( `VALUE` ) ).
    lv_matched = match_token_sequence( is_statement   = is_statement
                                       it_expected    = lt_eq_val
                                       iv_start_index = 2 ).
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 4
                    IMPORTING es_token     = ls_tok4
                              ev_found     = lv_found4 ).
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 5
                    IMPORTING es_token     = ls_tok5
                              ev_found     = lv_found5 ).
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 6
                    IMPORTING es_token     = ls_tok6
                              ev_found     = lv_found6 ).
    lv_tok4_up = to_upper( ls_tok4-lexeme ).

    IF lv_count = 5 AND lv_matched = abap_true AND lv_found4 = abap_true AND lv_found5 = abap_true
       AND ( lv_tok4_up = '#(' OR lv_tok4_up CP '*#(' ) AND ls_tok5-lexeme = ')'.
      rv_res = abap_true.
    ELSEIF lv_count >= 6 AND lv_matched = abap_true AND lv_found4 = abap_true
       AND lv_found5 = abap_true AND lv_found6 = abap_true
       AND ( ls_tok4-lexeme = '#' OR lv_tok4_up CP '*_TAB' )
       AND ls_tok5-lexeme = '(' AND ls_tok6-lexeme = ')'.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_nested_value_constructor.
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lt_open_val TYPE ty_token_lexemes.
    DATA ls_third TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found3 TYPE abap_bool.
    DATA lv_matched TYPE abap_bool.
    DATA lv_third_up TYPE string.

    rv_res = abap_false.
    lv_count = lines( is_statement-tokens ).
    lt_open_val = VALUE #( ( `(` ) ( `VALUE` ) ).

    DO lv_count TIMES.
      lv_idx = sy-index.
      lv_matched = match_token_sequence( is_statement   = is_statement
                                         it_expected    = lt_open_val
                                         iv_start_index = lv_idx ).
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx + 2
                      IMPORTING es_token     = ls_third
                                ev_found     = lv_found3 ).
      lv_third_up = to_upper( ls_third-lexeme ).
      IF lv_matched = abap_true AND lv_found3 = abap_true
         AND ( lv_third_up = '#(' OR lv_third_up CP '*#(' ).
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
