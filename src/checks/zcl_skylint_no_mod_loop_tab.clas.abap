CLASS zcl_skylint_no_mod_loop_tab DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        modify_loop_table TYPE if_ci_atc_check=>ty_finding_code VALUE 'MOD_LOOPTB',
        sort_in_loop      TYPE if_ci_atc_check=>ty_finding_code VALUE 'SORT_INLP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_loop_contexts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'LOOP_MODIFY'.

    DATA mv_check_append   TYPE abap_bool VALUE abap_true.
    DATA mv_check_insert   TYPE abap_bool VALUE abap_true.
    DATA mv_check_modify   TYPE abap_bool VALUE abap_true.
    DATA mv_check_delete   TYPE abap_bool VALUE abap_true.
    DATA mv_check_clear    TYPE abap_bool VALUE abap_true.
    DATA mv_check_sort     TYPE abap_bool VALUE abap_true.
    DATA mv_check_sort_any TYPE abap_bool VALUE abap_true.
    DATA mv_check_collect  TYPE abap_bool VALUE abap_true.

    METHODS get_loop_table
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_full_name) TYPE string.

    METHODS get_target_table_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    METHODS get_token_full_name
      IMPORTING is_token            TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_full_name) TYPE string.

    METHODS is_loop_table_target
      IMPORTING is_target_token   TYPE if_ci_atc_source_code_provider=>ty_token
                it_loop_stack     TYPE ty_loop_contexts
      RETURNING VALUE(rv_matches) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_mod_loop_tab IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutating or sorting tables inside loops'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-modify_loop_table
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Do not add, delete, sort, collect, or clear rows from the table currently being looped'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-sort_in_loop
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid sorting internal tables inside loops to prevent severe performance degradation'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                               ( name  = 'CHECK_APPEND'
                                                 value = REF #( mv_check_append ) )
                                               ( name  = 'CHECK_INSERT'
                                                 value = REF #( mv_check_insert ) )
                                               ( name  = 'CHECK_MODIFY'
                                                 value = REF #( mv_check_modify ) )
                                               ( name  = 'CHECK_DELETE'
                                                 value = REF #( mv_check_delete ) )
                                               ( name  = 'CHECK_CLEAR'
                                                 value = REF #( mv_check_clear ) )
                                               ( name  = 'CHECK_SORT'
                                                 value = REF #( mv_check_sort ) )
                                               ( name  = 'CHECK_SORT_ANY'
                                                 value = REF #( mv_check_sort_any ) )
                                               ( name  = 'CHECK_COLLECT'
                                                 value = REF #( mv_check_collect ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_loop_stack     TYPE ty_loop_contexts.
    DATA lv_loop_full_name TYPE string.
    DATA ls_target_token   TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP'.
          lv_loop_full_name = get_loop_table( <ls_statement> ).
          APPEND lv_loop_full_name TO lt_loop_stack.

        WHEN 'ENDLOOP'.
          IF lt_loop_stack IS NOT INITIAL.
            DELETE lt_loop_stack INDEX lines( lt_loop_stack ).
          ENDIF.

        WHEN 'APPEND'.
          IF mv_check_append = abap_true AND lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_loop_table ).
            ENDIF.
          ENDIF.

        WHEN 'INSERT'.
          IF mv_check_insert = abap_true AND lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_loop_table ).
            ENDIF.
          ENDIF.

        WHEN 'MODIFY'.
          IF mv_check_modify = abap_true AND lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_loop_table ).
            ENDIF.
          ENDIF.

        WHEN 'DELETE'.
          IF mv_check_delete = abap_true AND lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_loop_table ).
            ENDIF.
          ENDIF.

        WHEN 'CLEAR' OR 'FREE'.
          IF mv_check_clear = abap_true AND lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_loop_table ).
            ENDIF.
          ENDIF.

        WHEN 'COLLECT'.
          IF mv_check_collect = abap_true AND lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_loop_table ).
            ENDIF.
          ENDIF.

        WHEN 'SORT'.
          IF lt_loop_stack IS NOT INITIAL.
            ls_target_token = get_target_table_token( <ls_statement> ).
            IF is_loop_table_target( is_target_token = ls_target_token
                                     it_loop_stack   = lt_loop_stack ) = abap_true.
              IF mv_check_sort = abap_true.
                report_statement( is_statement    = <ls_statement>
                                  iv_finding_code = c_finding_codes-modify_loop_table ).
              ENDIF.
            ELSEIF mv_check_sort_any = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-sort_in_loop ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_loop_table.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_full_name.

    ls_tok = zcl_skylint_ast_util=>get_token_after_sequence(
                 is_statement = is_statement
                 it_expected  = VALUE #( ( `LOOP` ) ( `AT` ) ) ).
    IF ls_tok-lexeme IS INITIAL OR ls_tok-lexeme = 'GROUP'.
      RETURN.
    ENDIF.

    rv_full_name = get_token_full_name( ls_tok ).
  ENDMETHOD.

  METHOD get_target_table_token.
    CLEAR rs_token.

    CASE is_statement-keyword.
      WHEN 'APPEND'.
        rs_token = zcl_skylint_ast_util=>get_token_after(
                       is_statement = is_statement
                       iv_lexeme    = 'TO' ).

      WHEN 'INSERT'.
        rs_token = zcl_skylint_ast_util=>get_token_after_sequence(
                       is_statement = is_statement
                       it_expected  = VALUE #( ( `INTO` ) ( `TABLE` ) ) ).
        IF rs_token-lexeme IS INITIAL.
          rs_token = zcl_skylint_ast_util=>get_token_after(
                         is_statement = is_statement
                         iv_lexeme    = 'INTO' ).
        ENDIF.

      WHEN 'MODIFY'.
        rs_token = zcl_skylint_ast_util=>get_token_after_sequence(
                       is_statement = is_statement
                       it_expected  = VALUE #( ( `MODIFY` ) ( `TABLE` ) ) ).
        IF rs_token-lexeme IS INITIAL.
          rs_token = zcl_skylint_ast_util=>get_token_after(
                         is_statement = is_statement
                         iv_lexeme    = 'MODIFY' ).
        ENDIF.

      WHEN 'DELETE'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'ADJACENT' ) = abap_true.
          rs_token = zcl_skylint_ast_util=>get_token_after(
                         is_statement = is_statement
                         iv_lexeme    = 'FROM' ).
        ELSE.
          rs_token = zcl_skylint_ast_util=>get_token_after_sequence(
                         is_statement = is_statement
                         it_expected  = VALUE #( ( `DELETE` ) ( `TABLE` ) ) ).

          IF rs_token-lexeme IS INITIAL.
            rs_token = zcl_skylint_ast_util=>get_token_after(
                           is_statement = is_statement
                           iv_lexeme    = 'DELETE' ).
          ENDIF.
        ENDIF.

      WHEN 'CLEAR' OR 'FREE'.
        rs_token = zcl_skylint_ast_util=>get_token_after(
                       is_statement = is_statement
                       iv_lexeme    = is_statement-keyword ).

      WHEN 'SORT'.
        rs_token = zcl_skylint_ast_util=>get_token_after(
                       is_statement = is_statement
                       iv_lexeme    = 'SORT' ).

      WHEN 'COLLECT'.
        rs_token = zcl_skylint_ast_util=>get_token_after(
                       is_statement = is_statement
                       iv_lexeme    = 'INTO' ).
    ENDCASE.
  ENDMETHOD.

  METHOD get_token_full_name.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rv_full_name.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      IF <ls_ref>-full_name IS NOT INITIAL.
        rv_full_name = <ls_ref>-full_name.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_loop_table_target.
    DATA lv_target_full_name TYPE string.
    DATA lv_loop_full_name   TYPE string.

    rv_matches = abap_false.
    lv_target_full_name = get_token_full_name( is_target_token ).
    IF lv_target_full_name IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_loop_stack INTO lv_loop_full_name.
      IF lv_loop_full_name IS NOT INITIAL AND lv_target_full_name = lv_loop_full_name.
        rv_matches = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
