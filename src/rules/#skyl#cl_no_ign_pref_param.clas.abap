CLASS /skyl/cl_no_ign_pref_param DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        ignored_preferred_param TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_IGN_PRF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IGN_PREF_PARAM'.

    METHODS check_method_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS /skyl/cl_no_ign_pref_param IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Report ignored PREFERRED PARAMETER addition'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-ignored_preferred_param
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'PREFERRED PARAMETER is ignored when mandatory parameters exist'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'METHODS' OR <ls_statement>-keyword = 'CLASS-METHODS'.
        check_method_statement( <ls_statement> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_method_statement.
    DATA lv_pref_idx   TYPE i.
    DATA lt_params     TYPE /skyl/cl_ast_util=>ty_method_parameters.
    DATA lv_has_mand   TYPE abap_bool.
    DATA ls_pref_token TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_param> TYPE /skyl/cl_ast_util=>ty_method_parameter.

    lv_pref_idx = /skyl/cl_ast_util=>find_token_sequence( is_statement = is_statement
                                                          it_expected  = VALUE #( ( `PREFERRED` ) ( `PARAMETER` ) ) ).
    IF lv_pref_idx = 0.
      RETURN.
    ENDIF.

    lt_params = /skyl/cl_ast_util=>get_method_parameters( is_statement ).
    lv_has_mand = abap_false.

    LOOP AT lt_params ASSIGNING <ls_param>.
      IF <ls_param>-section <> 'IMPORTING'.
        CONTINUE.
      ENDIF.
      IF <ls_param>-is_optional = abap_false AND <ls_param>-has_default = abap_false.
        lv_has_mand = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_has_mand = abap_false.
      RETURN.
    ENDIF.

    ls_pref_token = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_pref_idx ).

    report_token( is_token        = ls_pref_token
                  is_statement    = is_statement
                  iv_finding_code = c_finding_codes-ignored_preferred_param ).
  ENDMETHOD.
ENDCLASS.
