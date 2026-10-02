CLASS zcl_skylint_sci_adapter DEFINITION
  PUBLIC
  INHERITING FROM cl_ci_test_scan
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS run REDEFINITION.

  PRIVATE SECTION.
    DATA mo_runner TYPE REF TO zcl_skylint_runner.

    METHODS map_scan_to_procedure
      RETURNING VALUE(rs_procedure) TYPE zif_skylint_types=>ty_procedure.

    METHODS report_findings
      IMPORTING it_findings TYPE zif_skylint_types=>ty_findings.

ENDCLASS.


CLASS zcl_skylint_sci_adapter IMPLEMENTATION.

  METHOD constructor.
    DATA lt_checks TYPE zcl_skylint_runner=>ty_check_list.
    DATA lo_check  TYPE REF TO zcl_skylint_check_base.
    DATA ls_cfg    TYPE zif_skylint_types=>ty_config.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    super->constructor( ).

    description = 'Skylint: Clean ABAP & Security Suite'.
    category    = 'CL_CI_CATEGORY_PROGRAM_CONSTRUCTS'.
    version     = '0001'.
    position    = '999'.

    mo_runner = zcl_skylint_runner=>create_default( ).
    lt_checks = mo_runner->get_registered_checks( ).

    LOOP AT lt_checks INTO lo_check.
      ls_cfg = lo_check->get_config( ).
      LOOP AT ls_cfg-finding_codes ASSIGNING <ls_fc>.
        fill_message(
            p_code = <ls_fc>-code
            p_text = <ls_fc>-text
            p_kind = COND #( WHEN <ls_fc>-severity = zif_skylint_types=>severities-error
                             THEN c_error
                             WHEN <ls_fc>-severity = zif_skylint_types=>severities-info
                             THEN c_note
                             ELSE c_warning ) ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD run.
    DATA ls_procedure TYPE zif_skylint_types=>ty_procedure.
    DATA lt_findings  TYPE zif_skylint_types=>ty_findings.

    IF ref_scan IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_procedure = map_scan_to_procedure( ).
    IF ls_procedure-statements IS INITIAL.
      RETURN.
    ENDIF.

    lt_findings = mo_runner->run_procedure( ls_procedure ).
    IF lt_findings IS NOT INITIAL.
      report_findings( lt_findings ).
    ENDIF.
  ENDMETHOD.

  METHOD map_scan_to_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_stmt>  TYPE sstmnt.
    FIELD-SYMBOLS <ls_token> TYPE stokesx.

    rs_procedure-id-name = program_name.
    rs_procedure-id-kind = zif_skylint_types=>procedure_kinds-method.

    LOOP AT ref_scan->statements ASSIGNING <ls_stmt>.
      CLEAR ls_stmt.
      ls_stmt-level = <ls_stmt>-level.
      ls_stmt-type  = <ls_stmt>-type.

      " Map statement keyword and normalize kernel types
      CASE <ls_stmt>-type.
        WHEN 'C'.
          ls_stmt-keyword = 'COMPUTE'.
        WHEN 'A'.
          ls_stmt-keyword = '+CALL_METHOD'.
        WHEN OTHERS.
          IF <ls_stmt>-from <= <ls_stmt>-to.
            ASSIGN ref_scan->tokens[ <ls_stmt>-from ] TO <ls_token>.
            IF sy-subrc = 0.
              ls_stmt-keyword = <ls_token>-str.
            ENDIF.
          ENDIF.
      ENDCASE.

      " Extract statement tokens
      IF <ls_stmt>-from <= <ls_stmt>-to.
        LOOP AT ref_scan->tokens ASSIGNING <ls_token> FROM <ls_stmt>-from TO <ls_stmt>-to.
          CLEAR ls_tok.
          ls_tok-lexeme          = <ls_token>-str.
          ls_tok-type            = <ls_token>-type.
          ls_tok-position-line   = <ls_token>-row.
          ls_tok-position-column = <ls_token>-col.

          IF ls_stmt-position-line IS INITIAL.
            ls_stmt-position-line   = <ls_token>-row.
            ls_stmt-position-column = <ls_token>-col.
          ENDIF.

          APPEND ls_tok TO ls_stmt-tokens.
        ENDLOOP.
      ENDIF.

      APPEND ls_stmt TO rs_procedure-statements.
    ENDLOOP.
  ENDMETHOD.

  METHOD report_findings.
    FIELD-SYMBOLS <ls_finding> TYPE zif_skylint_types=>ty_finding.

    LOOP AT it_findings ASSIGNING <ls_finding>.
      inform(
          p_sub_obj_type = c_type_include
          p_sub_obj_name = get_include( )
          p_line         = <ls_finding>-position-line
          p_column       = <ls_finding>-position-column
          p_kind         = COND #( WHEN <ls_finding>-severity = zif_skylint_types=>severities-error
                                   THEN c_error
                                   WHEN <ls_finding>-severity = zif_skylint_types=>severities-info
                                   THEN c_note
                                   ELSE c_warning )
          p_test         = my_name
          p_code         = <ls_finding>-code
          p_param_1      = <ls_finding>-message ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
