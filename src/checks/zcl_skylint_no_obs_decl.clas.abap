CLASS zcl_skylint_no_obs_decl DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_declaration TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_OBS_DCL',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        replace_declaration TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLACE_DC',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_OBS_DECL'.

    DATA mv_check_tables       TYPE abap_bool VALUE abap_true.
    DATA mv_check_type_pools   TYPE abap_bool VALUE abap_true.
    DATA mv_check_ranges       TYPE abap_bool VALUE abap_true.
    DATA mv_check_header_line  TYPE abap_bool VALUE abap_true.
    DATA mv_check_occurs       TYPE abap_bool VALUE abap_true.
    DATA mv_check_initial_size TYPE abap_bool VALUE abap_true.
    DATA mv_check_common_part  TYPE abap_bool VALUE abap_true.
    DATA mv_check_statics      TYPE abap_bool VALUE abap_true.
    DATA mv_check_fs_structure TYPE abap_bool VALUE abap_true.
    DATA mv_check_load         TYPE abap_bool VALUE abap_true.
    DATA mv_check_parameter    TYPE abap_bool VALUE abap_true.
    DATA mv_check_refresh      TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_obs_decl IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Obsolete Data and Type Declarations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_declaration
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete declaration constructs (TABLES, RANGES, TYPE-POOLS, etc.)'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-replace_declaration
                                                short_text = 'Replace obsolete declaration with modern equivalent' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_TABLES'
                                                value = REF #( mv_check_tables ) )
                                              ( name  = 'CHECK_TYPE_POOLS'
                                                value = REF #( mv_check_type_pools ) )
                                              ( name  = 'CHECK_RANGES'
                                                value = REF #( mv_check_ranges ) )
                                              ( name  = 'CHECK_HEADER_LINE'
                                                value = REF #( mv_check_header_line ) )
                                              ( name  = 'CHECK_OCCURS'
                                                value = REF #( mv_check_occurs ) )
                                              ( name  = 'CHECK_INITIAL_SIZE'
                                                value = REF #( mv_check_initial_size ) )
                                              ( name  = 'CHECK_COMMON_PART'
                                                value = REF #( mv_check_common_part ) )
                                              ( name  = 'CHECK_STATICS'
                                                value = REF #( mv_check_statics ) )
                                              ( name  = 'CHECK_FS_STRUCTURE'
                                                value = REF #( mv_check_fs_structure ) )
                                              ( name  = 'CHECK_LOAD'
                                                value = REF #( mv_check_load ) )
                                              ( name  = 'CHECK_PARAMETER'
                                                value = REF #( mv_check_parameter ) )
                                              ( name  = 'CHECK_REFRESH'
                                                value = REF #( mv_check_refresh ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA lv_dst      TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR: ls_quickfix,
             lv_line.

      IF     mv_check_occurs = abap_true
         AND (    <ls_statement>-keyword = 'DATA'
               OR <ls_statement>-keyword = 'TYPES'
               OR <ls_statement>-keyword = 'DESCRIBE'
               OR <ls_statement>-keyword = 'RANGES' )
         AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                               iv_lexeme    = 'OCCURS' ) > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-obsolete_declaration ).
        CONTINUE.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'TABLES'.
          IF mv_check_tables = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.

        WHEN 'TYPE-POOLS'.
          IF mv_check_type_pools = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.

        WHEN 'RANGES'.
          IF mv_check_ranges = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.

        WHEN 'STATICS'.
          IF mv_check_statics = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.

        WHEN 'REFRESH'.
          IF mv_check_refresh = abap_true.
            lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                            iv_lexeme    = 'REFRESH' )-lexeme.
            IF lv_dst IS NOT INITIAL.
              lv_line = |CLEAR { lv_dst }.|.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_declaration
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'PARAMETER'.
          IF mv_check_parameter = abap_true.
            lv_line = condense( zcl_skylint_ast_util=>flatten_statement(
                                    is_statement = <ls_statement>
                                    it_overrides = VALUE #( ( index  = 1
                                                              lexeme = 'PARAMETERS' ) )
                                    iv_suffix    = '.' ) ).
            IF lv_line IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_declaration
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'DATA'.
          IF     mv_check_header_line = abap_true
             AND zcl_skylint_ast_util=>find_token_sequence(
                     is_statement = <ls_statement>
                     it_expected  = VALUE #( ( `WITH` ) ( `HEADER` ) ( `LINE` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ELSEIF     mv_check_common_part = abap_true
                 AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                                it_expected  = VALUE #( ( `COMMON` ) ( `PART` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ELSEIF     mv_check_initial_size = abap_true
                 AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                                it_expected  = VALUE #( ( `INITIAL` ) ( `SIZE` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.

        WHEN 'FIELD-SYMBOLS'.
          IF     mv_check_fs_structure = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'STRUCTURE' )  > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.

        WHEN 'CLASS' OR 'INTERFACE'.
          IF     mv_check_load = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'LOAD' )       > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_declaration ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
