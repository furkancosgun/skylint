CLASS zcl_skylint_no_list_proc DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        list_processing TYPE if_ci_atc_check=>ty_finding_code VALUE 'LIST_PROC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LIST_PROC'.

    DATA mv_check_write     TYPE abap_bool VALUE abap_true.
    DATA mv_check_uline     TYPE abap_bool VALUE abap_true.
    DATA mv_check_skip      TYPE abap_bool VALUE abap_true.
    DATA mv_check_other     TYPE abap_bool VALUE abap_true.
    DATA mv_ignore_write_to TYPE abap_bool VALUE abap_true.
    DATA mv_check_leave     TYPE abap_bool VALUE abap_true.
    DATA mv_check_reject    TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_list_proc IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Prohibit classic list processing statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-list_processing
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'List processing statement is forbidden in OO/Cloud ABAP'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_WRITE'
                                                                value = REF #( mv_check_write ) )
                                                              ( name  = 'CHECK_ULINE'
                                                                value = REF #( mv_check_uline ) )
                                                              ( name  = 'CHECK_SKIP'
                                                                value = REF #( mv_check_skip ) )
                                                              ( name  = 'CHECK_OTHER'
                                                                value = REF #( mv_check_other ) )
                                                              ( name  = 'IGN_WRITE_TO'
                                                                value = REF #( mv_ignore_write_to ) )
                                                              ( name  = 'CHECK_LEAVE'
                                                                value = REF #( mv_check_leave ) )
                                                              ( name  = 'CHECK_REJECT'
                                                                value = REF #( mv_check_reject ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'WRITE'.
          IF mv_check_write = abap_false.
            CONTINUE.
          ENDIF.
          IF     mv_ignore_write_to = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'TO' )         > 0.
            CONTINUE.
          ENDIF.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-list_processing ).

        WHEN 'ULINE'.
          IF mv_check_uline = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'SKIP'.
          IF mv_check_skip = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'NEW-LINE' OR 'NEW-PAGE' OR 'BACK' OR 'HIDE' OR 'FORMAT' OR 'POSITION' OR 'RESERVE'.
          IF mv_check_other = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'READ'.
          IF     mv_check_other = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'LINE' )       > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'MODIFY'.
          IF     mv_check_other = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'LINE' )       > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'SCROLL'.
          IF     mv_check_other = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'LIST' )       > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'LEAVE'.
          IF mv_check_leave = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.

        WHEN 'REJECT'.
          IF mv_check_reject = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-list_processing ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
