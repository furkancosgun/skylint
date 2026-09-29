CLASS zcl_skylint_check_082 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        find_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'FIND_SUBRC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHECK_FIND_SUBRC'.
ENDCLASS.


CLASS zcl_skylint_check_082 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Enforce explicit sy-subrc check directly after FIND or SEARCH'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-find_subrc
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Check sy-subrc immediately after FIND or SEARCH operation'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tabix      TYPE i.
    DATA lv_next_tabix TYPE i.
    DATA lv_has_subrc  TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next>      TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_tabix = sy-tabix.
      IF <ls_statement>-keyword <> 'FIND' AND <ls_statement>-keyword <> 'SEARCH'.
        CONTINUE.
      ENDIF.

      lv_next_tabix = lv_tabix + 1.
      IF lv_next_tabix > lines( is_procedure-statements ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-find_subrc ).
        CONTINUE.
      ENDIF.

      ASSIGN is_procedure-statements[ lv_next_tabix ] TO <ls_next>.
      IF sy-subrc = 0.
        lv_has_subrc = abap_false.
        LOOP AT <ls_next>-tokens ASSIGNING <ls_token>.
          IF to_upper( <ls_token>-lexeme ) = 'SY-SUBRC'.
            lv_has_subrc = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_has_subrc = abap_false.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-find_subrc ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
