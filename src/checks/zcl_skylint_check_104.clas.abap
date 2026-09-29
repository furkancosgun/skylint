CLASS zcl_skylint_check_104 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        pref_exists TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_EXST',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_LINE_EXISTS'.
ENDCLASS.


CLASS zcl_skylint_check_104 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer line_exists( ... ) over READ TABLE TRANSPORTING NO FIELDS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-pref_exists
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use modern line_exists( ... ) expression to check for table line existence'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    DATA lv_len TYPE i.
    DATA lv_found TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok1> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok2> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok3> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'READ'.
      lv_len = lines( <ls_stmt>-tokens ).
      lv_idx = 1.
      lv_found = abap_false.

      WHILE lv_idx <= lv_len - 2.
        ASSIGN <ls_stmt>-tokens[ lv_idx ] TO <ls_tok1>.
        ASSIGN <ls_stmt>-tokens[ lv_idx + 1 ] TO <ls_tok2>.
        ASSIGN <ls_stmt>-tokens[ lv_idx + 2 ] TO <ls_tok3>.

        IF to_upper( <ls_tok1>-lexeme ) = 'TRANSPORTING'
            AND to_upper( <ls_tok2>-lexeme ) = 'NO'
            AND to_upper( <ls_tok3>-lexeme ) = 'FIELDS'.
          lv_found = abap_true.
          EXIT.
        ENDIF.
        lv_idx = lv_idx + 1.
      ENDWHILE.

      IF lv_found = abap_true.
        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-pref_exists ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
