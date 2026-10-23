CLASS zcl_skylint_no_ident_cont DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_contents TYPE if_ci_atc_check=>ty_finding_code VALUE 'IDCONT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IDENT_CONT'.

    TYPES: BEGIN OF ty_branch,
             kind     TYPE string,
             from_idx TYPE i,
             to_idx   TYPE i,
           END OF ty_branch,
           ty_branches TYPE STANDARD TABLE OF ty_branch WITH NON-UNIQUE KEY kind.
    TYPES: BEGIN OF ty_frame,
             if_idx       TYPE i,
             current_kind TYPE string,
             current_from TYPE i,
             branches     TYPE ty_branches,
           END OF ty_frame,
           ty_frames TYPE STANDARD TABLE OF ty_frame WITH EMPTY KEY.

    METHODS evaluate_if
      IMPORTING is_frame      TYPE ty_frame
                it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS evaluate_elseif
      IMPORTING is_frame      TYPE ty_frame
                it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS is_same_statement
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_idx_a       TYPE i
                iv_idx_b       TYPE i
      RETURNING VALUE(rv_same) TYPE abap_bool.

    METHODS get_signature
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_sig) TYPE string.

    METHODS report_if
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_idx        TYPE i.

ENDCLASS.


CLASS zcl_skylint_no_ident_cont IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid identical code in IF and ELSE branches'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-identical_contents
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Identical statement in IF and ELSE branches; extract common code'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_frame  TYPE ty_frame.
    DATA ls_branch TYPE ty_branch.
    DATA lt_frames TYPE ty_frames.
    DATA lv_idx    TYPE i.
    DATA lv_top    TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'IF'.
          CLEAR ls_frame.
          ls_frame-if_idx       = lv_idx.
          ls_frame-current_kind = 'IF'.
          ls_frame-current_from = lv_idx + 1.
          APPEND ls_frame TO lt_frames.

        WHEN 'ELSEIF' OR 'ELSE'.
          lv_top = lines( lt_frames ).
          IF lv_top = 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_frames INDEX lv_top INTO ls_frame.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ls_branch = VALUE #( kind     = ls_frame-current_kind
                               from_idx = ls_frame-current_from
                               to_idx   = lv_idx - 1 ).
          APPEND ls_branch TO ls_frame-branches.
          IF <ls_statement>-keyword = 'ELSEIF'.
            ls_frame-current_kind = 'ELSEIF'.
          ELSE.
            ls_frame-current_kind = 'ELSE'.
          ENDIF.
          ls_frame-current_from = lv_idx + 1.
          MODIFY lt_frames INDEX lv_top FROM ls_frame.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

        WHEN 'ENDIF'.
          lv_top = lines( lt_frames ).
          IF lv_top = 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_frames INDEX lv_top INTO ls_frame.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ls_branch = VALUE #( kind     = ls_frame-current_kind
                               from_idx = ls_frame-current_from
                               to_idx   = lv_idx - 1 ).
          APPEND ls_branch TO ls_frame-branches.
          DELETE lt_frames INDEX lv_top.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          evaluate_if( is_frame      = ls_frame
                       it_statements = is_procedure-statements ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate_if.
    DATA ls_if_branch     TYPE ty_branch.
    DATA ls_else_branch   TYPE ty_branch.
    DATA lv_has_elseif    TYPE abap_bool.

    READ TABLE is_frame-branches INTO ls_if_branch WITH KEY kind = 'IF'.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE is_frame-branches INTO ls_else_branch WITH KEY kind = 'ELSE'.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF    ls_if_branch-from_idx   > ls_if_branch-to_idx
       OR ls_else_branch-from_idx > ls_else_branch-to_idx.
      RETURN.
    ENDIF.

    LOOP AT is_frame-branches TRANSPORTING NO FIELDS WHERE kind = 'ELSEIF'.
      lv_has_elseif = abap_true.
    ENDLOOP.

    IF lv_has_elseif = abap_true.
      evaluate_elseif( is_frame      = is_frame
                       it_statements = it_statements ).
      RETURN.
    ENDIF.

    IF is_same_statement( it_statements = it_statements
                          iv_idx_a      = ls_if_branch-from_idx
                          iv_idx_b      = ls_else_branch-from_idx ) = abap_true.
      report_if( it_statements = it_statements
                 iv_idx        = is_frame-if_idx ).
      RETURN.
    ENDIF.

    IF is_same_statement( it_statements = it_statements
                          iv_idx_a      = ls_if_branch-to_idx
                          iv_idx_b      = ls_else_branch-to_idx ) = abap_true.
      report_if( it_statements = it_statements
                 iv_idx        = is_frame-if_idx ).
    ENDIF.
  ENDMETHOD.

  METHOD evaluate_elseif.
    DATA ls_if_branch     TYPE ty_branch.
    DATA ls_else_branch   TYPE ty_branch.
    DATA ls_elseif_branch TYPE ty_branch.
    DATA lv_first_match   TYPE abap_bool.
    DATA lv_last_match    TYPE abap_bool.

    READ TABLE is_frame-branches INTO ls_if_branch WITH KEY kind = 'IF'.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE is_frame-branches INTO ls_else_branch WITH KEY kind = 'ELSE'.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_first_match = abap_true.
    lv_last_match = abap_true.

    LOOP AT is_frame-branches INTO ls_elseif_branch WHERE kind = 'ELSEIF'.
      IF ls_elseif_branch-from_idx > ls_elseif_branch-to_idx.
        RETURN.
      ENDIF.

      IF    is_same_statement( it_statements = it_statements
                               iv_idx_a      = ls_if_branch-from_idx
                               iv_idx_b      = ls_elseif_branch-from_idx ) = abap_false
         OR is_same_statement( it_statements = it_statements
                               iv_idx_a      = ls_else_branch-from_idx
                               iv_idx_b      = ls_elseif_branch-from_idx ) = abap_false.
        lv_first_match = abap_false.
      ENDIF.

      IF    is_same_statement( it_statements = it_statements
                               iv_idx_a      = ls_if_branch-to_idx
                               iv_idx_b      = ls_elseif_branch-to_idx ) = abap_false
         OR is_same_statement( it_statements = it_statements
                               iv_idx_a      = ls_else_branch-to_idx
                               iv_idx_b      = ls_elseif_branch-to_idx ) = abap_false.
        lv_last_match = abap_false.
      ENDIF.
    ENDLOOP.

    IF lv_first_match = abap_true OR lv_last_match = abap_true.
      report_if( it_statements = it_statements
                 iv_idx        = is_frame-if_idx ).
    ENDIF.
  ENDMETHOD.

  METHOD is_same_statement.
    DATA ls_stmt_a TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_b TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_sig_a  TYPE string.
    DATA lv_sig_b  TYPE string.

    rv_same = abap_false.
    IF    iv_idx_a < 1
       OR iv_idx_b < 1
       OR iv_idx_a > lines( it_statements )
       OR iv_idx_b > lines( it_statements ).
      RETURN.
    ENDIF.

    ls_stmt_a = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = iv_idx_a ).
    ls_stmt_b = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = iv_idx_b ).
    lv_sig_a = get_signature( ls_stmt_a ).
    lv_sig_b = get_signature( ls_stmt_b ).

    IF lv_sig_a IS NOT INITIAL AND lv_sig_a = lv_sig_b.
      rv_same = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_signature.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_sig.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme IS INITIAL OR <ls_token>-lexeme CP '##*'.
        CONTINUE.
      ENDIF.
      IF rv_sig IS INITIAL.
        rv_sig = <ls_token>-lexeme.
      ELSE.
        rv_sig = |{ rv_sig } { <ls_token>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD report_if.
    DATA ls_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                        iv_index      = iv_idx ).
    report_statement( is_statement    = ls_statement
                      iv_finding_code = c_finding_codes-identical_contents ).
  ENDMETHOD.
ENDCLASS.
