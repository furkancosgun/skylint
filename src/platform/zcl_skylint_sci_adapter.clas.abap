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

      ls_statement-index           = sy-tabix.
      ls_statement-keyword         = <ls_stmt>-keyword.
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

    uses_checksum = abap_false.
    LOOP AT lt_findings ASSIGNING <ls_finding>.
      inform( p_sub_obj_type = c_type_include
              p_sub_obj_name = p_proc-include
              p_line         = <ls_finding>-position-line
              p_column       = CONV #( <ls_finding>-position-column )
              p_kind         = <ls_finding>-severity
              p_test         = myname
              p_code         = <ls_finding>-code ).
    ENDLOOP.
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
