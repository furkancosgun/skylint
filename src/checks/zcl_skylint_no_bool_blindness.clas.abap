CLASS zcl_skylint_no_bool_blindness DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        boolean_flag TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_BOOL_BL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_BOOL_BLINDNESS'.

    METHODS has_bool_importing_param
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_bool_blindness IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Avoid boolean flag importing parameters'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-boolean_flag
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Boolean importing parameters hide intent; use dedicated methods or a typed flag'
                  pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.
      IF has_bool_importing_param( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-boolean_flag ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_bool_importing_param.
    DATA lt_params TYPE zcl_skylint_ast_util=>ty_method_parameters.

    lt_params = zcl_skylint_ast_util=>get_method_parameters( is_statement ).

    rv_yes = xsdbool( line_exists( lt_params[ section   = 'IMPORTING'
                                              type_name = 'ABAP_BOOL' ] ) ).
  ENDMETHOD.
ENDCLASS.
