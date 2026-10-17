CLASS zcl_skylint_modify_own_tab DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        modify_own_tables TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOT_OWN_TB',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OWN_TABLES'.

ENDCLASS.


CLASS zcl_skylint_modify_own_tab IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Modify Only Own Database Tables'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-modify_own_tables
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Modify only customer-owned (Z/Y) database tables'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_target TYPE string.
    DATA lv_is_db  TYPE abap_bool.
    DATA lv_tok2   TYPE string.
    DATA lv_tok3   TYPE string.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CLEAR: lv_target,
             lv_is_db.

      CASE <ls_statement>-keyword.
        WHEN 'DELETE'.
          IF lines( <ls_statement>-tokens ) >= 3.
            lv_tok2 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = 2 ).
            lv_tok3 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = 3 ).
            IF lv_tok2 = 'FROM'.
              lv_target = lv_tok3.
              lv_is_db  = abap_true.
            ENDIF.
          ENDIF.

        WHEN 'UPDATE'.
          IF lines( <ls_statement>-tokens ) >= 2.
            lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                                iv_index     = 2 ).
            lv_is_db  = abap_true.
          ENDIF.

        WHEN 'INSERT'.
          IF lines( <ls_statement>-tokens ) >= 3.
            lv_tok2 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = 2 ).
            lv_tok3 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = 3 ).
            IF lv_tok2 = 'INTO' AND lv_tok3 <> 'TABLE'.
              lv_target = lv_tok3.
              lv_is_db  = abap_true.
            ELSEIF lv_tok3 = 'FROM'.
              lv_target = lv_tok2.
              lv_is_db  = abap_true.
            ENDIF.
          ENDIF.

        WHEN 'MODIFY'.
          IF lines( <ls_statement>-tokens ) >= 3.
            lv_tok2 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = 2 ).
            lv_tok3 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = 3 ).
            IF lv_tok3 = 'FROM'.
              IF     NOT line_exists( <ls_statement>-tokens[ lexeme = 'INDEX' ] )
                 AND NOT line_exists( <ls_statement>-tokens[ lexeme = 'TRANSPORTING' ] ).
                lv_target = lv_tok2.
                lv_is_db  = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      IF lv_is_db = abap_true AND lv_target IS NOT INITIAL.
        IF lv_target(1) = '(' OR lv_target(1) = '@'.
          CONTINUE.
        ENDIF.

        IF lv_target(1) <> 'Z' AND lv_target(1) <> 'Y'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-modify_own_tables ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
