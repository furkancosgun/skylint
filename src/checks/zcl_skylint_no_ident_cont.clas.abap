CLASS zcl_skylint_no_ident_cont DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_contents TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_IDN_CNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IDENT_CONT'.

    TYPES:
      BEGIN OF ty_branch,
        kind     TYPE string,
        from_idx TYPE i,
        to_idx   TYPE i,
      END OF ty_branch,
      ty_branches TYPE STANDARD TABLE OF ty_branch WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_frame,
        if_idx       TYPE i,
        current_kind TYPE string,
        current_from TYPE i,
        branches     TYPE ty_branches,
      END OF ty_frame,
      ty_frames TYPE STANDARD TABLE OF ty_frame WITH EMPTY KEY.

    METHODS evaluate_if
      IMPORTING is_frame      TYPE ty_frame
                it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS evaluate_all_branches
      IMPORTING is_frame      TYPE ty_frame
                it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS is_same_statement
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_idx_a       TYPE i
                iv_idx_b       TYPE i
      RETURNING VALUE(rv_same) TYPE abap_bool.

    METHODS is_extractable_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_ok) TYPE abap_bool.

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

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

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

          ASSIGN lt_frames[ lv_top ] TO FIELD-SYMBOL(<ls_current_frame>).
          ls_branch = VALUE #( kind     = <ls_current_frame>-current_kind
                               from_idx = <ls_current_frame>-current_from
                               to_idx   = lv_idx - 1 ).
          APPEND ls_branch TO <ls_current_frame>-branches.
          <ls_current_frame>-current_kind = <ls_statement>-keyword.
          <ls_current_frame>-current_from = lv_idx + 1.

        WHEN 'ENDIF'.
          lv_top = lines( lt_frames ).
          IF lv_top = 0.
            CONTINUE.
          ENDIF.

          ASSIGN lt_frames[ lv_top ] TO <ls_current_frame>.
          ls_branch = VALUE #( kind     = <ls_current_frame>-current_kind
                               from_idx = <ls_current_frame>-current_from
                               to_idx   = lv_idx - 1 ).
          APPEND ls_branch TO <ls_current_frame>-branches.
          ls_frame = <ls_current_frame>.
          DELETE lt_frames INDEX lv_top.

          evaluate_if( is_frame      = ls_frame
                       it_statements = is_procedure-statements ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate_if.
    IF    NOT line_exists( is_frame-branches[ kind = 'IF' ] )
       OR NOT line_exists( is_frame-branches[ kind = 'ELSE' ] ).
      RETURN.
    ENDIF.

    LOOP AT is_frame-branches ASSIGNING FIELD-SYMBOL(<ls_br>).
      IF <ls_br>-from_idx > <ls_br>-to_idx.
        RETURN.
      ENDIF.
    ENDLOOP.

    evaluate_all_branches( is_frame      = is_frame
                           it_statements = it_statements ).
  ENDMETHOD.

  METHOD evaluate_all_branches.
    DATA lv_first_same TYPE abap_bool VALUE abap_true.
    DATA lv_last_same  TYPE abap_bool VALUE abap_true.

    ASSIGN is_frame-branches[ 1 ] TO FIELD-SYMBOL(<ls_base_branch>).

    IF is_extractable_statement( it_statements[ <ls_base_branch>-from_idx ] ) = abap_false.
      lv_first_same = abap_false.
    ENDIF.

    IF is_extractable_statement( it_statements[ <ls_base_branch>-to_idx ] ) = abap_false.
      lv_last_same = abap_false.
    ENDIF.

    LOOP AT is_frame-branches ASSIGNING FIELD-SYMBOL(<ls_branch>) FROM 2.
      IF lv_first_same = abap_true AND is_same_statement( it_statements = it_statements
                                                          iv_idx_a      = <ls_base_branch>-from_idx
                                                          iv_idx_b      = <ls_branch>-from_idx ) = abap_false.
        lv_first_same = abap_false.
      ENDIF.

      IF lv_last_same = abap_true AND is_same_statement( it_statements = it_statements
                                                         iv_idx_a      = <ls_base_branch>-to_idx
                                                         iv_idx_b      = <ls_branch>-to_idx ) = abap_false.
        lv_last_same = abap_false.
      ENDIF.

      IF lv_first_same = abap_false AND lv_last_same = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_first_same = abap_true OR lv_last_same = abap_true.
      report_if( it_statements = it_statements
                 iv_idx        = is_frame-if_idx ).
    ENDIF.
  ENDMETHOD.

  METHOD is_extractable_statement.
    rv_ok = abap_true.
    CASE is_statement-keyword.
      WHEN 'IF'    OR 'ENDIF'   OR 'ELSE'  OR 'ELSEIF' OR
           'LOOP'  OR 'ENDLOOP' OR
           'WHILE' OR 'ENDWHILE' OR
           'DO'    OR 'ENDDO'   OR
           'CASE'  OR 'ENDCASE' OR 'WHEN'  OR
           'TRY'   OR 'ENDTRY'  OR 'CATCH' OR 'CLEANUP'.
        rv_ok = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_same_statement.
    DATA lv_sig_a TYPE string.
    DATA lv_sig_b TYPE string.

    rv_same = abap_false.
    IF    iv_idx_a < 1 OR iv_idx_b < 1
       OR iv_idx_a > lines( it_statements ) OR iv_idx_b > lines( it_statements ).
      RETURN.
    ENDIF.

    lv_sig_a = get_signature( it_statements[ iv_idx_a ] ).
    lv_sig_b = get_signature( it_statements[ iv_idx_b ] ).

    IF lv_sig_a IS NOT INITIAL AND lv_sig_a = lv_sig_b.
      rv_same = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_signature.
    CLEAR rv_sig.
    LOOP AT is_statement-tokens ASSIGNING FIELD-SYMBOL(<ls_token>).
      IF rv_sig IS INITIAL.
        rv_sig = <ls_token>-lexeme.
      ELSE.
        rv_sig = |{ rv_sig } { <ls_token>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD report_if.
    report_statement( is_statement    = it_statements[ iv_idx ]
                      iv_finding_code = c_finding_codes-identical_contents ).
  ENDMETHOD.
ENDCLASS.
