CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config OPTIONAL.

    METHODS run
      IMPORTING is_procedure       TYPE zif_skylint_types=>ty_procedure
      RETURNING VALUE(rt_findings) TYPE zif_skylint_types=>ty_findings.

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

ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.

  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.

  METHOD run.
    CLEAR mt_findings.
    CLEAR mt_quickfixes.
    check( is_procedure ).
    rt_findings = mt_findings.
  ENDMETHOD.

  METHOD get_config.
    rs_config = ms_config.
  ENDMETHOD.

  METHOD get_recorded_quickfixes.
    rt_recorded = mt_quickfixes.
  ENDMETHOD.

  METHOD report_statement.
    DATA ls_finding TYPE zif_skylint_types=>ty_finding.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    IF has_valid_pseudo_comment( is_statement    = is_statement
                                 iv_finding_code = iv_finding_code ) = abap_true.
      RETURN.
    ENDIF.

    ASSIGN ms_config-finding_codes[ code = iv_finding_code ] TO <ls_fc>.
    IF sy-subrc = 0.
      ls_finding-severity = <ls_fc>-severity.
      ls_finding-message  = format_message( iv_template = <ls_fc>-text
                                            iv_param_1  = iv_param_1
                                            iv_param_2  = iv_param_2
                                            iv_param_3  = iv_param_3
                                            iv_param_4  = iv_param_4 ).
    ENDIF.

    ls_finding-code     = iv_finding_code.
    ls_finding-position = is_statement-position.
    IF is_quickfix-code IS NOT INITIAL.
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

    ASSIGN ms_config-finding_codes[ code = iv_finding_code ] TO <ls_fc>.
    IF sy-subrc = 0.
      ls_finding-severity = <ls_fc>-severity.
      ls_finding-message  = format_message( iv_template = <ls_fc>-text
                                            iv_param_1  = iv_param_1
                                            iv_param_2  = iv_param_2
                                            iv_param_3  = iv_param_3
                                            iv_param_4  = iv_param_4 ).
    ENDIF.

    ls_finding-code            = iv_finding_code.
    ls_finding-position-line   = is_token-position-line.
    ls_finding-position-column = is_token-position-column.
    IF is_quickfix-code IS NOT INITIAL.
      APPEND is_quickfix TO ls_finding-quickfixes.
    ENDIF.
    IF it_quickfixes IS NOT INITIAL.
      APPEND LINES OF it_quickfixes TO ls_finding-quickfixes.
    ENDIF.

    report_finding( ls_finding ).
  ENDMETHOD.

  METHOD report_finding.
    APPEND is_finding TO mt_findings.
  ENDMETHOD.

  METHOD get_attribute.
    FIELD-SYMBOLS <ls_attr> TYPE zif_skylint_types=>ty_attribute.
    FIELD-SYMBOLS <lv_src>  TYPE any.

    READ TABLE ms_config-attributes ASSIGNING <ls_attr>
         WITH KEY name = iv_name.
    IF sy-subrc = 0 AND <ls_attr>-value IS BOUND.
      ASSIGN <ls_attr>-value->* TO <lv_src>.
      IF sy-subrc = 0.
        ev_value = <lv_src>.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD quickfix_replace.
    DATA ls_qf TYPE zif_skylint_types=>ty_quickfix.

    ls_qf-code           = iv_quickfix_code.
    ls_qf-kind           = zif_skylint_types=>quickfix_kinds-replace.
    ls_qf-statement_from = iv_statement_from.
    ls_qf-statement_to   = iv_statement_to.
    IF ls_qf-statement_to IS INITIAL.
      ls_qf-statement_to = iv_statement_from.
    ENDIF.
    ls_qf-token_from     = iv_token_from.
    ls_qf-token_to       = iv_token_to.
    IF ls_qf-token_from IS NOT INITIAL AND ls_qf-token_to IS INITIAL.
      ls_qf-token_to     = iv_token_from.
    ENDIF.
    ls_qf-new_code       = it_new_code.

    APPEND ls_qf TO mt_quickfixes.
    rs_quickfix = ls_qf.
  ENDMETHOD.

  METHOD has_valid_pseudo_comment.
    FIELD-SYMBOLS <ls_fc> TYPE zif_skylint_types=>ty_finding_code_config.

    rv_has_pseudo_comment = abap_false.
    ASSIGN ms_config-finding_codes[ code = iv_finding_code ] TO <ls_fc>.
    IF sy-subrc <> 0 OR <ls_fc>-pseudo_comment IS INITIAL.
      RETURN.
    ENDIF.

    IF line_exists( is_statement-pseudo_comments[ table_line = <ls_fc>-pseudo_comment ] ).
      rv_has_pseudo_comment = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD format_message.
    rv_message = iv_template.
    IF iv_param_1 IS NOT INITIAL.
      REPLACE FIRST OCCURRENCE OF '&1' IN rv_message WITH iv_param_1.
      IF sy-subrc <> 0.
        REPLACE FIRST OCCURRENCE OF '&' IN rv_message WITH iv_param_1.
      ENDIF.
    ENDIF.
    IF iv_param_2 IS NOT INITIAL.
      REPLACE FIRST OCCURRENCE OF '&2' IN rv_message WITH iv_param_2.
      IF sy-subrc <> 0.
        REPLACE FIRST OCCURRENCE OF '&' IN rv_message WITH iv_param_2.
      ENDIF.
    ENDIF.
    IF iv_param_3 IS NOT INITIAL.
      REPLACE FIRST OCCURRENCE OF '&3' IN rv_message WITH iv_param_3.
      IF sy-subrc <> 0.
        REPLACE FIRST OCCURRENCE OF '&' IN rv_message WITH iv_param_3.
      ENDIF.
    ENDIF.
    IF iv_param_4 IS NOT INITIAL.
      REPLACE FIRST OCCURRENCE OF '&4' IN rv_message WITH iv_param_4.
      IF sy-subrc <> 0.
        REPLACE FIRST OCCURRENCE OF '&' IN rv_message WITH iv_param_4.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
