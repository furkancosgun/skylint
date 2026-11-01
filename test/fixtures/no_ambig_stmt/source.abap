CLASS zcl_skylint_test_no_ambig DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_skylint_test_no_ambig IMPLEMENTATION.
  METHOD test_001.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    MODIFY lt_data FROM ls_row.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    DELETE lt_data FROM ls_row.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    MODIFY TABLE lt_data FROM ls_row.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    DELETE TABLE lt_data FROM ls_row.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    MODIFY ztab FROM @ls_row.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    DELETE lt_data INDEX 1.
  ENDMETHOD.
ENDCLASS.
