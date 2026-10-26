CLASS zcl_skylint_no_select_star DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        select_star TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_SEL_STR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_SELECT_STAR'.

    METHODS is_select_star
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_select_star IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid SELECT * (specify columns explicitly)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-select_star
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid SELECT *; specify required columns explicitly'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'SELECT' AND is_select_star( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-select_star ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_select_star.
    DATA lv_in_fields   TYPE abap_bool.
    DATA lv_prev_lexeme TYPE string.
    DATA lv_len         TYPE i.
    DATA lv_suffix      TYPE string.
    DATA lv_last_char   TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-references IS INITIAL.
        CASE <ls_token>-lexeme.
          WHEN 'SELECT' OR 'FIELDS'.
            lv_in_fields = abap_true.
          WHEN 'FROM' OR 'WHERE' OR 'GROUP' OR 'HAVING' OR 'ORDER' OR 'INTO' OR 'UP' OR 'UNION'.
            lv_in_fields = abap_false.
        ENDCASE.
      ENDIF.

      IF lv_in_fields = abap_true.
        lv_len = strlen( <ls_token>-lexeme ).
        IF lv_len >= 2.
          lv_suffix = substring( val = <ls_token>-lexeme
                                 off = lv_len - 2
                                 len = 2 ).
          IF lv_suffix = '~*'.
            rv_res = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

        IF <ls_token>-lexeme = '*'.
          IF strlen( lv_prev_lexeme ) >= 1.
            lv_last_char = substring( val = lv_prev_lexeme
                                      off = strlen( lv_prev_lexeme ) - 1
                                      len = 1 ).
          ELSE.
            CLEAR lv_last_char.
          ENDIF.

          IF    lv_prev_lexeme = 'SELECT'
             OR lv_prev_lexeme = 'SINGLE'
             OR lv_prev_lexeme = 'FIELDS'
             OR lv_prev_lexeme = 'DISTINCT'
             OR lv_last_char   = ','.
            rv_res = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

      lv_prev_lexeme = <ls_token>-lexeme.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
