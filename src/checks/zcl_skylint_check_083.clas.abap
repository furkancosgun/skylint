CLASS zcl_skylint_check_083 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_filter TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FILTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_FILTER'.
ENDCLASS.


CLASS zcl_skylint_check_083 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural silinsin
    super->constructor( VALUE #( description       = 'Prefer FILTER #( ) table operator over manual filter copy loops'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_filter
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer FILTER #( ... ) expression over manual filter copy loop'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_where TYPE abap_bool.
    DATA lv_tabix TYPE i.
    DATA lv_next_tabix TYPE i.
    DATA ls_body TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_end TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_body_found TYPE abap_bool.
    DATA lv_end_found TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'LOOP'.
      lv_tabix = sy-tabix.
      lv_has_where = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) = 'WHERE'.
          lv_has_where = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_has_where = abap_false.
        CONTINUE.
      ENDIF.
      lv_next_tabix = lv_tabix + 1.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_next_tabix
                          IMPORTING es_statement  = ls_body
                                    ev_found      = lv_body_found ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_tabix + 2
                          IMPORTING es_statement  = ls_end
                                    ev_found      = lv_end_found ).
      CASE lv_body_found.
        WHEN abap_true.
          IF lv_end_found = abap_false.
            CONTINUE.
          ENDIF.
          IF ( ls_body-keyword = 'INSERT' OR ls_body-keyword = 'APPEND' )
             AND ls_end-keyword = 'ENDLOOP'.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-prefer_filter ).
          ENDIF.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
