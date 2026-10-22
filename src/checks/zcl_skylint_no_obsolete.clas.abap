CLASS zcl_skylint_no_obsolete DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'OBSOLETE',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        replace_obsolete TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLACE_OB',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OBSOLETE'.

    DATA mv_check_move           TYPE abap_bool VALUE abap_true.
    DATA mv_check_refresh        TYPE abap_bool VALUE abap_true.
    DATA mv_check_compute        TYPE abap_bool VALUE abap_true.
    DATA mv_check_tables         TYPE abap_bool VALUE abap_true.
    DATA mv_check_field_groups   TYPE abap_bool VALUE abap_true.
    DATA mv_check_test_seams     TYPE abap_bool VALUE abap_true.
    DATA mv_check_break          TYPE abap_bool VALUE abap_true.
    DATA mv_check_statics        TYPE abap_bool VALUE abap_true.
    DATA mv_check_define         TYPE abap_bool VALUE abap_true.
    DATA mv_check_export_memory  TYPE abap_bool VALUE abap_true.
    DATA mv_check_form           TYPE abap_bool VALUE abap_true.
    DATA mv_check_loop_ctl       TYPE abap_bool VALUE abap_true.
    DATA mv_check_add            TYPE abap_bool VALUE abap_true.
    DATA mv_check_add_corr       TYPE abap_bool VALUE abap_true.
    DATA mv_check_type_pools     TYPE abap_bool VALUE abap_true.
    DATA mv_check_ranges         TYPE abap_bool VALUE abap_true.
    DATA mv_check_header_line    TYPE abap_bool VALUE abap_true.
    DATA mv_check_load           TYPE abap_bool VALUE abap_true.
    DATA mv_check_pack           TYPE abap_bool VALUE abap_true.
    DATA mv_check_unpack         TYPE abap_bool VALUE abap_true.
    DATA mv_check_extract        TYPE abap_bool VALUE abap_true.
    DATA mv_check_common_part    TYPE abap_bool VALUE abap_true.
    DATA mv_check_free_memory    TYPE abap_bool VALUE abap_true.
    DATA mv_check_provide        TYPE abap_bool VALUE abap_true.
    DATA mv_check_contexts       TYPE abap_bool VALUE abap_true.
    DATA mv_check_initial_size   TYPE abap_bool VALUE abap_true.
    DATA mv_check_catch_system   TYPE abap_bool VALUE abap_true.
    DATA mv_check_get_reference  TYPE abap_bool VALUE abap_true.
    DATA mv_check_infotypes      TYPE abap_bool VALUE abap_true.
    DATA mv_check_communication  TYPE abap_bool VALUE abap_true.
    DATA mv_check_set_ext_check  TYPE abap_bool VALUE abap_true.
    DATA mv_check_occurs         TYPE abap_bool VALUE abap_true.
    DATA mv_check_fs_structure   TYPE abap_bool VALUE abap_true.
    DATA mv_check_parameter      TYPE abap_bool VALUE abap_true.
    DATA mv_check_select_no_into TYPE abap_bool VALUE abap_true.
    DATA mv_check_exit_sql       TYPE abap_bool VALUE abap_true.
    DATA mv_check_sort_by_fs     TYPE abap_bool VALUE abap_true.
    DATA mv_check_call_transf    TYPE abap_bool VALUE abap_true.
    DATA mv_check_regex          TYPE abap_bool VALUE abap_true.
    DATA mv_check_occurences     TYPE abap_bool VALUE abap_true.
    DATA mv_check_replace_into   TYPE abap_bool VALUE abap_true.
    DATA mv_check_loop_extract   TYPE abap_bool VALUE abap_true.
    DATA mv_check_sort_extract   TYPE abap_bool VALUE abap_true.

    METHODS check_with_quickfix
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_is_match  TYPE abap_bool
                ev_line      TYPE string.

    METHODS check_obsolete_constructs
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_loop_controls
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_additional_constructs
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS build_arithmetic_line
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

    METHODS select_without_into
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS select_is_count_star
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS sort_by_field_symbol
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS sort_is_dataset
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS uses_posix_api
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_obsolete IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete statements (MOVE, REFRESH, FORM, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_statement
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete or deprecated statement; use modern Clean ABAP construct'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-replace_obsolete
                                                short_text = 'Replace obsolete statement' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_MOVE'
                                                value = REF #( mv_check_move ) )
                                              ( name  = 'CHECK_REFRESH'
                                                value = REF #( mv_check_refresh ) )
                                              ( name  = 'CHECK_COMPUTE'
                                                value = REF #( mv_check_compute ) )
                                              ( name  = 'CHECK_TABLES'
                                                value = REF #( mv_check_tables ) )
                                              ( name  = 'CHECK_FIELD_GROUPS'
                                                value = REF #( mv_check_field_groups ) )
                                              ( name  = 'CHECK_TEST_SEAMS'
                                                value = REF #( mv_check_test_seams ) )
                                              ( name  = 'CHECK_BREAK'
                                                value = REF #( mv_check_break ) )
                                              ( name  = 'CHECK_STATICS'
                                                value = REF #( mv_check_statics ) )
                                              ( name  = 'CHECK_DEFINE'
                                                value = REF #( mv_check_define ) )
                                              ( name  = 'CHECK_EXPORT_MEMORY'
                                                value = REF #( mv_check_export_memory ) )
                                              ( name  = 'CHECK_FORM'
                                                value = REF #( mv_check_form ) )
                                              ( name  = 'CHECK_LOOP_CTL'
                                                value = REF #( mv_check_loop_ctl ) )
                                              ( name  = 'CHECK_ADD'
                                                value = REF #( mv_check_add ) )
                                              ( name  = 'CHECK_ADD_CORR'
                                                value = REF #( mv_check_add_corr ) )
                                              ( name  = 'CHECK_TYPE_POOLS'
                                                value = REF #( mv_check_type_pools ) )
                                              ( name  = 'CHECK_RANGES'
                                                value = REF #( mv_check_ranges ) )
                                              ( name  = 'CHECK_HEADER_LINE'
                                                value = REF #( mv_check_header_line ) )
                                              ( name  = 'CHECK_LOAD'
                                                value = REF #( mv_check_load ) )
                                              ( name  = 'CHECK_PACK'
                                                value = REF #( mv_check_pack ) )
                                              ( name  = 'CHECK_UNPACK'
                                                value = REF #( mv_check_unpack ) )
                                              ( name  = 'CHECK_EXTRACT'
                                                value = REF #( mv_check_extract ) )
                                              ( name  = 'CHECK_COMMON_PART'
                                                value = REF #( mv_check_common_part ) )
                                              ( name  = 'CHECK_FREE_MEMORY'
                                                value = REF #( mv_check_free_memory ) )
                                              ( name  = 'CHECK_PROVIDE'
                                                value = REF #( mv_check_provide ) )
                                              ( name  = 'CHECK_CONTEXTS'
                                                value = REF #( mv_check_contexts ) )
                                              ( name  = 'CHECK_INITIAL_SIZE'
                                                value = REF #( mv_check_initial_size ) )
                                              ( name  = 'CHECK_CATCH_SYSTEM'
                                                value = REF #( mv_check_catch_system ) )
                                              ( name  = 'CHECK_GET_REFERENCE'
                                                value = REF #( mv_check_get_reference ) )
                                              ( name  = 'CHECK_INFOTYPES'
                                                value = REF #( mv_check_infotypes ) )
                                              ( name  = 'CHECK_COMMUNICATION'
                                                value = REF #( mv_check_communication ) )
                                              ( name  = 'CHECK_SET_EXT_CHECK'
                                                value = REF #( mv_check_set_ext_check ) )
                                              ( name  = 'CHECK_OCCURS'
                                                value = REF #( mv_check_occurs ) )
                                              ( name  = 'CHECK_FS_STRUCTURE'
                                                value = REF #( mv_check_fs_structure ) )
                                              ( name  = 'CHECK_PARAMETER'
                                                value = REF #( mv_check_parameter ) )
                                              ( name  = 'CHECK_SELECT_NO_INTO'
                                                value = REF #( mv_check_select_no_into ) )
                                              ( name  = 'CHECK_EXIT_SQL'
                                                value = REF #( mv_check_exit_sql ) )
                                              ( name  = 'CHECK_SORT_BY_FS'
                                                value = REF #( mv_check_sort_by_fs ) )
                                              ( name  = 'CHECK_CALL_TRANSF'
                                                value = REF #( mv_check_call_transf ) )
                                              ( name  = 'CHECK_REGEX'
                                                value = REF #( mv_check_regex ) )
                                              ( name  = 'CHECK_OCCURENCES'
                                                value = REF #( mv_check_occurences ) )
                                              ( name  = 'CHECK_REPLACE_INTO'
                                                value = REF #( mv_check_replace_into ) )
                                              ( name  = 'CHECK_LOOP_EXTRACT'
                                                value = REF #( mv_check_loop_extract ) )
                                              ( name  = 'CHECK_SORT_EXTRACT'
                                                value = REF #( mv_check_sort_extract ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_is_match TYPE abap_bool.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.

      check_with_quickfix( EXPORTING is_statement = <ls_statement>
                           IMPORTING ev_is_match  = lv_is_match
                                     ev_line      = lv_line ).

      IF lv_is_match = abap_true.
        IF lv_line IS NOT INITIAL.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_obsolete
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line ) ) ).
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-obsolete_statement
                          is_quickfix     = ls_quickfix ).
        CONTINUE.
      ENDIF.

      IF    check_obsolete_constructs( <ls_statement> ) = abap_true
         OR check_loop_controls( <ls_statement> )       = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-obsolete_statement ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_with_quickfix.
    DATA lv_src TYPE string.
    DATA lv_dst TYPE string.

    ev_is_match = abap_false.
    CLEAR ev_line.

    CASE is_statement-keyword.
      WHEN 'GET'.
        IF     mv_check_get_reference = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `REFERENCE` ) ( `OF` ) ) ) > 0
           AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                       iv_lexeme    = 'INTO' ) = abap_true.

          ev_is_match = abap_true.
          lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                          iv_lexeme    = 'OF' )-lexeme.
          lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                          iv_lexeme    = 'INTO' )-lexeme.
          ev_line = |{ lv_dst } = REF #( { lv_src } ).|.
        ENDIF.
      WHEN 'MOVE'.
        IF mv_check_move = abap_true.
          ev_is_match = abap_true.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'TO' ) = abap_true.
            lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'MOVE' )-lexeme.
            lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'TO' )-lexeme.
            IF lv_src IS NOT INITIAL AND lv_dst IS NOT INITIAL.
              ev_line = |{ lv_dst } = { lv_src }.|.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'REFRESH'.
        IF mv_check_refresh = abap_true.
          ev_is_match = abap_true.
          lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                          iv_lexeme    = 'REFRESH' )-lexeme.
          IF lv_dst IS NOT INITIAL.
            ev_line = |CLEAR { lv_dst }.|.
          ENDIF.
        ENDIF.

      WHEN 'PARAMETER'.
        IF mv_check_parameter = abap_true.
          ev_is_match = abap_true.
          ev_line = condense( zcl_skylint_ast_util=>flatten_statement(
                                  is_statement = is_statement
                                  it_overrides = VALUE #( ( index  = 1
                                                            lexeme = 'PARAMETERS' ) )
                                  iv_suffix    = '.' ) ).
        ENDIF.

      WHEN 'COMPUTE'.
        IF     mv_check_compute = abap_true
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'COMPUTE' )  > 0.
          ev_line = condense( zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                                       it_deletions = VALUE #( ( 1 ) )
                                                                       iv_suffix    = '.' ) ).
          ev_is_match = abap_true.
        ENDIF.

      WHEN 'ADD' OR 'SUBTRACT' OR 'MULTIPLY' OR 'DIVIDE'.
        IF mv_check_add = abap_true.
          ev_is_match = abap_true.
          ev_line = build_arithmetic_line( is_statement ).
        ENDIF.

    ENDCASE.
  ENDMETHOD.

  METHOD build_arithmetic_line.
    DATA lv_src TYPE string.
    DATA lv_dst TYPE string.
    DATA lv_op  TYPE string.
    DATA lv_kw  TYPE string.

    CLEAR rv_line.
    lv_kw = is_statement-keyword.

    CASE lv_kw.
      WHEN 'ADD'.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'ADD' )-lexeme.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'TO' )-lexeme.
        lv_op = '+'.
      WHEN 'SUBTRACT'.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'SUBTRACT' )-lexeme.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'FROM' )-lexeme.
        lv_op = '-'.
      WHEN 'MULTIPLY'.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'MULTIPLY' )-lexeme.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'BY' )-lexeme.
        lv_op = '*'.
      WHEN 'DIVIDE'.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'DIVIDE' )-lexeme.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'BY' )-lexeme.
        lv_op = '/'.
    ENDCASE.

    IF lv_src IS NOT INITIAL AND lv_dst IS NOT INITIAL AND lv_op IS NOT INITIAL.
      rv_line = |{ lv_dst } = { lv_dst } { lv_op } { lv_src }.|.
    ENDIF.
  ENDMETHOD.

  METHOD check_obsolete_constructs.
    rv_is = abap_false.

    IF     mv_check_occurs = abap_true
       AND (    is_statement-keyword = 'DATA'
             OR is_statement-keyword = 'TYPES'
             OR is_statement-keyword = 'DESCRIBE'
             OR is_statement-keyword = 'RANGES' )
       AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                             iv_lexeme    = 'OCCURS' ) > 0.
      rv_is = abap_true.
      RETURN.
    ENDIF.

    CASE is_statement-keyword.
      WHEN 'PACK'.
        rv_is = mv_check_pack.

      WHEN 'UNPACK'.
        rv_is = mv_check_unpack.

      WHEN 'EXTRACT'.
        rv_is = mv_check_extract.

      WHEN 'PROVIDE' OR 'ENDPROVIDE'.
        rv_is = mv_check_provide.

      WHEN 'CONTEXTS' OR 'DEMAND' OR 'SUPPLY'.
        rv_is = mv_check_contexts.

      WHEN 'FREE'.
        IF     mv_check_free_memory = abap_true
           AND lines( is_statement-tokens ) = 2
           AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                       iv_lexeme    = 'MEMORY' )   = abap_true.
          rv_is = abap_true.
        ENDIF.

      WHEN 'CATCH'.
        IF     mv_check_catch_system = abap_true
           AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                       iv_lexeme    = 'SYSTEM-EXCEPTIONS' ) = abap_true.
          rv_is = abap_true.
        ENDIF.

      WHEN 'INFOTYPES'.
        rv_is = mv_check_infotypes.

      WHEN 'COMMUNICATION'.
        rv_is = mv_check_communication.

      WHEN 'SET'.
        IF     mv_check_set_ext_check = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `EXTENDED` ) ( `CHECK` ) ) ) > 0.
          rv_is = abap_true.
        ENDIF.

      WHEN 'TABLES'.
        rv_is = mv_check_tables.

      WHEN 'FIELD-GROUPS'.
        rv_is = mv_check_field_groups.

      WHEN 'FIELD-SYMBOLS' OR 'PARAMETER' OR 'SELECT' OR 'EXIT'
        OR 'SORT' OR 'CALL' OR 'FIND' OR 'REPLACE' OR 'LOOP'.
        rv_is = check_additional_constructs( is_statement ).

      WHEN 'TEST-SEAM' OR 'TEST-INJECT'.
        rv_is = mv_check_test_seams.

      WHEN 'BREAK-POINT' OR 'BREAK'.
        rv_is = mv_check_break.

      WHEN 'STATICS'.
        rv_is = mv_check_statics.

      WHEN 'DEFINE'.
        rv_is = mv_check_define.

      WHEN 'EXPORT'.
        IF     mv_check_export_memory = abap_true
           AND (    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                            iv_lexeme    = 'MEMORY' )   = abap_true
                 OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                            iv_lexeme    = 'DATABASE' ) = abap_true ).
          rv_is = abap_true.
        ENDIF.

      WHEN 'PERFORM' OR 'FORM'.
        rv_is = mv_check_form.

      WHEN 'ADD-CORRESPONDING' OR 'SUBTRACT-CORRESPONDING'
        OR 'MULTIPLY-CORRESPONDING' OR 'DIVIDE-CORRESPONDING'.
        rv_is = mv_check_add_corr.

      WHEN 'TYPE-POOLS'.
        rv_is = mv_check_type_pools.

      WHEN 'RANGES'.
        rv_is = mv_check_ranges.

      WHEN 'DATA'.
        IF     mv_check_header_line = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `WITH` ) ( `HEADER` ) ( `LINE` ) ) ) > 0.
          rv_is = abap_true.
        ENDIF.

        IF     mv_check_common_part = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `COMMON` ) ( `PART` ) ) ) > 0.
          rv_is = abap_true.
        ENDIF.

        IF     mv_check_initial_size = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `INITIAL` ) ( `SIZE` ) ) ) > 0.
          rv_is = abap_true.
          RETURN.
        ENDIF.

      WHEN 'CLASS' OR 'INTERFACE'.
        IF     mv_check_load = abap_true
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'LOAD' )     > 0.
          rv_is = abap_true.
        ENDIF.
    ENDCASE.

    IF mv_check_regex = abap_true AND uses_posix_api( is_statement ) = abap_true.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD check_additional_constructs.
    rv_is = abap_false.

    CASE is_statement-keyword.
      WHEN 'FIELD-SYMBOLS'.
        IF     mv_check_fs_structure = abap_true
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'STRUCTURE' ) > 0.
          rv_is = abap_true.
        ENDIF.

      WHEN 'PARAMETER'.
        rv_is = mv_check_parameter.

      WHEN 'SELECT'.
        IF     mv_check_select_no_into             = abap_true
           AND select_without_into( is_statement ) = abap_true.
          rv_is = abap_true.
        ENDIF.

      WHEN 'EXIT'.
        IF     mv_check_exit_sql = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `FROM` ) ( `SQL` ) ) ) > 0.
          rv_is = abap_true.
        ENDIF.

      WHEN 'SORT'.
        IF     mv_check_sort_by_fs                  = abap_true
           AND sort_by_field_symbol( is_statement ) = abap_true.
          rv_is = abap_true.
        ENDIF.
        IF     mv_check_sort_extract           = abap_true
           AND sort_is_dataset( is_statement ) = abap_true.
          rv_is = abap_true.
        ENDIF.

      WHEN 'CALL'.
        IF     mv_check_call_transf = abap_true
           AND zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `CALL` ) ( `TRANSFORMATION` ) ) ) > 0
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'OBJECTS' ) > 0.
          rv_is = abap_true.
        ENDIF.

      WHEN 'FIND' OR 'REPLACE'.
        IF     mv_check_regex = abap_true
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'REGEX' )    > 0.
          rv_is = abap_true.
        ENDIF.
        IF     mv_check_occurences = abap_true
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'OCCURENCES' ) > 0.
          rv_is = abap_true.
        ENDIF.
        IF     mv_check_replace_into = abap_true
           AND is_statement-keyword = 'REPLACE'
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'INTO' )     > 0.
          rv_is = abap_true.
        ENDIF.

      WHEN 'LOOP'.
        IF     mv_check_loop_extract = abap_true
           AND zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'AT' )       = 0.
          rv_is = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD select_without_into.
    rv_is = abap_false.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'INTO' )      = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'APPENDING' ) = abap_true.
      RETURN.
    ENDIF.

    IF select_is_count_star( is_statement ) = abap_true.
      RETURN.
    ENDIF.

    rv_is = abap_true.
  ENDMETHOD.

  METHOD select_is_count_star.
    DATA lv_lexeme TYPE string.
    DATA lv_next   TYPE string.
    DATA lv_next2  TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.
      IF strlen( lv_lexeme ) < 6 OR lv_lexeme(6) <> 'COUNT('.
        CONTINUE.
      ENDIF.
      IF    lv_lexeme(1) = ''''
         OR lv_lexeme(1) = '`'
         OR lv_lexeme(1) = '|'.
        CONTINUE.
      ENDIF.
      IF contains( val = lv_lexeme
                   sub = '*' ).
        rv_is = abap_true.
        RETURN.
      ENDIF.
      lv_next  = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = sy-tabix + 1 ).
      lv_next2 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = sy-tabix + 2 ).
      IF lv_next = '*' AND lv_next2 = ')'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sort_by_field_symbol.
    DATA lv_index  TYPE i.
    DATA lv_count  TYPE i.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    lv_index = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'BY' ).
    IF lv_index = 0.
      RETURN.
    ENDIF.

    lv_count = lines( is_statement-tokens ).
    lv_index += 1.
    WHILE lv_index <= lv_count.
      ASSIGN is_statement-tokens[ lv_index ] TO <ls_token>.
      lv_lexeme = <ls_token>-lexeme.
      IF strlen( lv_lexeme ) >= 2 AND lv_lexeme(1) = '<'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
      lv_index += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD sort_is_dataset.
    DATA lv_second TYPE string.

    rv_is = abap_false.
    lv_second = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = 2 ).
    IF lv_second IS INITIAL OR lv_second = 'BY' OR lv_second = 'AS'.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD uses_posix_api.
    DATA lv_full_name TYPE string.
    DATA lv_lexeme    TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_is = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
          CONTINUE.
        ENDIF.
        lv_full_name = to_upper( <ls_ref>-full_name ).
        IF    lv_full_name = '\TY:CL_ABAP_REGEX\ME:CREATE_POSIX'
           OR (     lv_full_name CP '\TY:CL_ABAP_MATCHER\ME:*'
                AND contains( val = lv_full_name
                              sub = 'POSIX' ) ).
          rv_is = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = to_upper( <ls_token>-lexeme ).
      IF    lv_lexeme CP 'CL_ABAP_REGEX=>CREATE_POSIX*'
         OR lv_lexeme CP 'CL_ABAP_MATCHER=>*POSIX*'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_loop_controls.
    rv_is = abap_false.
    IF mv_check_loop_ctl = abap_false.
      RETURN.
    ENDIF.

    CASE is_statement-keyword.
      WHEN 'SUM'.
        rv_is = abap_true.

      WHEN 'ON'.
        IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                             iv_lexeme    = 'CHANGE' ) > 0.
          rv_is = abap_true.
        ENDIF.

      WHEN 'AT'.
        IF    zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                iv_lexeme    = 'NEW' )      > 0
           OR zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                iv_lexeme    = 'END' )      > 0
           OR zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                iv_lexeme    = 'FIRST' )    > 0
           OR zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                iv_lexeme    = 'LAST' )     > 0.
          rv_is = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
