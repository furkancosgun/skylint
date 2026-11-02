CLASS zcl_test_pref_read_key DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             field1 TYPE string,
             field2 TYPE i,
           END OF ty_row.
    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
ENDCLASS.

CLASS zcl_test_pref_read_key IMPLEMENTATION.

  METHOD test_001.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field1 = 'X' AND field2 = 3.
  ENDMETHOD.

  METHOD test_002.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WITH KEY field1 = 'X'.
  ENDMETHOD.

  METHOD test_003.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field1 = 'X'. "#EC PREF_READ_KEY
  ENDMETHOD.

  METHOD test_004.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INDEX 1 INTO ls_row.
  ENDMETHOD.

  METHOD test_005.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field2 > 1.
  ENDMETHOD.

  METHOD test_006.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field1 CS 'X'.
  ENDMETHOD.

  METHOD test_007.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field1 = 'X' OR field1 = 'Y'.
  ENDMETHOD.

  METHOD test_008.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field1 IS NOT INITIAL.
  ENDMETHOD.

  METHOD test_009.
    DATA ls_row TYPE ty_row.
    READ TABLE lt_data INTO ls_row WHERE field1 EQ 'X' AND field2 EQ 3.
  ENDMETHOD.

ENDCLASS.
