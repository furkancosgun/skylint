CLASS zcl_skylint_no_dup_literals DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        duplicate_literal TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUP_LIT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DUP_LITERALS'.

    TYPES: BEGIN OF ty_literal_count,
             literal TYPE string,
             count   TYPE i,
           END OF ty_literal_count,
           ty_literal_counts TYPE STANDARD TABLE OF ty_literal_count WITH EMPTY KEY.

    DATA mv_min_occurrences TYPE i VALUE 3.
    DATA mv_min_length      TYPE i VALUE 3.

    METHODS count_literals
      IMPORTING it_statements    TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rt_counts) TYPE ty_literal_counts.

    METHODS report_duplicates
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                it_counts     TYPE ty_literal_counts.

    METHODS is_fixed_string_literal
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS get_literal_content
      IMPORTING is_token          TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_content) TYPE string.
ENDCLASS.


CLASS zcl_skylint_no_dup_literals IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid repeating the same string literal'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-duplicate_literal
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Replace repeated literals with a constant'
                                                pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                              ( name  = 'MIN_OCCURRENCES'
                                                value = REF #( mv_min_occurrences ) )
                                              ( name  = 'MIN_LENGTH'
                                                value = REF #( mv_min_length ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_counts TYPE ty_literal_counts.

    lt_counts = count_literals( is_procedure-statements ).
    IF lt_counts IS INITIAL.
      RETURN.
    ENDIF.

    report_duplicates( it_statements = is_procedure-statements
                       it_counts     = lt_counts ).
  ENDMETHOD.

  METHOD count_literals.
    DATA lv_literal TYPE string.
    DATA lv_length  TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_counter>   TYPE ty_literal_count.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF is_fixed_string_literal( <ls_token> ) = abap_false.
          CONTINUE.
        ENDIF.

        lv_literal = get_literal_content( <ls_token> ).
        lv_length = strlen( lv_literal ).
        IF lv_length < mv_min_length.
          CONTINUE.
        ENDIF.

        ASSIGN rt_counts[ literal = lv_literal ] TO <ls_counter>.
        IF sy-subrc = 0.
          <ls_counter>-count += 1.
        ELSE.
          APPEND VALUE #( literal = lv_literal
                          count   = 1 ) TO rt_counts.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD report_duplicates.
    DATA lv_literal TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_counter>   TYPE ty_literal_count.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF is_fixed_string_literal( <ls_token> ) = abap_false.
          CONTINUE.
        ENDIF.

        lv_literal = get_literal_content( <ls_token> ).
        IF strlen( lv_literal ) < mv_min_length.
          CONTINUE.
        ENDIF.

        ASSIGN it_counts[ literal = lv_literal ] TO <ls_counter>.
        IF sy-subrc = 0 AND <ls_counter>-count >= mv_min_occurrences.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-duplicate_literal ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_fixed_string_literal.
    rv_yes = abap_false.

    IF is_token-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>token_is_literal( is_token ) = abap_false.
      RETURN.
    ENDIF.

    IF is_token-lexeme CO '0123456789'.
      RETURN.
    ENDIF.

    IF is_token-lexeme CP '|*{*|'.
      RETURN.
    ENDIF.

    rv_yes = abap_true.
  ENDMETHOD.

  METHOD get_literal_content.
    DATA lv_length TYPE i.

    CLEAR rv_content.

    lv_length = strlen( is_token-lexeme ).
    IF lv_length <= 2.
      RETURN.
    ENDIF.

    rv_content = substring( val = is_token-lexeme
                            off = 1
                            len = lv_length - 2 ).
  ENDMETHOD.
ENDCLASS.
