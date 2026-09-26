CLASS zcl_skylint_check_019 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'DUPCOND',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'IDENTICAL_CONDITIONS'.

    METHODS check_duplicate_elseif
      IMPORTING iv_idx       TYPE i
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS check_duplicate_when
      IMPORTING iv_idx       TYPE i
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS get_condition_string
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_cond) TYPE string.

ENDCLASS.


CLASS zcl_skylint_check_019 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect identical branch conditions in IF/ELSEIF and CASE/WHEN'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-identical_condition
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Identical condition in branch; duplicate branch is unreachable'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'ELSEIF'.
          check_duplicate_elseif( iv_idx       = lv_idx
                                  is_statement = <ls_statement>
                                  is_procedure = is_procedure ).

        WHEN 'WHEN'.
          check_duplicate_when( iv_idx       = lv_idx
                                is_statement = <ls_statement>
                                is_procedure = is_procedure ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_duplicate_elseif.
    DATA lv_cond      TYPE string.
    DATA lv_prev_cond TYPE string.
    DATA lv_back_idx  TYPE i.
    DATA lv_depth     TYPE i.
    FIELD-SYMBOLS <ls_back_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_cond = get_condition_string( is_statement ).
    lv_depth = 0.
    lv_back_idx = iv_idx - 1.

    WHILE lv_back_idx >= 1.
      ASSIGN is_procedure-statements[ lv_back_idx ] TO <ls_back_stmt>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      CASE <ls_back_stmt>-keyword.
        WHEN 'ENDIF'.
          lv_depth += 1.

        WHEN 'IF'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( <ls_back_stmt> ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
            ENDIF.
            EXIT.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'ELSEIF'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( <ls_back_stmt> ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.

      lv_back_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD check_duplicate_when.
    DATA lv_cond      TYPE string.
    DATA lv_prev_cond TYPE string.
    DATA lv_back_idx  TYPE i.
    DATA lv_depth     TYPE i.
    FIELD-SYMBOLS <ls_back_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_cond = get_condition_string( is_statement ).
    lv_depth = 0.
    lv_back_idx = iv_idx - 1.

    WHILE lv_back_idx >= 1.
      ASSIGN is_procedure-statements[ lv_back_idx ] TO <ls_back_stmt>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      CASE <ls_back_stmt>-keyword.
        WHEN 'ENDCASE'.
          lv_depth += 1.

        WHEN 'CASE'.
          IF lv_depth = 0.
            EXIT.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'WHEN'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( <ls_back_stmt> ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.

      lv_back_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_condition_string.
    DATA lv_tok_cnt TYPE i.
    DATA lv_tok_idx TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_cond = ''.
    lv_tok_cnt = lines( is_statement-tokens ).
    IF lv_tok_cnt < 2.
      RETURN.
    ENDIF.

    DO lv_tok_cnt - 1 TIMES.
      lv_tok_idx = sy-index + 1.
      ASSIGN is_statement-tokens[ lv_tok_idx ] TO <ls_token>.
      IF sy-subrc = 0.
        IF rv_cond IS INITIAL.
          rv_cond = to_upper( <ls_token>-lexeme ).
        ELSE.
          rv_cond = |{ rv_cond } { to_upper( <ls_token>-lexeme ) }|.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
