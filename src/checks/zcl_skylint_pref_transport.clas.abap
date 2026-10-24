CLASS zcl_skylint_pref_transport DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        full_modify TYPE if_ci_atc_check=>ty_finding_code VALUE 'FULL_MODIF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TRANSPORTING'.
ENDCLASS.


CLASS zcl_skylint_pref_transport IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid MODIFY itab in LOOP without TRANSPORTING clause'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-full_modify
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Specify TRANSPORTING fields in MODIFY itab inside loop for performance'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_loop          TYPE i VALUE 0.
    DATA lv_has_transporting TYPE abap_bool.
    DATA lv_is_itab_modify   TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP'.
          lv_in_loop += 1.

        WHEN 'ENDLOOP'.
          IF lv_in_loop > 0.
            lv_in_loop -= 1.
          ENDIF.

        WHEN 'MODIFY'.
          IF lv_in_loop > 0.
            IF zcl_skylint_ast_util=>statement_is_db_access( <ls_statement> ) = abap_true.
              CONTINUE.
            ENDIF.

            lv_has_transporting = zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                                          iv_lexeme    = 'TRANSPORTING' ).
            lv_is_itab_modify = xsdbool(
                 zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'FROM' )       = abap_true
              OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'INDEX' )      = abap_true ).

            IF lv_is_itab_modify = abap_true AND lv_has_transporting = abap_false.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-full_modify ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
