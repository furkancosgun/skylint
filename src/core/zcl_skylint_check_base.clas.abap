CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

    TYPES: BEGIN OF ty_check_config,
             description       TYPE string,
             remote_enablement TYPE abap_bool,
             finding_codes     TYPE if_ci_atc_check_meta_data=>ty_finding_code_infos,
             quickfix_codes    TYPE if_ci_atc_check_meta_data=>ty_quickfix_code_infos,
             attributes        TYPE if_ci_atc_check_meta_data=>ty_attributes,
           END OF ty_check_config.

    CONSTANTS:
      BEGIN OF c_quickfix_modes,
        replace       TYPE string VALUE 'REPLACE',
        insert_before TYPE string VALUE 'INSERT_BEFORE',
        insert_after  TYPE string VALUE 'INSERT_AFTER',
      END OF c_quickfix_modes.

    TYPES ty_code_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    TYPES: BEGIN OF ty_quickfix,
             code           TYPE cl_ci_atc_quickfixes=>ty_quickfix_code,
             mode           TYPE string,
             statement_from TYPE i,
             statement_to   TYPE i,
             token_from     TYPE i,
             token_to       TYPE i,
             new_code       TYPE ty_code_lines,
           END OF ty_quickfix,
           ty_quickfixes TYPE STANDARD TABLE OF ty_quickfix WITH EMPTY KEY.

    METHODS constructor
      IMPORTING is_config TYPE ty_check_config OPTIONAL.

  PROTECTED SECTION.
    METHODS check ABSTRACT
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS report_statement
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code
                is_quickfix     TYPE ty_quickfix   OPTIONAL
                it_quickfixes   TYPE ty_quickfixes OPTIONAL.

    METHODS report_token
      IMPORTING is_token        TYPE if_ci_atc_source_code_provider=>ty_token
                is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code
                is_quickfix     TYPE ty_quickfix   OPTIONAL
                it_quickfixes   TYPE ty_quickfixes OPTIONAL.

    METHODS quickfix_replace
      IMPORTING iv_quickfix_code   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code
                iv_statement_from  TYPE i
                iv_statement_to    TYPE i OPTIONAL
                iv_token_from      TYPE i OPTIONAL
                iv_token_to        TYPE i OPTIONAL
                it_new_code        TYPE ty_code_lines
      RETURNING VALUE(rs_quickfix) TYPE ty_quickfix.

    METHODS quickfix_insert_before
      IMPORTING iv_quickfix_code   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code
                iv_statement_from  TYPE i
                iv_statement_to    TYPE i OPTIONAL
                iv_token_from      TYPE i OPTIONAL
                iv_token_to        TYPE i OPTIONAL
                it_new_code        TYPE ty_code_lines
      RETURNING VALUE(rs_quickfix) TYPE ty_quickfix.

    METHODS quickfix_insert_after
      IMPORTING iv_quickfix_code   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code
                iv_statement_from  TYPE i
                iv_statement_to    TYPE i OPTIONAL
                iv_token_from      TYPE i OPTIONAL
                iv_token_to        TYPE i OPTIONAL
                it_new_code        TYPE ty_code_lines
      RETURNING VALUE(rs_quickfix) TYPE ty_quickfix.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_reported,
             code         TYPE if_ci_atc_check=>ty_finding_code,
             statement    TYPE if_ci_atc_source_code_provider=>ty_statement,
             procedure_id TYPE if_ci_atc_source_code_provider=>ty_procedure_id,
             quickfixes   TYPE ty_quickfixes,
           END OF ty_reported,
           ty_reported_tab TYPE STANDARD TABLE OF ty_reported WITH EMPTY KEY.

    DATA ms_config        TYPE ty_check_config.
    DATA mt_reported      TYPE ty_reported_tab.
    DATA mo_factory       TYPE REF TO cl_ci_atc_assistant_factory.
    DATA mo_code_provider TYPE REF TO if_ci_atc_source_code_provider.

    METHODS has_valid_pseudo_comment
      IMPORTING is_statement                 TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code              TYPE if_ci_atc_check=>ty_finding_code
      RETURNING VALUE(rv_has_pseudo_comment) TYPE abap_bool.

    METHODS convert_reported
      RETURNING VALUE(rt_findings) TYPE if_ci_atc_check=>ty_findings.

ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.
  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.

  METHOD has_valid_pseudo_comment.
    DATA lv_ci_tag    TYPE string.
    DATA lv_plain_tag TYPE string.
    FIELD-SYMBOLS <ls_fc> TYPE if_ci_atc_check_meta_data=>ty_finding_code_info.

    rv_has_pseudo_comment = abap_false.
    ASSIGN ms_config-finding_codes[ code = iv_finding_code ] TO <ls_fc>.
    IF sy-subrc <> 0 OR <ls_fc>-pseudo_comment IS INITIAL.
      RETURN.
    ENDIF.

    IF strlen( <ls_fc>-pseudo_comment ) >= 3 AND <ls_fc>-pseudo_comment(3) = 'CI_'.
      lv_ci_tag    = <ls_fc>-pseudo_comment.
      lv_plain_tag = <ls_fc>-pseudo_comment+3.
    ELSE.
      lv_ci_tag    = |CI_{ <ls_fc>-pseudo_comment }|.
      lv_plain_tag = <ls_fc>-pseudo_comment.
    ENDIF.

    IF line_exists( is_statement-pseudo_comments[ table_line = lv_plain_tag ] )
       OR line_exists( is_statement-pseudo_comments[ table_line = lv_ci_tag ] ).
      rv_has_pseudo_comment = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD quickfix_replace.
    DATA ls_qf TYPE ty_quickfix.

    ls_qf-code           = iv_quickfix_code.
    ls_qf-mode           = c_quickfix_modes-replace.
    ls_qf-statement_from = iv_statement_from.
    ls_qf-statement_to   = iv_statement_to.
    IF ls_qf-statement_to IS INITIAL.
      ls_qf-statement_to = iv_statement_from.
    ENDIF.
    ls_qf-token_from = iv_token_from.
    ls_qf-token_to   = iv_token_to.
    IF ls_qf-token_from IS NOT INITIAL AND ls_qf-token_to IS INITIAL.
      ls_qf-token_to = iv_token_from.
    ENDIF.
    ls_qf-new_code = it_new_code.

    rs_quickfix = ls_qf.
  ENDMETHOD.

  METHOD quickfix_insert_before.
    DATA ls_qf TYPE ty_quickfix.

    ls_qf-code           = iv_quickfix_code.
    ls_qf-mode           = c_quickfix_modes-insert_before.
    ls_qf-statement_from = iv_statement_from.
    ls_qf-statement_to   = iv_statement_to.
    IF ls_qf-statement_to IS INITIAL.
      ls_qf-statement_to = iv_statement_from.
    ENDIF.
    ls_qf-token_from = iv_token_from.
    ls_qf-token_to   = iv_token_to.
    IF ls_qf-token_from IS NOT INITIAL AND ls_qf-token_to IS INITIAL.
      ls_qf-token_to = iv_token_from.
    ENDIF.
    ls_qf-new_code = it_new_code.

    rs_quickfix = ls_qf.
  ENDMETHOD.

  METHOD quickfix_insert_after.
    DATA ls_qf TYPE ty_quickfix.

    ls_qf-code           = iv_quickfix_code.
    ls_qf-mode           = c_quickfix_modes-insert_after.
    ls_qf-statement_from = iv_statement_from.
    ls_qf-statement_to   = iv_statement_to.
    IF ls_qf-statement_to IS INITIAL.
      ls_qf-statement_to = iv_statement_from.
    ENDIF.
    ls_qf-token_from = iv_token_from.
    ls_qf-token_to   = iv_token_to.
    IF ls_qf-token_from IS NOT INITIAL AND ls_qf-token_to IS INITIAL.
      ls_qf-token_to = iv_token_from.
    ENDIF.
    ls_qf-new_code = it_new_code.

    rs_quickfix = ls_qf.
  ENDMETHOD.

  METHOD report_statement.
    DATA ls_reported TYPE ty_reported.

    IF has_valid_pseudo_comment( is_statement    = is_statement
                                 iv_finding_code = iv_finding_code ) = abap_true.
      RETURN.
    ENDIF.

    ls_reported-code      = iv_finding_code.
    ls_reported-statement = is_statement.
    IF is_quickfix-code IS NOT INITIAL.
      APPEND is_quickfix TO ls_reported-quickfixes.
    ENDIF.
    IF it_quickfixes IS NOT INITIAL.
      APPEND LINES OF it_quickfixes TO ls_reported-quickfixes.
    ENDIF.

    APPEND ls_reported TO mt_reported.
  ENDMETHOD.

  METHOD report_token.
    DATA ls_reported TYPE ty_reported.

    IF has_valid_pseudo_comment( is_statement    = is_statement
                                 iv_finding_code = iv_finding_code ) = abap_true.
      RETURN.
    ENDIF.

    ls_reported-code      = iv_finding_code.
    ls_reported-statement = is_statement.
    ls_reported-statement-position = is_token-position.
    IF is_quickfix-code IS NOT INITIAL.
      APPEND is_quickfix TO ls_reported-quickfixes.
    ENDIF.
    IF it_quickfixes IS NOT INITIAL.
      APPEND LINES OF it_quickfixes TO ls_reported-quickfixes.
    ENDIF.

    APPEND ls_reported TO mt_reported.
  ENDMETHOD.

  METHOD convert_reported.
    DATA lo_quickfixes TYPE REF TO cl_ci_atc_quickfixes.
    DATA lo_fix        TYPE REF TO if_ci_atc_quickfix.
    DATA lo_context    TYPE REF TO cl_ci_atc_quickfix_context.
    DATA lo_details    TYPE REF TO cl_ci_atc_finding_details.

    FIELD-SYMBOLS <ls_rep> TYPE ty_reported.
    FIELD-SYMBOLS <ls_qf>  TYPE ty_quickfix.

    LOOP AT mt_reported ASSIGNING <ls_rep>.
      CLEAR lo_details.
      IF <ls_rep>-quickfixes IS NOT INITIAL.
        lo_quickfixes = mo_factory->create_quickfixes( ).
        LOOP AT <ls_rep>-quickfixes ASSIGNING <ls_qf>.
          lo_fix = lo_quickfixes->create_quickfix( <ls_qf>-code ).
          lo_context = mo_factory->create_quickfix_context( VALUE #( procedure_id = <ls_rep>-procedure_id
                                                                     statements   = VALUE #(
                                                                         from = <ls_qf>-statement_from
                                                                         to   = <ls_qf>-statement_to )
                                                                     tokens       = VALUE #(
                                                                         from = <ls_qf>-token_from
                                                                         to   = <ls_qf>-token_to ) ) ).
          CASE <ls_qf>-mode.
            WHEN c_quickfix_modes-insert_before.
              lo_fix->insert_before( context = lo_context
                                     code    = <ls_qf>-new_code ).
            WHEN c_quickfix_modes-insert_after.
              lo_fix->insert_after( context = lo_context
                                    code    = <ls_qf>-new_code ).
            WHEN OTHERS.
              lo_fix->replace( context = lo_context
                               code    = <ls_qf>-new_code ).
          ENDCASE.
        ENDLOOP.
        lo_details = mo_factory->create_finding_details( )->attach_quickfixes( lo_quickfixes ).
      ENDIF.

      INSERT VALUE #( code     = <ls_rep>-code
                      location = mo_code_provider->get_statement_location( <ls_rep>-statement )
                      checksum = mo_code_provider->get_statement_checksum( <ls_rep>-statement )
                      details  = lo_details )
             INTO TABLE rt_findings.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ci_atc_check~get_meta_data.
    meta_data = NEW zcl_skylint_check_meta_data( iv_description       = ms_config-description
                                                 it_finding_codes     = ms_config-finding_codes
                                                 it_quickfix_codes    = ms_config-quickfix_codes
                                                 it_attributes        = ms_config-attributes
                                                 iv_remote_enablement = ms_config-remote_enablement ).
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    DATA ls_comp_unit  TYPE if_ci_atc_source_code_provider=>ty_compilation_unit.
    DATA lr_procedures TYPE REF TO if_ci_atc_source_code_provider=>ty_procedures.

    FIELD-SYMBOLS <ls_procedure> TYPE if_ci_atc_source_code_provider=>ty_procedure.
    FIELD-SYMBOLS <ls_rep>       TYPE ty_reported.

    CLEAR mt_reported.
    mo_code_provider = data_provider->get_code_provider( ).
    ls_comp_unit = mo_code_provider->object_to_comp_unit( object ).
    TRY.
        lr_procedures = mo_code_provider->get_procedures( ls_comp_unit ).
      CATCH cx_ci_atc_invalid_comp_unit.
        RETURN.
    ENDTRY.

    LOOP AT lr_procedures->* ASSIGNING <ls_procedure>.
      check( <ls_procedure> ).
      LOOP AT mt_reported ASSIGNING <ls_rep>
           WHERE procedure_id IS INITIAL.
        <ls_rep>-procedure_id = <ls_procedure>-id.
      ENDLOOP.
    ENDLOOP.

    findings = convert_reported( ).
  ENDMETHOD.

  METHOD if_ci_atc_check~set_attributes.
    FIELD-SYMBOLS <ls_own> TYPE if_ci_atc_check_meta_data=>ty_attribute.
    FIELD-SYMBOLS <ls_new> TYPE if_ci_atc_check_meta_data=>ty_attribute.
    FIELD-SYMBOLS <lv_own> TYPE any.
    FIELD-SYMBOLS <lv_new> TYPE any.

    LOOP AT ms_config-attributes ASSIGNING <ls_own>.
      ASSIGN attributes[ name = <ls_own>-name ] TO <ls_new>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN <ls_own>-value->* TO <lv_own>.
      ASSIGN <ls_new>-value->* TO <lv_new>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <lv_own> = <lv_new>.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ci_atc_check~set_assistant_factory.
    mo_factory = factory.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
  ENDMETHOD.
ENDCLASS.
