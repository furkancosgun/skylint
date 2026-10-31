CLASS zcl_skylint_no_unused_param DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unused_param TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_UNUS_PR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_used_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_UNUSED_PARAM'.

    DATA mv_check_methods TYPE abap_bool VALUE abap_true.
    DATA mv_check_forms   TYPE abap_bool VALUE abap_true.
    DATA mv_check_funcs   TYPE abap_bool VALUE abap_true.

    METHODS extract_method_parameters
      IMPORTING is_procedure         TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rt_parameters) TYPE string_table.

    METHODS extract_signature_parameters
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_parameters) TYPE string_table.

    METHODS collect_used_parameters
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rt_names) TYPE ty_used_names.
ENDCLASS.


CLASS zcl_skylint_no_unused_param IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid unused parameters in procedures'
                                 remote_enablement = abap_false
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unused_param
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Parameter(s) &1 never used in procedure'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_METHODS'
                                                                value = REF #( mv_check_methods ) )
                                                              ( name  = 'CHECK_FORMS'
                                                                value = REF #( mv_check_forms ) )
                                                              ( name  = 'CHECK_FUNCS'
                                                                value = REF #( mv_check_funcs ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_parameters TYPE string_table.
    DATA lt_used       TYPE ty_used_names.
    DATA lv_unused     TYPE string.
    DATA lv_name       TYPE string.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF lines( is_procedure-statements ) < 1.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).

    CASE is_procedure-id-kind.
      WHEN if_ci_atc_source_code_provider=>procedure_kinds-method.
        IF mv_check_methods = abap_false.
          RETURN.
        ENDIF.
        lt_parameters = extract_method_parameters( is_procedure ).

      WHEN if_ci_atc_source_code_provider=>procedure_kinds-form_routine.
        IF mv_check_forms = abap_false.
          RETURN.
        ENDIF.
        lt_parameters = extract_signature_parameters( ls_first_stmt ).

      WHEN if_ci_atc_source_code_provider=>procedure_kinds-function.
        IF mv_check_funcs = abap_false.
          RETURN.
        ENDIF.
        lt_parameters = extract_signature_parameters( ls_first_stmt ).

      WHEN OTHERS.
        RETURN.
    ENDCASE.

    IF lt_parameters IS INITIAL.
      RETURN.
    ENDIF.

    lt_used = collect_used_parameters( is_procedure-statements ).

    LOOP AT lt_parameters INTO lv_name.
      IF line_exists( lt_used[ table_line = lv_name ] ).
        CONTINUE.
      ENDIF.

      IF lv_unused IS INITIAL.
        lv_unused = lv_name.
      ELSE.
        lv_unused = |{ lv_unused }, { lv_name }|.
      ENDIF.
    ENDLOOP.

    IF lv_unused IS NOT INITIAL.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-unused_param
                        is_parameters   = VALUE #( param_1 = lv_unused ) ).
    ENDIF.
  ENDMETHOD.

  METHOD extract_method_parameters.
    DATA ls_method TYPE abap_methdescr.
    DATA lv_found  TYPE abap_bool.
    FIELD-SYMBOLS <ls_param> TYPE abap_parmdescr.

    TRY.
        zcl_skylint_rtti_util=>get_procedure_method_descr( EXPORTING is_procedure = is_procedure
                                                           IMPORTING es_method    = ls_method
                                                                     ev_found     = lv_found ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    IF lv_found = abap_false.
      RETURN.
    ENDIF.

    IF    ls_method-is_interface  = abap_true
       OR ls_method-is_abstract   = abap_true
       OR ls_method-is_redefined  = abap_true
       OR ls_method-is_inherited  = abap_true
       OR ls_method-for_event    IS NOT INITIAL.
      RETURN.
    ENDIF.

    LOOP AT ls_method-parameters ASSIGNING <ls_param>.
      IF <ls_param>-parm_kind = cl_abap_objectdescr=>returning.
        CONTINUE.
      ENDIF.

      IF <ls_param>-name IS INITIAL OR <ls_param>-name(1) = '_'.
        CONTINUE.
      ENDIF.

      APPEND <ls_param>-name TO rt_parameters.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_signature_parameters.
    DATA ls_ref  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = <ls_token>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF ls_ref IS INITIAL.
        CONTINUE.
      ENDIF.

      IF     ls_ref-usage_mode  <> if_ci_atc_source_code_provider=>usage_modes-definition
         AND ls_ref-usage_grade <> if_ci_atc_source_code_provider=>usage_grades-definition.
        CONTINUE.
      ENDIF.
      zcl_skylint_ast_util=>parse_full_name( EXPORTING iv_full_name = ls_ref-full_name
                                             IMPORTING ev_data_name = lv_name ).
      IF lv_name IS NOT INITIAL AND lv_name(1) <> '_'.
        APPEND lv_name TO rt_parameters.
      ENDIF.
      CLEAR lv_name.
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_used_parameters.
    DATA lt_references TYPE if_ci_atc_source_code_provider=>ty_compiler_references.
    DATA lv_root       TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_reference> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT it_statements ASSIGNING <ls_statement> FROM 2.
      lt_references = zcl_skylint_ast_util=>statement_get_references(
                          is_statement = <ls_statement>
                          iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      LOOP AT lt_references ASSIGNING <ls_reference>.
        zcl_skylint_ast_util=>parse_full_name( EXPORTING iv_full_name = <ls_reference>-full_name
                                               IMPORTING ev_data_name = lv_root ).
        IF lv_root IS NOT INITIAL.
          INSERT lv_root INTO TABLE rt_names.
        ENDIF.
        CLEAR lv_root.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
