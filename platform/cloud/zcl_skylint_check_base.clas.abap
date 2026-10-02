CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config OPTIONAL.

    METHODS get_config
      RETURNING VALUE(rs_config) TYPE zif_skylint_types=>ty_config.

    METHODS get_recorded_quickfixes
      RETURNING VALUE(rt_recorded) TYPE zif_skylint_types=>ty_quickfixes.

  PROTECTED SECTION.
    METHODS check ABSTRACT
      IMPORTING is_procedure TYPE zif_skylint_types=>ty_procedure.

    METHODS report_statement
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
                iv_finding_code TYPE zif_skylint_types=>ty_finding_code
                iv_param_1      TYPE string                           OPTIONAL
                iv_param_2      TYPE string                           OPTIONAL
                iv_param_3      TYPE string                           OPTIONAL
                iv_param_4      TYPE string                           OPTIONAL
                is_quickfix     TYPE zif_skylint_types=>ty_quickfix   OPTIONAL
                it_quickfixes   TYPE zif_skylint_types=>ty_quickfixes OPTIONAL.

    METHODS report_token
      IMPORTING is_token        TYPE zif_skylint_types=>ty_token
                is_statement    TYPE zif_skylint_types=>ty_statement
                iv_finding_code TYPE zif_skylint_types=>ty_finding_code
                iv_param_1      TYPE string                           OPTIONAL
                iv_param_2      TYPE string                           OPTIONAL
                iv_param_3      TYPE string                           OPTIONAL
                iv_param_4      TYPE string                           OPTIONAL
                is_quickfix     TYPE zif_skylint_types=>ty_quickfix   OPTIONAL
                it_quickfixes   TYPE zif_skylint_types=>ty_quickfixes OPTIONAL.

    METHODS get_attribute
      IMPORTING iv_name  TYPE string
      EXPORTING ev_value TYPE any.

    METHODS quickfix_replace
      IMPORTING iv_quickfix_code  TYPE zif_skylint_types=>ty_quickfix_code
                iv_statement_from TYPE i
                iv_statement_to   TYPE i                                OPTIONAL
                iv_token_from     TYPE i                                OPTIONAL
                iv_token_to       TYPE i                                OPTIONAL
                it_new_code       TYPE zif_skylint_types=>ty_code_lines
      RETURNING VALUE(rs_quickfix) TYPE zif_skylint_types=>ty_quickfix.

  PRIVATE SECTION.
    DATA ms_config      TYPE zif_skylint_types=>ty_config.
    DATA mt_findings    TYPE zif_skylint_types=>ty_findings.
    DATA mt_quickfixes  TYPE zif_skylint_types=>ty_quickfixes.
    DATA mo_atc_context TYPE REF TO if_ci_atc_context.

    METHODS report_finding
      IMPORTING is_finding TYPE zif_skylint_types=>ty_finding.

    METHODS has_valid_pseudo_comment
      IMPORTING is_statement                 TYPE zif_skylint_types=>ty_statement
                iv_finding_code              TYPE zif_skylint_types=>ty_finding_code
      RETURNING VALUE(rv_has_pseudo_comment) TYPE abap_bool.

    METHODS format_message
      IMPORTING iv_template       TYPE string
                iv_param_1        TYPE string OPTIONAL
                iv_param_2        TYPE string OPTIONAL
                iv_param_3        TYPE string OPTIONAL
                iv_param_4        TYPE string OPTIONAL
      RETURNING VALUE(rv_message) TYPE string.

    METHODS map_procedure
      IMPORTING io_source_provider  TYPE REF TO if_ci_atc_source_code_provider
                is_proc_id          TYPE any
      RETURNING VALUE(rs_procedure) TYPE zif_skylint_types=>ty_procedure.

    METHODS emit_atc_finding
      IMPORTING is_finding TYPE zif_skylint_types=>ty_finding.

ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.

  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.

  METHOD get_config.
    rs_config = ms_config.
  ENDMETHOD.

  METHOD get_recorded_quickfixes.
    rt_recorded = mt_quickfixes.
  ENDMETHOD.

  METHOD if_ci_atc_check~get_meta_data.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.
    FIELD-SYMBOLS <ls_qf> TYPE zif_skylint_types=>ty_quickfix_code_info.

    ro_meta_data = cl_ci_atc_check_meta_data=>create(
      )->description( ms_config-description
      )->checked_object_types( VALUE #( ( 'CLAS' ) ( 'INTF' ) ( 'PROG' ) ( 'FUGR' ) ) ).

    LOOP AT ms_config-finding_codes ASSIGNING <ls_fc>.
      ro_meta_data->finding_code(
          finding_code   = <ls_fc>-code
          severity       = COND #( WHEN <ls_fc>-severity = zif_skylint_types=>severities-error
                                   THEN cl_ci_atc_finding_severities=>error
                                   WHEN <ls_fc>-severity = zif_skylint_types=>severities-info
                                   THEN cl_ci_atc_finding_severities=>note
                                   ELSE cl_ci_atc_finding_severities=>warning )
          text           = <ls_fc>-text
          pseudo_comment = <ls_fc>-pseudo_comment ).
    ENDLOOP.

    LOOP AT ms_config-quickfix_codes ASSIGNING <ls_qf>.
      ro_meta_data->quickfix_code(
          quickfix_code = <ls_qf>-code
          short_text    = <ls_qf>-short_text ).
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
    ro_prerequisites = cl_ci_atc_check_prerequisites=>create( ).
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    DATA lo_src_provider TYPE REF TO if_ci_atc_source_code_provider.
    DATA lt_procedures   TYPE any TABLE.
    DATA ls_procedure    TYPE zif_skylint_types=>ty_procedure.
    FIELD-SYMBOLS <ls_proc> TYPE any.

    mo_atc_context = io_context.
    lo_src_provider = io_context->get_source_code_provider( ).
    IF lo_src_provider IS NOT BOUND.
      RETURN.
    ENDIF.

    lt_procedures = lo_src_provider->get_procedures( ).

    LOOP AT lt_procedures ASSIGNING <ls_proc>.
      ls_procedure = map_procedure( io_source_provider = lo_src_provider
                                   is_proc_id         = <ls_proc> ).
      IF ls_procedure-statements IS NOT INITIAL.
        CLEAR mt_findings.
        CLEAR mt_quickfixes.
        check( ls_procedure ).
      ENDIF.
    ENDLOOP.

    CLEAR mo_atc_context.
  ENDMETHOD.

  METHOD map_procedure.
    DATA lt_statements TYPE if_ci_atc_source_code_provider=>ty_statements.
    DATA lt_tokens     TYPE if_ci_atc_source_code_provider=>ty_tokens.
    DATA ls_stmt       TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok        TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_src_stmt> TYPE any.
    FIELD-SYMBOLS <ls_src_tok>  TYPE any.

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

  METHOD report_statement.
    DATA ls_finding TYPE zif_skylint_types=>ty_finding.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    IF has_valid_pseudo_comment( is_statement    = is_statement
                                 iv_finding_code = iv_finding_code ) = abap_true.
      RETURN.
    ENDIF.

    READ TABLE ms_config-finding_codes ASSIGNING <ls_fc>
         WITH TABLE KEY code = iv_finding_code.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ls_finding-code            = iv_finding_code.
    ls_finding-severity        = <ls_fc>-severity.
    ls_finding-position-line   = is_statement-position-line.
    ls_finding-position-column = is_statement-position-column.
    ls_finding-message         = format_message( iv_template = <ls_fc>-text
                                                 iv_param_1   = iv_param_1
                                                 iv_param_2   = iv_param_2
                                                 iv_param_3   = iv_param_3
                                                 iv_param_4   = iv_param_4 ).

    IF is_quickfix IS NOT INITIAL.
      APPEND is_quickfix TO ls_finding-quickfixes.
    ENDIF.
    IF it_quickfixes IS NOT INITIAL.
      APPEND LINES OF it_quickfixes TO ls_finding-quickfixes.
    ENDIF.

    report_finding( ls_finding ).
  ENDMETHOD.

  METHOD report_token.
    DATA ls_finding TYPE zif_skylint_types=>ty_finding.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    IF has_valid_pseudo_comment( is_statement    = is_statement
                                 iv_finding_code = iv_finding_code ) = abap_true.
      RETURN.
    ENDIF.

    READ TABLE ms_config-finding_codes ASSIGNING <ls_fc>
         WITH TABLE KEY code = iv_finding_code.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ls_finding-code            = iv_finding_code.
    ls_finding-severity        = <ls_fc>-severity.
    ls_finding-position-line   = is_token-position-line.
    ls_finding-position-column = is_token-position-column.
    ls_finding-message         = format_message( iv_template = <ls_fc>-text
                                                 iv_param_1   = iv_param_1
                                                 iv_param_2   = iv_param_2
                                                 iv_param_3   = iv_param_3
                                                 iv_param_4   = iv_param_4 ).

    IF is_quickfix IS NOT INITIAL.
      APPEND is_quickfix TO ls_finding-quickfixes.
    ENDIF.
    IF it_quickfixes IS NOT INITIAL.
      APPEND LINES OF it_quickfixes TO ls_finding-quickfixes.
    ENDIF.

    report_finding( ls_finding ).
  ENDMETHOD.

  METHOD report_finding.
    APPEND is_finding TO mt_findings.
    IF is_finding-quickfixes IS NOT INITIAL.
      APPEND LINES OF is_finding-quickfixes TO mt_quickfixes.
    ENDIF.

    IF mo_atc_context IS BOUND.
      emit_atc_finding( is_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD emit_atc_finding.
    mo_atc_context->add_finding(
        structure = VALUE #(
            code      = is_finding-code
            severity  = COND #( WHEN is_finding-severity = zif_skylint_types=>severities-error
                                THEN cl_ci_atc_finding_severities=>error
                                WHEN is_finding-severity = zif_skylint_types=>severities-info
                                THEN cl_ci_atc_finding_severities=>note
                                ELSE cl_ci_atc_finding_severities=>warning )
            location  = VALUE #( line   = is_finding-position-line
                                 column = is_finding-position-column )
            message_args = VALUE #( ( is_finding-message ) ) ) ).
  ENDMETHOD.

  METHOD has_valid_pseudo_comment.
    DATA ls_token TYPE zif_skylint_types=>ty_token.
    DATA lv_pcom  TYPE string.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    rv_has_pseudo_comment = abap_false.

    READ TABLE ms_config-finding_codes ASSIGNING <ls_fc>
         WITH TABLE KEY code = iv_finding_code.
    IF sy-subrc <> 0 OR <ls_fc>-pseudo_comment IS INITIAL.
      RETURN.
    ENDIF.

    lv_pcom = <ls_fc>-pseudo_comment.

    " 1. Check pseudo_comments table attached by parser
    IF line_exists( is_statement-pseudo_comments[ table_line = lv_pcom ] ).
      rv_has_pseudo_comment = abap_true.
      RETURN.
    ENDIF.

    " 2. Fallback check inside statement tokens
    LOOP AT is_statement-tokens INTO ls_token.
      IF ls_token-type = zif_skylint_types=>token_types-comment
         AND contains( val = ls_token-lexeme sub = lv_pcom ).
        rv_has_pseudo_comment = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD format_message.
    rv_message = iv_template.
    IF iv_param_1 IS NOT INITIAL.
      REPLACE '&1' IN rv_message WITH iv_param_1.
    ENDIF.
    IF iv_param_2 IS NOT INITIAL.
      REPLACE '&2' IN rv_message WITH iv_param_2.
    ENDIF.
    IF iv_param_3 IS NOT INITIAL.
      REPLACE '&3' IN rv_message WITH iv_param_3.
    ENDIF.
    IF iv_param_4 IS NOT INITIAL.
      REPLACE '&4' IN rv_message WITH iv_param_4.
    ENDIF.
  ENDMETHOD.

  METHOD get_attribute.
    FIELD-SYMBOLS <ls_attr> TYPE zif_skylint_types=>ty_attribute.
    FIELD-SYMBOLS <lv_src>  TYPE any.

    READ TABLE ms_config-attributes ASSIGNING <ls_attr>
         WITH KEY name = iv_name.
    IF sy-subrc = 0 AND <ls_attr>-value IS BOUND.
      ASSIGN <ls_attr>-value->* TO <lv_src>.
      IF <lv_src> IS ASSIGNED.
        ev_value = <lv_src>.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD quickfix_replace.
    rs_quickfix-code           = iv_quickfix_code.
    rs_quickfix-statement_from = iv_statement_from.
    rs_quickfix-statement_to   = COND #( WHEN iv_statement_to IS NOT INITIAL
                                         THEN iv_statement_to
                                         ELSE iv_statement_from ).
    rs_quickfix-token_from     = iv_token_from.
    rs_quickfix-token_to       = iv_token_to.
    rs_quickfix-new_code       = it_new_code.
  ENDMETHOD.

ENDCLASS.
