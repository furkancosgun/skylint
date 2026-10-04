CLASS zcl_skylint_check_052 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_loop_control TYPE zif_skylint_types=>ty_finding_code VALUE 'OBS_L_CTRL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_052 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-obsolete_loop_control
                       severity = zif_skylint_types=>severities-warning
                       text     = 'Avoid obsolete control statements in LOOP; use modern grouping' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SUM'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-obsolete_loop_control ).
        WHEN 'ON'.
          IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 2
                                                     iv_expected  = `CHANGE` ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_loop_control ).
          ENDIF.
        WHEN 'AT'.
          IF    zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `NEW` )        = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `END` )        = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `FIRST` )      = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `LAST` )       = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_loop_control ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
