CLASS zcl_skylint_check_080 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_use TYPE if_ci_atc_check=>ty_finding_code VALUE 'AVOID_USE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_check_break           TYPE abap_bool VALUE abap_true.
    DATA mv_check_statics         TYPE abap_bool VALUE abap_true.
    DATA mv_check_define          TYPE abap_bool VALUE abap_true.
    DATA mv_check_export_memory   TYPE abap_bool VALUE abap_true.
    DATA mv_check_export_database TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_check_080 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid use of certain statements (BREAK, STATICS, DEFINE, EXPORT)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-avoid_use
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Avoid use of statement; use modern Clean ABAP construct instead' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_BREAK'
                                                                value = REF #( mv_check_break ) )
                                                              ( name  = 'CHECK_STATICS'
                                                                value = REF #( mv_check_statics ) )
                                                              ( name  = 'CHECK_DEFINE'
                                                                value = REF #( mv_check_define ) )
                                                              ( name  = 'CHECK_EXPORT_MEMORY'
                                                                value = REF #( mv_check_export_memory ) )
                                                              ( name  = 'CHECK_EXPORT_DATABASE'
                                                                value = REF #( mv_check_export_database ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     mv_check_break = abap_true
         AND ( <ls_statement>-keyword = 'BREAK-POINT' OR <ls_statement>-keyword = 'BREAK' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF mv_check_statics = abap_true AND <ls_statement>-keyword = 'STATICS'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF mv_check_define = abap_true AND <ls_statement>-keyword = 'DEFINE'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF     mv_check_export_memory = abap_true
         AND <ls_statement>-keyword = 'EXPORT'
         AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                        it_expected  = VALUE #( ( `TO` ) ( `MEMORY` ) ) ) > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF     mv_check_export_database = abap_true
         AND <ls_statement>-keyword = 'EXPORT'
         AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                        it_expected  = VALUE #( ( `TO` ) ( `DATABASE` ) ) ) > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
