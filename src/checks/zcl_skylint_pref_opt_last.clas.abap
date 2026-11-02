CLASS zcl_skylint_pref_opt_last DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        optional_last TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_OPT_L',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_OPTIONAL_LAST'.

    METHODS check_method_parameters
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_pref_opt_last IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Declare optional and default parameters last in methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-optional_last
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Declare mandatory parameters before OPTIONAL and DEFAULT parameters'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'METHODS' OR <ls_statement>-keyword = 'CLASS-METHODS'.
        check_method_parameters( <ls_statement> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_method_parameters.
    DATA lt_params        TYPE zcl_skylint_ast_util=>ty_method_parameters.
    DATA lv_curr_section  TYPE string.
    DATA lv_seen_optional TYPE abap_bool.
    FIELD-SYMBOLS <ls_param> TYPE zcl_skylint_ast_util=>ty_method_parameter.

    lt_params = zcl_skylint_ast_util=>get_method_parameters( is_statement ).

    LOOP AT lt_params ASSIGNING <ls_param>.
      IF <ls_param>-section <> 'IMPORTING' AND <ls_param>-section <> 'CHANGING'.
        CONTINUE.
      ENDIF.

      IF <ls_param>-section <> lv_curr_section.
        lv_curr_section  = <ls_param>-section.
        lv_seen_optional = abap_false.
      ENDIF.

      IF <ls_param>-is_optional = abap_true OR <ls_param>-has_default = abap_true.
        lv_seen_optional = abap_true.
      ELSEIF lv_seen_optional = abap_true.
        report_token( is_token        = <ls_param>-token
                      is_statement    = is_statement
                      iv_finding_code = c_finding_codes-optional_last ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
