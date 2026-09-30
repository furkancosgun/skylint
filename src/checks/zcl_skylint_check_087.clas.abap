CLASS zcl_skylint_check_087 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dyn_sql TYPE if_ci_atc_check=>ty_finding_code VALUE 'DYN_SQL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_DYNAMIC_SQL'.
ENDCLASS.


CLASS zcl_skylint_check_087 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid dynamic SQL table or clause names without sanitization'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-dyn_sql
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid dynamic table or clause in SQL; use static SQL or sanitize'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_is_dynamic TYPE abap_bool.
    DATA lv_idx        TYPE i.
    DATA lv_len        TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_next>      TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'DELETE'.
      lv_is_dynamic = abap_false.
      lv_len = lines( <ls_statement>-tokens ).
      lv_idx = 1.

      WHILE lv_idx < lv_len.
        ASSIGN <ls_statement>-tokens[ lv_idx ] TO <ls_token>.
        IF sy-subrc = 0 AND ( to_upper( <ls_token>-lexeme ) = 'FROM' OR to_upper( <ls_token>-lexeme ) = 'WHERE' ).
          ASSIGN <ls_statement>-tokens[ lv_idx + 1 ] TO <ls_next>.
          IF sy-subrc = 0 AND ( <ls_next>-lexeme CP '(*)' OR <ls_next>-lexeme = '(' ).
            lv_is_dynamic = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
        lv_idx += 1.
      ENDWHILE.

      IF lv_is_dynamic = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dyn_sql ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
