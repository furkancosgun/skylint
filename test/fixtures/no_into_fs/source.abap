CLASS zcl_skylint_test_into_fs DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_into_fs IMPLEMENTATION.
  METHOD test_001.
    DATA lt_data TYPE string_table.
    FIELD-SYMBOLS <fs_row> TYPE string.
    READ TABLE lt_data INTO <fs_row> INDEX 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_data TYPE string_table.
    FIELD-SYMBOLS <fs_row> TYPE string.
    LOOP AT lt_data INTO <fs_row>.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_data TYPE string_table.
    FIELD-SYMBOLS <fs_row> TYPE string.
    READ TABLE lt_data ASSIGNING <fs_row> INDEX 1.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_data TYPE string_table.
    DATA ls_row TYPE string.
    READ TABLE lt_data INTO ls_row INDEX 1.
  ENDMETHOD.
ENDCLASS.
