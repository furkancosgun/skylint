CLASS zcl_skylint_no_kernel_call DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        kernel_call TYPE if_ci_atc_check=>ty_finding_code VALUE 'KERNELCALL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'KERNEL_CALL'.

ENDCLASS.


CLASS zcl_skylint_no_kernel_call IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid Kernel and Native Calls'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-kernel_call
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid internal kernel calls (CALL, SYSTEM-CALL, EXEC SQL)'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SYSTEM-CALL'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-kernel_call ).

        WHEN 'CALL'.
          IF zcl_skylint_ast_util=>token_is_literal(
                 zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                  iv_index     = 2 ) ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-kernel_call ).
          ENDIF.

        WHEN 'EXEC'.
          IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 2
                                                     iv_expected  = `SQL` ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-kernel_call ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
