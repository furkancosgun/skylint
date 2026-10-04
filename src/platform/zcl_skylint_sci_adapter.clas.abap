CLASS zcl_skylint_sci_adapter DEFINITION
  PUBLIC
  INHERITING FROM cl_ci_test_abap_comp_procs ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config.

    METHODS lint ABSTRACT
      IMPORTING is_code_block      TYPE zif_skylint_types=>ty_code_block
      RETURNING VALUE(rt_findings) TYPE zif_skylint_types=>ty_findings.

    METHODS get_attributes              REDEFINITION.
    METHODS put_attributes              REDEFINITION.
    METHODS if_ci_test~query_attributes REDEFINITION.

  PROTECTED SECTION.
    METHODS analyze_proc REDEFINITION.

    DATA ms_config TYPE zif_skylint_types=>ty_config.

  PRIVATE SECTION.
    METHODS build_data.
    METHODS sync_to_data.
    METHODS sync_from_data.

    DATA mr_data TYPE REF TO data.

    METHODS build_quickfix_detail
      IMPORTING is_finding       TYPE zif_skylint_types=>ty_finding
                is_proc          TYPE cl_abap_comp_procs=>t_proc_def
      RETURNING VALUE(rv_detail) TYPE xstring.
ENDCLASS.


CLASS zcl_skylint_sci_adapter IMPLEMENTATION.
  METHOD constructor.
    DATA ls_message TYPE scimessage.
    FIELD-SYMBOLS <ls_code> TYPE zif_skylint_types=>ty_finding_code_config.

    super->constructor( ).
    ms_config = is_config.

    category       = 'ZCL_SKYLINT_SCI_CATEGORY'.
    version        = '001'.
    description    = ms_config-description.
    has_attributes = xsdbool( ms_config-attributes IS NOT INITIAL ).
    attributes_ok  = abap_true.
    has_checksums  = abap_true.

    LOOP AT ms_config-finding_codes ASSIGNING <ls_code>.
      CLEAR ls_message.
      ls_message-test = myname.
      ls_message-code = <ls_code>-code.
      ls_message-text = <ls_code>-text.
      ls_message-pcom = <ls_code>-pseudo_comment.
      ls_message-kind = <ls_code>-severity.
      INSERT ls_message INTO TABLE scimessages.
    ENDLOOP.

    build_data( ).
  ENDMETHOD.

  METHOD analyze_proc.
    DATA ls_code_block TYPE zif_skylint_types=>ty_code_block.
    DATA ls_statement  TYPE zif_skylint_types=>ty_statement.
    DATA ls_token      TYPE zif_skylint_types=>ty_token.
    DATA ls_reference  TYPE zif_skylint_types=>ty_compiler_reference.
    DATA lt_findings   TYPE zif_skylint_types=>ty_findings.
    DATA lv_checksum   TYPE int4.
    DATA ls_checksum   TYPE sci_crc64.
    DATA lv_qf_detail  TYPE xstring.

    FIELD-SYMBOLS <ls_stmt>    TYPE cl_abap_comp_procs=>t_stmt.
    FIELD-SYMBOLS <ls_token>   TYPE cl_abap_comp_procs=>t_token.
    FIELD-SYMBOLS <ls_ref>     TYPE scr_token_ref.
    FIELD-SYMBOLS <ls_finding> TYPE zif_skylint_types=>ty_finding.

    ls_code_block-object_type = object_type.
    ls_code_block-object_name = object_name.
    ls_code_block-block_kind  = p_proc-proc_id-proc_type.
    ls_code_block-block_name  = p_proc-proc_id-proc_name.

    LOOP AT p_proc-stmts ASSIGNING <ls_stmt>.
      CLEAR ls_statement.

      ls_statement-index   = sy-tabix.
      ls_statement-keyword = <ls_stmt>-keyword.
      ls_statement-position-line   = <ls_stmt>-line.
      ls_statement-position-column = <ls_stmt>-column.

      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_token>.
        CLEAR ls_token.

        ls_token-lexeme          = <ls_token>-str.
        ls_token-position-line   = <ls_token>-line.
        ls_token-position-column = <ls_token>-column.

        LOOP AT <ls_token>-refs ASSIGNING <ls_ref>.
          ls_reference-full_name   = <ls_ref>-full_name.
          ls_reference-kind        = <ls_ref>-tag.
          ls_reference-usage_grade = <ls_ref>-grade.
          ls_reference-usage_mode  = <ls_ref>-mode2.
          APPEND ls_reference TO ls_token-references.
        ENDLOOP.

        APPEND ls_token TO ls_statement-tokens.
      ENDLOOP.

      APPEND ls_statement TO ls_code_block-statements.
    ENDLOOP.

    lt_findings = lint( ls_code_block ).

    LOOP AT lt_findings ASSIGNING <ls_finding>.
      CLEAR lv_checksum.

      IF <ls_finding>-statement_index > 0.
        get_stmt_checksum( EXPORTING p_proc_def   = p_proc
                                     p_index_stmt = <ls_finding>-statement_index
                           CHANGING  p_checksum   = ls_checksum ).
        lv_checksum = ls_checksum-i1.
      ENDIF.

      lv_qf_detail = build_quickfix_detail( is_finding = <ls_finding>
                                            is_proc    = p_proc ).

      inform( p_sub_obj_type = c_type_include
              p_sub_obj_name = p_proc-include
              p_line         = <ls_finding>-position-line
              p_column       = CONV #( <ls_finding>-position-column )
              p_kind         = <ls_finding>-severity
              p_test         = myname
              p_code         = <ls_finding>-code
              p_checksum_1   = lv_checksum
              p_detail       = lv_qf_detail ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_quickfix_detail.
    DATA lo_quickfixes TYPE REF TO object.
    DATA lo_context    TYPE REF TO object.
    DATA lo_quickfix   TYPE REF TO object.
    DATA lv_code       TYPE c LENGTH 10.
    DATA lv_new_code   TYPE string.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_line_col   TYPE token_col.

    FIELD-SYMBOLS <ls_quickfix> TYPE zif_skylint_types=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt>     TYPE cl_abap_comp_procs=>t_stmt.
    FIELD-SYMBOLS <lv_line>     TYPE string.

    IF is_finding-quickfixes IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        CALL METHOD ('CL_CI_QUICKFIX_CREATION')=>('CREATE_QUICKFIX_ALTERNATIVES')
          RECEIVING
            p_quickfix_alternatives = lo_quickfixes.

        IF lo_quickfixes IS INITIAL.
          RETURN.
        ENDIF.

        LOOP AT is_finding-quickfixes ASSIGNING <ls_quickfix>.
          CLEAR: lo_context, lo_quickfix.

          lv_stmt_idx = <ls_quickfix>-statement_from.
          IF lv_stmt_idx <= 0.
            lv_stmt_idx = is_finding-statement_index.
          ENDIF.

          IF lv_stmt_idx > 0 AND lines( is_proc-stmts ) >= lv_stmt_idx.
            ASSIGN is_proc-stmts[ lv_stmt_idx ] TO <ls_stmt>.
            IF sy-subrc = 0.
              TRY.
                  CALL METHOD ('CL_CI_QUICKFIX_ABAP_CONTEXT')=>('CREATE_FROM_COMP_PROCS_STMT')
                    EXPORTING
                      p_action_stmt    = <ls_stmt>
                      p_proc_def       = is_proc
                      p_proc_defs      = procs
                      p_with_end_point = abap_true
                    RECEIVING
                      p_context        = lo_context.
                CATCH cx_root.
                  CLEAR lo_context.
              ENDTRY.
            ENDIF.
          ENDIF.

          IF lo_context IS INITIAL.
            TRY.
                lv_line_col = CONV #( is_finding-position-column ).
                CALL METHOD ('CL_CI_QUICKFIX_ABAP_CONTEXT')=>('CREATE_FROM_INCLUDE')
                  EXPORTING
                    p_include = is_proc-include
                    p_line    = is_finding-position-line
                    p_col     = lv_line_col
                  RECEIVING
                    p_context = lo_context.
              CATCH cx_root.
                CLEAR lo_context.
            ENDTRY.
          ENDIF.

          IF lo_context IS INITIAL.
            CONTINUE.
          ENDIF.

          lv_code = <ls_quickfix>-code.
          IF lv_code IS INITIAL.
            lv_code = '001'.
          ENDIF.

          TRY.
              CALL METHOD lo_quickfixes->('CREATE_QUICKFIX')
                EXPORTING
                  p_quickfix_code = lv_code
                RECEIVING
                  p_quickfix      = lo_quickfix.

              IF lo_quickfix IS INITIAL.
                CONTINUE.
              ENDIF.

              CLEAR lv_new_code.
              LOOP AT <ls_quickfix>-new_code ASSIGNING <lv_line>.
                IF lv_new_code IS INITIAL.
                  lv_new_code = <lv_line>.
                ELSE.
                  CONCATENATE lv_new_code cl_abap_char_utilities=>cr_lf <lv_line> INTO lv_new_code.
                ENDIF.
              ENDLOOP.

              CALL METHOD lo_quickfix->('IF_CI_QUICKFIX_ABAP_ACTIONS~REPLACE_BY')
                EXPORTING
                  p_new_code = lv_new_code
                  p_context  = lo_context.

              TRY.
                  CALL METHOD lo_quickfix->('IF_CI_QUICKFIX_SINGLE~ENABLE_AUTOMATIC_EXECUTION').
                CATCH cx_root.
                  " Optional in older versions
              ENDTRY.

            CATCH cx_root.
              " Skip single quickfix on failure
          ENDTRY.
        ENDLOOP.

        TRY.
            CALL METHOD lo_quickfixes->('EXPORT_TO_XSTRING')
              RECEIVING
                p_detail = rv_detail.
          CATCH cx_root.
            CLEAR rv_detail.
        ENDTRY.

      CATCH cx_sy_dyn_call_illegal_class cx_root.
        " QuickFix framework not available on this NetWeaver release (e.g. 7.52)
        CLEAR rv_detail.
    ENDTRY.
  ENDMETHOD.

  METHOD build_data.
    DATA lt_component   TYPE cl_abap_structdescr=>component_table.
    DATA lo_structdescr TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <ls_attr> TYPE zif_skylint_types=>ty_attribute.

    IF ms_config-attributes IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT ms_config-attributes ASSIGNING <ls_attr>.
      CASE <ls_attr>-kind.
        WHEN zif_skylint_types=>attribute_kinds-boolean.
          INSERT VALUE #( name = <ls_attr>-name
                          type = CAST #( cl_abap_typedescr=>describe_by_name( 'XFELD' ) ) )
                 INTO TABLE lt_component.
        WHEN zif_skylint_types=>attribute_kinds-integer.
          INSERT VALUE #( name = <ls_attr>-name
                          type = CAST #( cl_abap_typedescr=>describe_by_name( 'I' ) ) )
                 INTO TABLE lt_component.
        WHEN zif_skylint_types=>attribute_kinds-string.
          INSERT VALUE #( name = <ls_attr>-name
                          type = CAST #( cl_abap_typedescr=>describe_by_name( 'TEXT1' ) ) )
                 INTO TABLE lt_component.
        WHEN OTHERS.
          ASSERT 1 = 2.
      ENDCASE.
    ENDLOOP.

    lo_structdescr = cl_abap_structdescr=>create( lt_component ).
    CREATE DATA mr_data TYPE HANDLE lo_structdescr.

    sync_to_data( ).
  ENDMETHOD.

  METHOD get_attributes.
    FIELD-SYMBOLS <lv_data> TYPE any.

    sync_to_data( ).

    ASSIGN mr_data->* TO <lv_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    EXPORT attributes = <lv_data> TO DATA BUFFER p_attributes.
  ENDMETHOD.

  METHOD if_ci_test~query_attributes.
    DATA lv_cancel     TYPE abap_bool.
    DATA lt_attributes TYPE sci_atttab.
    DATA ls_attribute  LIKE LINE OF lt_attributes.
    FIELD-SYMBOLS <lv_data>  TYPE any.
    FIELD-SYMBOLS <ls_attr>  TYPE zif_skylint_types=>ty_attribute.
    FIELD-SYMBOLS <lv_field> TYPE any.

    IF ms_config-attributes IS INITIAL.
      attributes_ok = abap_true.
      RETURN.
    ENDIF.

    sync_to_data( ).

    ASSIGN mr_data->* TO <lv_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT ms_config-attributes ASSIGNING <ls_attr>.
      CLEAR ls_attribute.

      CASE <ls_attr>-kind.
        WHEN zif_skylint_types=>attribute_kinds-boolean.
          ls_attribute-kind = 'C'.
        WHEN OTHERS.
          ls_attribute-kind = 'P'.
      ENDCASE.

      IF <ls_attr>-text IS NOT INITIAL.
        ls_attribute-text = <ls_attr>-text.
      ELSE.
        ls_attribute-text = <ls_attr>-name.
      ENDIF.

      ASSIGN COMPONENT <ls_attr>-name OF STRUCTURE <lv_data> TO <lv_field>.
      IF sy-subrc = 0.
        ls_attribute-ref = REF #( <lv_field> ).
        APPEND ls_attribute TO lt_attributes.
      ENDIF.
    ENDLOOP.

    lv_cancel = cl_ci_query_attributes=>generic( p_name       = myname
                                                 p_title      = 'Options'
                                                 p_attributes = lt_attributes
                                                 p_display    = p_display ).
    IF lv_cancel = abap_true.
      RETURN.
    ENDIF.

    sync_from_data( ).

    attributes_ok = abap_true.
  ENDMETHOD.

  METHOD put_attributes.
    FIELD-SYMBOLS <ls_data> TYPE any.

    ASSIGN mr_data->* TO <ls_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IMPORT attributes = <ls_data> FROM DATA BUFFER p_attributes.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    sync_from_data( ).
  ENDMETHOD.

  METHOD sync_from_data.
    FIELD-SYMBOLS <ls_data> TYPE any.
    FIELD-SYMBOLS <ls_attr> TYPE zif_skylint_types=>ty_attribute.
    FIELD-SYMBOLS <lv_src>  TYPE any.
    FIELD-SYMBOLS <lv_dst>  TYPE any.

    ASSIGN mr_data->* TO <ls_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT ms_config-attributes ASSIGNING <ls_attr>.
      ASSIGN COMPONENT <ls_attr>-name OF STRUCTURE <ls_data> TO <lv_src>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN <ls_attr>-value->* TO <lv_dst>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <lv_dst> = <lv_src>.
    ENDLOOP.
  ENDMETHOD.

  METHOD sync_to_data.
    FIELD-SYMBOLS <ls_data> TYPE any.
    FIELD-SYMBOLS <ls_attr> TYPE zif_skylint_types=>ty_attribute.
    FIELD-SYMBOLS <lv_src>  TYPE any.
    FIELD-SYMBOLS <lv_dst>  TYPE any.

    ASSIGN mr_data->* TO <ls_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT ms_config-attributes ASSIGNING <ls_attr>.
      ASSIGN <ls_attr>-value->* TO <lv_src>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT <ls_attr>-name OF STRUCTURE <ls_data> TO <lv_dst>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <lv_dst> = <lv_src>.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
