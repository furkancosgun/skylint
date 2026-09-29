CLASS zcl_skylint_check_076 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'INTERFACE_DATA'.

ENDCLASS.


CLASS zcl_skylint_check_076 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable DATA declarations in interfaces; allow only CONSTANTS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-interface_data
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid mutable DATA in interfaces; declare CONSTANTS or move to class'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_in_interface TYPE abap_bool.

    lv_in_interface = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'INTERFACE'.
        lv_in_interface = abap_true.
      ELSEIF <ls_statement>-keyword = 'ENDINTERFACE'.
        lv_in_interface = abap_false.
      ELSEIF lv_in_interface = abap_true AND <ls_statement>-keyword = 'DATA'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-interface_data ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
