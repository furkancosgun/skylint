CLASS zcl_skylint_no_intf_data DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        interface_data TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTF_DATA',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'INTF_DATA'.

    METHODS is_interface
      IMPORTING is_procedure      TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is_intf) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_intf_data IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable DATA in interfaces; allow only CONSTANTS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-interface_data
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid mutable DATA in interfaces; declare CONSTANTS or move to class'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    IF is_interface( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'DATA' AND <ls_statement>-keyword <> 'CLASS-DATA'.
        CONTINUE.
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-interface_data ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_interface.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-interface.
      rv_is_intf = abap_true.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    rv_is_intf = xsdbool( ls_first_stmt-keyword = 'INTERFACE' ).
  ENDMETHOD.
ENDCLASS.
