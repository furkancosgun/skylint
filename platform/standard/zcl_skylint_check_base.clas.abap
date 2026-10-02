CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  INHERITING FROM cl_ci_test_scan
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config OPTIONAL.

    METHODS run REDEFINITION.

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
    DATA ms_config     TYPE zif_skylint_types=>ty_config.
    DATA mt_findings   TYPE zif_skylint_types=>ty_findings.
    DATA mt_quickfixes TYPE zif_skylint_types=>ty_quickfixes.

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

    METHODS map_scan_to_procedure
      RETURNING VALUE(rs_procedure) TYPE zif_skylint_types=>ty_procedure.

ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.

  METHOD constructor.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    super->constructor( ).
    ms_config = is_config.

    description = ms_config-description.
    category    = 'CL_CI_CATEGORY_PROGRAM_CONSTRUCTS'.
    version     = '0001'.
    position    = '999'.

    LOOP AT ms_config-finding_codes ASSIGNING <ls_fc>.
      fill_message(
          p_code           = <ls_fc>-code
          p_text           = <ls_fc>-text
          p_pseudo_comment = <ls_fc>-pseudo_comment
          p_kind           = COND #( WHEN <ls_fc>-severity = zif_skylint_types=>severities-error
                                     THEN c_error
                                     WHEN <ls_fc>-severity = zif_skylint_types=>severities-info
                                     THEN c_note
                                     ELSE c_warning ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_config.
    rs_config = ms_config.
  ENDMETHOD.

  METHOD get_recorded_quickfixes.
    rt_recorded = mt_quickfixes.
  ENDMETHOD.

  METHOD run.
    DATA ls_procedure TYPE zif_skylint_types=>ty_procedure.

    IF ref_scan IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_procedure = map_scan_to_procedure( ).
    IF ls_procedure-statements IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR mt_findings.
    CLEAR mt_quickfixes.
    check( ls_procedure ).
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

    inform(
        p_sub_obj_type = c_type_include
        p_sub_obj_name = get_include( )
        p_line         = is_finding-position-line
        p_column       = is_finding-position-column
        p_kind         = COND #( WHEN is_finding-severity = zif_skylint_types=>severities-error
                                 THEN c_error
                                 WHEN is_finding-severity = zif_skylint_types=>severities-info
                                 THEN c_note
                                 ELSE c_warning )
        p_test         = my_name
        p_code         = is_finding-code
        p_param_1      = is_finding-message ).
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

    IF line_exists( is_statement-pseudo_comments[ table_line = lv_pcom ] ).
      rv_has_pseudo_comment = abap_true.
      RETURN.
    ENDIF.

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
