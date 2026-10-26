CLASS zcl_skylint_max_npath DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        npath_complexity TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_NPATH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_stack_frame,
        kind                 TYPE string,
        current_npath        TYPE i,
        branch_paths_sum     TYPE i,
        branch_count         TYPE i,
        curr_branch_bool_ops TYPE i,
        has_else             TYPE abap_bool,
      END OF ty_stack_frame,
      ty_stack_frames TYPE STANDARD TABLE OF ty_stack_frame WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_NPATH'.

    DATA mv_max_npath TYPE i VALUE 200.

    METHODS calculate_npath
      IMPORTING is_procedure    TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_npath) TYPE i.

    METHODS handle_if
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  ct_stack     TYPE ty_stack_frames.

    METHODS handle_elseif_else
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  ct_stack     TYPE ty_stack_frames.

    METHODS handle_endif
      CHANGING ct_stack TYPE ty_stack_frames.

    METHODS handle_case
      CHANGING ct_stack TYPE ty_stack_frames.

    METHODS handle_when
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  ct_stack     TYPE ty_stack_frames.

    METHODS handle_endcase
      CHANGING ct_stack TYPE ty_stack_frames.

    METHODS handle_loop
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  ct_stack     TYPE ty_stack_frames.

    METHODS handle_endloop
      CHANGING ct_stack TYPE ty_stack_frames.

    METHODS handle_try_catch
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  ct_stack     TYPE ty_stack_frames.

    METHODS handle_endtry
      CHANGING ct_stack TYPE ty_stack_frames.

    METHODS count_bool_ops
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_bool_ops) TYPE i.

    METHODS multiply_safe
      IMPORTING iv_a          TYPE i
                iv_b          TYPE i
      RETURNING VALUE(rv_res) TYPE i.

ENDCLASS.


CLASS zcl_skylint_max_npath IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit NPath complexity per procedure'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-npath_complexity
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Procedure NPath complexity exceeds threshold'
                                                pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_NPATH'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_npath ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_npath      TYPE i.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_npath = calculate_npath( is_procedure ).

    IF lv_npath <= mv_max_npath.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-npath_complexity ).
    ENDIF.
  ENDMETHOD.

  METHOD calculate_npath.
    DATA lt_stack TYPE ty_stack_frames.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_frame>     TYPE ty_stack_frame.

    APPEND VALUE ty_stack_frame( kind          = 'ROOT'
                                 current_npath = 1 ) TO lt_stack.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF'.
          handle_if( EXPORTING is_statement = <ls_statement>
                     CHANGING  ct_stack     = lt_stack ).
        WHEN 'ELSEIF' OR 'ELSE'.
          handle_elseif_else( EXPORTING is_statement = <ls_statement>
                              CHANGING  ct_stack     = lt_stack ).
        WHEN 'ENDIF'.
          handle_endif( CHANGING ct_stack = lt_stack ).
        WHEN 'CASE'.
          handle_case( CHANGING ct_stack = lt_stack ).
        WHEN 'WHEN'.
          handle_when( EXPORTING is_statement = <ls_statement>
                       CHANGING  ct_stack     = lt_stack ).
        WHEN 'ENDCASE'.
          handle_endcase( CHANGING ct_stack = lt_stack ).
        WHEN 'LOOP' OR 'WHILE' OR 'DO'.
          handle_loop( EXPORTING is_statement = <ls_statement>
                       CHANGING  ct_stack     = lt_stack ).
        WHEN 'ENDLOOP' OR 'ENDWHILE' OR 'ENDDO'.
          handle_endloop( CHANGING ct_stack = lt_stack ).
        WHEN 'TRY' OR 'CATCH' OR 'CLEANUP'.
          handle_try_catch( EXPORTING is_statement = <ls_statement>
                            CHANGING  ct_stack     = lt_stack ).
        WHEN 'ENDTRY'.
          handle_endtry( CHANGING ct_stack = lt_stack ).
      ENDCASE.
    ENDLOOP.

    ASSIGN lt_stack[ 1 ] TO <ls_frame>.
    IF sy-subrc = 0.
      rv_npath = <ls_frame>-current_npath.
    ELSE.
      rv_npath = 1.
    ENDIF.

    IF rv_npath < 1.
      rv_npath = 1.
    ENDIF.
  ENDMETHOD.

  METHOD handle_if.
    DATA lv_bool_ops TYPE i.

    lv_bool_ops = count_bool_ops( is_statement ).
    APPEND VALUE ty_stack_frame( kind                 = 'IF'
                                 current_npath        = 1
                                 branch_paths_sum     = 0
                                 curr_branch_bool_ops = lv_bool_ops
                                 has_else             = abap_false ) TO ct_stack.
  ENDMETHOD.

  METHOD handle_elseif_else.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_frame> TYPE ty_stack_frame.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind <> 'IF'.
      RETURN.
    ENDIF.

    <ls_frame>-branch_paths_sum += <ls_frame>-current_npath + <ls_frame>-curr_branch_bool_ops.
    <ls_frame>-current_npath     = 1.

    IF is_statement-keyword = 'ELSEIF'.
      <ls_frame>-curr_branch_bool_ops = count_bool_ops( is_statement ).
    ELSE.
      <ls_frame>-curr_branch_bool_ops = 0.
      <ls_frame>-has_else             = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD handle_endif.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    FIELD-SYMBOLS <ls_frame>  TYPE ty_stack_frame.
    FIELD-SYMBOLS <ls_parent> TYPE ty_stack_frame.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind <> 'IF'.
      RETURN.
    ENDIF.

    <ls_frame>-branch_paths_sum += <ls_frame>-current_npath + <ls_frame>-curr_branch_bool_ops.
    IF <ls_frame>-has_else = abap_false.
      <ls_frame>-branch_paths_sum += 1.
    ENDIF.
    lv_total = <ls_frame>-branch_paths_sum.
    DELETE ct_stack INDEX lv_idx.

    lv_idx = lines( ct_stack ).
    IF lv_idx > 0.
      ASSIGN ct_stack[ lv_idx ] TO <ls_parent>.
      <ls_parent>-current_npath = multiply_safe( iv_a = <ls_parent>-current_npath
                                                 iv_b = lv_total ).
    ENDIF.
  ENDMETHOD.

  METHOD handle_case.
    APPEND VALUE ty_stack_frame( kind             = 'CASE'
                                 current_npath    = 1
                                 branch_paths_sum = 0
                                 branch_count     = 0
                                 has_else         = abap_false ) TO ct_stack.
  ENDMETHOD.

  METHOD handle_when.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_frame> TYPE ty_stack_frame.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind <> 'CASE'.
      RETURN.
    ENDIF.

    IF <ls_frame>-branch_count > 0.
      <ls_frame>-branch_paths_sum += <ls_frame>-current_npath + <ls_frame>-curr_branch_bool_ops.
      <ls_frame>-current_npath     = 1.
    ENDIF.

    <ls_frame>-branch_count         += 1.
    <ls_frame>-curr_branch_bool_ops  = count_bool_ops( is_statement ).
    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'OTHERS' ) = abap_true.
      <ls_frame>-has_else = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD handle_endcase.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    FIELD-SYMBOLS <ls_frame>  TYPE ty_stack_frame.
    FIELD-SYMBOLS <ls_parent> TYPE ty_stack_frame.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind <> 'CASE'.
      RETURN.
    ENDIF.

    IF <ls_frame>-branch_count > 0.
      <ls_frame>-branch_paths_sum += <ls_frame>-current_npath + <ls_frame>-curr_branch_bool_ops.
    ENDIF.
    IF <ls_frame>-has_else = abap_false.
      <ls_frame>-branch_paths_sum += 1.
    ENDIF.
    IF <ls_frame>-branch_paths_sum = 0.
      <ls_frame>-branch_paths_sum = 1.
    ENDIF.
    lv_total = <ls_frame>-branch_paths_sum.
    DELETE ct_stack INDEX lv_idx.

    lv_idx = lines( ct_stack ).
    IF lv_idx > 0.
      ASSIGN ct_stack[ lv_idx ] TO <ls_parent>.
      <ls_parent>-current_npath = multiply_safe( iv_a = <ls_parent>-current_npath
                                                 iv_b = lv_total ).
    ENDIF.
  ENDMETHOD.

  METHOD handle_loop.
    DATA lv_bool_ops TYPE i.

    lv_bool_ops = count_bool_ops( is_statement ).
    APPEND VALUE ty_stack_frame( kind                 = 'LOOP'
                                 current_npath        = 1
                                 curr_branch_bool_ops = lv_bool_ops ) TO ct_stack.
  ENDMETHOD.

  METHOD handle_endloop.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    FIELD-SYMBOLS <ls_frame>  TYPE ty_stack_frame.
    FIELD-SYMBOLS <ls_parent> TYPE ty_stack_frame.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind <> 'LOOP'.
      RETURN.
    ENDIF.

    lv_total = <ls_frame>-current_npath + 1 + <ls_frame>-curr_branch_bool_ops.
    DELETE ct_stack INDEX lv_idx.

    lv_idx = lines( ct_stack ).
    IF lv_idx > 0.
      ASSIGN ct_stack[ lv_idx ] TO <ls_parent>.
      <ls_parent>-current_npath = multiply_safe( iv_a = <ls_parent>-current_npath
                                                 iv_b = lv_total ).
    ENDIF.
  ENDMETHOD.

  METHOD handle_try_catch.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_frame> TYPE ty_stack_frame.

    IF is_statement-keyword = 'TRY'.
      APPEND VALUE ty_stack_frame( kind             = 'TRY'
                                   current_npath    = 1
                                   branch_paths_sum = 0
                                   branch_count     = 0 ) TO ct_stack.
      RETURN.
    ENDIF.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind = 'TRY'.
      <ls_frame>-branch_paths_sum += <ls_frame>-current_npath.
      <ls_frame>-current_npath     = 1.
      <ls_frame>-branch_count     += 1.
    ENDIF.
  ENDMETHOD.

  METHOD handle_endtry.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    FIELD-SYMBOLS <ls_frame>  TYPE ty_stack_frame.
    FIELD-SYMBOLS <ls_parent> TYPE ty_stack_frame.

    lv_idx = lines( ct_stack ).
    IF lv_idx = 0.
      RETURN.
    ENDIF.
    ASSIGN ct_stack[ lv_idx ] TO <ls_frame>.
    IF <ls_frame>-kind <> 'TRY'.
      RETURN.
    ENDIF.

    <ls_frame>-branch_paths_sum += <ls_frame>-current_npath.
    IF <ls_frame>-branch_paths_sum = 0.
      <ls_frame>-branch_paths_sum = 1.
    ENDIF.
    lv_total = <ls_frame>-branch_paths_sum.
    DELETE ct_stack INDEX lv_idx.

    lv_idx = lines( ct_stack ).
    IF lv_idx > 0.
      ASSIGN ct_stack[ lv_idx ] TO <ls_parent>.
      <ls_parent>-current_npath = multiply_safe( iv_a = <ls_parent>-current_npath
                                                 iv_b = lv_total ).
    ENDIF.
  ENDMETHOD.

  METHOD count_bool_ops.
    DATA ls_token   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_between TYPE abap_bool.

    rv_bool_ops = 0.
    lv_between = abap_false.

    LOOP AT is_statement-tokens INTO ls_token WHERE references IS INITIAL.
      CASE ls_token-lexeme.
        WHEN 'BETWEEN'.
          lv_between = abap_true.
        WHEN 'AND'.
          IF lv_between = abap_true.
            lv_between = abap_false.
          ELSE.
            rv_bool_ops += 1.
          ENDIF.
        WHEN 'OR'.
          rv_bool_ops += 1.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD multiply_safe.
    IF iv_a = 0 OR iv_b = 0.
      rv_res = 0.
      RETURN.
    ENDIF.

    IF iv_a > 1000000 / iv_b.
      rv_res = 1000000.
    ELSE.
      rv_res = iv_a * iv_b.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
