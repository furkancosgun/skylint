CLASS zcl_skylint_check_079 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        catch_empty TYPE if_ci_atc_check=>ty_finding_code VALUE 'CATCH_EMPTY',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EMPTY_CATCH_BLOCK'.
ENDCLASS.


CLASS zcl_skylint_check_079 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Empty CATCH block detected; handle, log or document why ignored'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-catch_empty
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Empty CATCH block detected; handle or document why exception is ignored'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tabix TYPE i.
    DATA lv_next_tabix TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_tabix = sy-tabix.
      IF <ls_statement>-keyword <> 'CATCH'.
        CONTINUE.
      ENDIF.

      lv_next_tabix = lv_tabix + 1.
      IF lv_next_tabix > lines( is_procedure-statements ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-catch_empty ).
        CONTINUE.
      ENDIF.

      ASSIGN is_procedure-statements[ lv_next_tabix ] TO <ls_next>.
      IF sy-subrc = 0 AND ( <ls_next>-keyword = 'CATCH' OR
                            <ls_next>-keyword = 'CLEANUP' OR
                            <ls_next>-keyword = 'ENDTRY' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-catch_empty ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
