CLASS zcl_skylint_no_single_when DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        short_case TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_SGL_WHN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_SINGLE_WHEN'.

    METHODS count_when_branches
      IMPORTING iv_start_idx  TYPE i
                is_procedure  TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_cnt) TYPE i.

ENDCLASS.


CLASS zcl_skylint_no_single_when IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid CASE statements with only one WHEN branch'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-short_case
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'CASE statement has <= 1 WHEN branch; prefer IF'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx        TYPE i.
    DATA lv_when_count TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CASE'.
        CONTINUE.
      ENDIF.
      lv_idx = sy-tabix.
      lv_when_count = count_when_branches( iv_start_idx = lv_idx
                                           is_procedure = is_procedure ).
      IF lv_when_count <= 1.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-short_case ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_when_branches.
    DATA lv_total    TYPE i.
    DATA lv_fwd_idx  TYPE i.
    DATA lv_depth    TYPE i.
    DATA ls_fwd_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_cnt = 0.
    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).
    lv_depth = 0.
    lv_fwd_idx = iv_start_idx + 1.

    WHILE lv_fwd_idx <= lv_total.
      ls_fwd_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = lv_fwd_idx ).
      IF ls_fwd_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_fwd_stmt-keyword.
        WHEN 'CASE'.
          lv_depth += 1.

        WHEN 'ENDCASE'.
          IF lv_depth = 0.
            RETURN.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'WHEN'.
          IF     lv_depth = 0
             AND zcl_skylint_ast_util=>match_token_sequence(
                     is_statement = ls_fwd_stmt
                     it_expected  = VALUE #( ( `WHEN` ) ( `OTHERS` ) ) ) = abap_false.
            rv_cnt += 1.
          ENDIF.
      ENDCASE.

      lv_fwd_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
