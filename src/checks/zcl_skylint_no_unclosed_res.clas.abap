CLASS zcl_skylint_no_unclosed_res DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unclosed_dataset TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_UNCL_DS',
        unclosed_cursor  TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_UNCL_CR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_open_resource,
        target_name TYPE string,
        stmt_index  TYPE i,
        statement   TYPE if_ci_atc_source_code_provider=>ty_statement,
      END OF ty_open_resource,
      ty_open_resources TYPE STANDARD TABLE OF ty_open_resource WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_close_resource,
        target_name TYPE string,
        stmt_index  TYPE i,
      END OF ty_close_resource,
      ty_close_resources TYPE STANDARD TABLE OF ty_close_resource WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_UNCLOSED_RES'.

    DATA mv_check_dataset TYPE abap_bool VALUE abap_true.
    DATA mv_check_cursor  TYPE abap_bool VALUE abap_true.

    METHODS extract_dataset_target
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_target) TYPE string.

    METHODS extract_cursor_target
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_target) TYPE string.

    METHODS normalize_target
      IMPORTING iv_lexeme            TYPE string
      RETURNING VALUE(rv_normalized) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_unclosed_res IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Ensure opened datasets and cursors are closed'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-unclosed_dataset
                                       text = 'OPEN DATASET is not closed; resource leak risk' )
                                     ( code = c_finding_codes-unclosed_cursor
                                       text = 'OPEN CURSOR is not closed; database cursor leak risk' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_DATASET'
                                                                value = REF #( mv_check_dataset ) )
                                                              ( name  = 'CHECK_CURSOR'
                                                                value = REF #( mv_check_cursor ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_open_datasets  TYPE ty_open_resources.
    DATA lt_close_datasets TYPE ty_close_resources.
    DATA lt_open_cursors   TYPE ty_open_resources.
    DATA lt_close_cursors  TYPE ty_close_resources.
    DATA lv_stmt_idx       TYPE i.
    DATA lv_target         TYPE string.
    DATA lv_is_closed      TYPE abap_bool.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_open>      TYPE ty_open_resource.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'OPEN'.
          IF mv_check_dataset = abap_true AND zcl_skylint_ast_util=>match_token_sequence(
                                                  is_statement = <ls_statement>
                                                  it_expected  = VALUE #( ( `OPEN` ) ( `DATASET` ) ) ) = abap_true.
            lv_target = extract_dataset_target( <ls_statement> ).
            IF lv_target IS NOT INITIAL.
              APPEND VALUE #( target_name = lv_target
                              stmt_index  = lv_stmt_idx
                              statement   = <ls_statement> ) TO lt_open_datasets.
            ENDIF.
          ELSEIF mv_check_cursor = abap_true AND zcl_skylint_ast_util=>match_token_sequence(
                                                     is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `OPEN` ) ( `CURSOR` ) ) ) = abap_true.
            lv_target = extract_cursor_target( <ls_statement> ).
            IF lv_target IS NOT INITIAL.
              APPEND VALUE #( target_name = lv_target
                              stmt_index  = lv_stmt_idx
                              statement   = <ls_statement> ) TO lt_open_cursors.
            ENDIF.
          ENDIF.

        WHEN 'CLOSE'.
          IF mv_check_dataset = abap_true AND zcl_skylint_ast_util=>match_token_sequence(
                                                  is_statement = <ls_statement>
                                                  it_expected  = VALUE #( ( `CLOSE` ) ( `DATASET` ) ) ) = abap_true.
            lv_target = extract_dataset_target( <ls_statement> ).
            IF lv_target IS NOT INITIAL.
              APPEND VALUE #( target_name = lv_target
                              stmt_index  = lv_stmt_idx ) TO lt_close_datasets.
            ENDIF.
          ELSEIF mv_check_cursor = abap_true AND zcl_skylint_ast_util=>match_token_sequence(
                                                     is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CLOSE` ) ( `CURSOR` ) ) ) = abap_true.
            lv_target = extract_cursor_target( <ls_statement> ).
            IF lv_target IS NOT INITIAL.
              APPEND VALUE #( target_name = lv_target
                              stmt_index  = lv_stmt_idx ) TO lt_close_cursors.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_open_datasets ASSIGNING <ls_open>.
      lv_is_closed = abap_false.
      LOOP AT lt_close_datasets TRANSPORTING NO FIELDS
           WHERE     target_name = <ls_open>-target_name
                 AND stmt_index  > <ls_open>-stmt_index.
        lv_is_closed = abap_true.
        EXIT.
      ENDLOOP.

      IF lv_is_closed = abap_false.
        report_statement( is_statement    = <ls_open>-statement
                          iv_finding_code = c_finding_codes-unclosed_dataset ).
      ENDIF.
    ENDLOOP.

    LOOP AT lt_open_cursors ASSIGNING <ls_open>.
      lv_is_closed = abap_false.
      LOOP AT lt_close_cursors TRANSPORTING NO FIELDS
           WHERE     target_name = <ls_open>-target_name
                 AND stmt_index  > <ls_open>-stmt_index.
        lv_is_closed = abap_true.
        EXIT.
      ENDLOOP.

      IF lv_is_closed = abap_false.
        report_statement( is_statement    = <ls_open>-statement
                          iv_finding_code = c_finding_codes-unclosed_cursor ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_dataset_target.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = 'DATASET' ).
    rv_target = normalize_target( ls_tok-lexeme ).
  ENDMETHOD.

  METHOD extract_cursor_target.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'HOLD' ) = abap_true.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'HOLD' ).
    ELSE.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'CURSOR' ).
    ENDIF.

    rv_target = normalize_target( ls_tok-lexeme ).
  ENDMETHOD.

  METHOD normalize_target.
    rv_normalized = to_upper( zcl_skylint_ast_util=>extract_name_from_paren( iv_lexeme ) ).
  ENDMETHOD.
ENDCLASS.
