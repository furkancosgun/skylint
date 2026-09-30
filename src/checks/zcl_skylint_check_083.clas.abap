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
    super->constructor( VALUE #( description       = 'Prefer FILTER #( ) table operator over manual filter copy loops'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_filter
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer FILTER #( ... ) expression over manual filter copy loop'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_where  TYPE abap_bool.
    DATA lv_tabix      TYPE i.
    DATA lv_next_tabix TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_body>      TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_end>       TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

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

      IF lv_has_where = abap_true AND lv_tabix + 2 <= lines( is_procedure-statements ).
        lv_next_tabix = lv_tabix + 1.
        ASSIGN is_procedure-statements[ lv_next_tabix ] TO <ls_body>.
        ASSIGN is_procedure-statements[ lv_tabix + 2 ] TO <ls_end>.
        IF     sy-subrc         = 0 AND ( <ls_body>-keyword = 'INSERT' OR <ls_body>-keyword = 'APPEND' )
           AND <ls_end>-keyword = 'ENDLOOP'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-prefer_filter ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
