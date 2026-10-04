CLASS zcl_skylint_check_059 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        interface_data TYPE zif_skylint_types=>ty_finding_code VALUE 'INTF_DATA',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_059 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable DATA declarations in interfaces; allow only CONSTANTS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-interface_data
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid mutable DATA in interfaces; declare CONSTANTS or move to class'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt TYPE zif_skylint_types=>ty_statement.
    DATA lv_is_intf    TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.

    IF    is_code_block-object_type = zif_skylint_types=>object_types-interface
       OR ls_first_stmt-keyword     = 'INTERFACE'.
      lv_is_intf = abap_true.
    ENDIF.

    IF lv_is_intf = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'DATA' OR keyword = 'CLASS-DATA'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-interface_data ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
