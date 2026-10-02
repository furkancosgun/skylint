CLASS zcl_skylint_atc_cloud_adapter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

    METHODS constructor.

  PRIVATE SECTION.
    DATA mo_runner TYPE REF TO zcl_skylint_runner.

    METHODS map_procedure
      IMPORTING io_source_provider  TYPE REF TO if_ci_atc_source_code_provider
                is_proc_id          TYPE any
      RETURNING VALUE(rs_procedure) TYPE zif_skylint_types=>ty_procedure.

    METHODS report_findings
      IMPORTING io_context   TYPE REF TO if_ci_atc_context
                it_findings  TYPE zif_skylint_types=>ty_findings
                is_procedure TYPE zif_skylint_types=>ty_procedure.

ENDCLASS.


CLASS zcl_skylint_atc_cloud_adapter IMPLEMENTATION.

  METHOD constructor.
    mo_runner = zcl_skylint_runner=>create_default( ).
  ENDMETHOD.

  METHOD if_ci_atc_check~get_meta_data.
    DATA lt_checks TYPE zcl_skylint_runner=>ty_check_list.
    DATA lo_check  TYPE REF TO zcl_skylint_check_base.
    DATA ls_cfg    TYPE zif_skylint_types=>ty_config.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    ro_meta_data = cl_ci_atc_check_meta_data=>create(
      )->description( 'Skylint: Clean ABAP & Modern ATC Suite'
      )->checked_object_types( VALUE #( ( 'CLAS' ) ( 'INTF' ) ( 'PROG' ) ( 'FUGR' ) ) ).

    lt_checks = mo_runner->get_registered_checks( ).
    LOOP AT lt_checks INTO lo_check.
      ls_cfg = lo_check->get_config( ).
      LOOP AT ls_cfg-finding_codes ASSIGNING <ls_fc>.
        ro_meta_data->finding_code(
            finding_code = <ls_fc>-code
            severity     = COND #( WHEN <ls_fc>-severity = zif_skylint_types=>severities-error
                                   THEN cl_ci_atc_finding_severities=>error
                                   WHEN <ls_fc>-severity = zif_skylint_types=>severities-info
                                   THEN cl_ci_atc_finding_severities=>note
                                   ELSE cl_ci_atc_finding_severities=>warning )
            text         = <ls_fc>-text ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
    ro_prerequisites = cl_ci_atc_check_prerequisites=>create( ).
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    DATA lo_src_provider TYPE REF TO if_ci_atc_source_code_provider.
    DATA lt_procedures   TYPE any TABLE.
    DATA ls_proc_record  TYPE any.
    DATA ls_procedure    TYPE zif_skylint_types=>ty_procedure.
    DATA lt_findings     TYPE zif_skylint_types=>ty_findings.
    FIELD-SYMBOLS <ls_proc> TYPE any.

    lo_src_provider = io_context->get_source_code_provider( ).
    IF lo_src_provider IS NOT BOUND.
      RETURN.
    ENDIF.

    lt_procedures = lo_src_provider->get_procedures( ).

    LOOP AT lt_procedures ASSIGNING <ls_proc>.
      ls_procedure = map_procedure( io_source_provider = lo_src_provider
                                   is_proc_id         = <ls_proc> ).

      IF ls_procedure-statements IS INITIAL.
        CONTINUE.
      ENDIF.

      lt_findings = mo_runner->run_procedure( ls_procedure ).
      IF lt_findings IS NOT INITIAL.
        report_findings( io_context   = io_context
                         it_findings  = lt_findings
                         is_procedure = ls_procedure ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_procedure.
    DATA lt_statements TYPE if_ci_atc_source_code_provider=>ty_statements.
    DATA lt_tokens     TYPE if_ci_atc_source_code_provider=>ty_tokens.
    DATA ls_stmt       TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok        TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_src_stmt> TYPE any.
    FIELD-SYMBOLS <ls_src_tok>  TYPE any.

    " Extract statements and tokens from ATC source code provider
    lt_statements = io_source_provider->get_statements( is_proc_id ).
    lt_tokens     = io_source_provider->get_tokens( is_proc_id ).

    LOOP AT lt_statements ASSIGNING <ls_src_stmt>.
      CLEAR ls_stmt.
      ASSIGN COMPONENT 'KEYWORD' OF STRUCTURE <ls_src_stmt> TO FIELD-SYMBOL(<lv_kw>).
      IF <lv_kw> IS ASSIGNED.
        ls_stmt-keyword = <lv_kw>.
      ENDIF.

      ASSIGN COMPONENT 'STATEMENT_TYPE' OF STRUCTURE <ls_src_stmt> TO FIELD-SYMBOL(<lv_stype>).
      IF <lv_stype> IS ASSIGNED.
        ls_stmt-type = <lv_stype>.
      ENDIF.

      ASSIGN COMPONENT 'ROW' OF STRUCTURE <ls_src_stmt> TO FIELD-SYMBOL(<lv_srow>).
      IF <lv_srow> IS ASSIGNED.
        ls_stmt-position-line = <lv_srow>.
      ENDIF.

      ASSIGN COMPONENT 'COL' OF STRUCTURE <ls_src_stmt> TO FIELD-SYMBOL(<lv_scol>).
      IF <lv_scol> IS ASSIGNED.
        ls_stmt-position-column = <lv_scol>.
      ENDIF.

      " Assign tokens belonging to this statement
      ASSIGN COMPONENT 'FROM_TOKEN' OF STRUCTURE <ls_src_stmt> TO FIELD-SYMBOL(<lv_from>).
      ASSIGN COMPONENT 'TO_TOKEN'   OF STRUCTURE <ls_src_stmt> TO FIELD-SYMBOL(<lv_to>).
      IF <lv_from> IS ASSIGNED AND <lv_to> IS ASSIGNED.
        LOOP AT lt_tokens ASSIGNING <ls_src_tok> FROM <lv_from> TO <lv_to>.
          CLEAR ls_tok.
          ASSIGN COMPONENT 'STR' OF STRUCTURE <ls_src_tok> TO FIELD-SYMBOL(<lv_tstr>).
          IF <lv_tstr> IS ASSIGNED.
            ls_tok-lexeme = <lv_tstr>.
          ENDIF.

          ASSIGN COMPONENT 'TYPE' OF STRUCTURE <ls_src_tok> TO FIELD-SYMBOL(<lv_ttype>).
          IF <lv_ttype> IS ASSIGNED.
            ls_tok-type = <lv_ttype>.
          ENDIF.

          ASSIGN COMPONENT 'ROW' OF STRUCTURE <ls_src_tok> TO FIELD-SYMBOL(<lv_trow>).
          IF <lv_trow> IS ASSIGNED.
            ls_tok-position-line = <lv_trow>.
          ENDIF.

          ASSIGN COMPONENT 'COL' OF STRUCTURE <ls_src_tok> TO FIELD-SYMBOL(<lv_tcol>).
          IF <lv_tcol> IS ASSIGNED.
            ls_tok-position-column = <lv_tcol>.
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
      io_context->add_finding(
          structure = VALUE #(
              code      = <ls_finding>-code
              severity  = COND #( WHEN <ls_finding>-severity = zif_skylint_types=>severities-error
                                  THEN cl_ci_atc_finding_severities=>error
                                  WHEN <ls_finding>-severity = zif_skylint_types=>severities-info
                                  THEN cl_ci_atc_finding_severities=>note
                                  ELSE cl_ci_atc_finding_severities=>warning )
              location  = VALUE #( line   = <ls_finding>-position-line
                                   column = <ls_finding>-position-column )
              message_args = VALUE #( ( <ls_finding>-message ) ) ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
