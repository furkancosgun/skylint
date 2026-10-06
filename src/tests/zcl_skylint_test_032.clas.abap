CLASS zcl_skylint_test_032 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_032 IMPLEMENTATION.
  METHOD test_001.
    SELECT * FROM zskylint_dummy INTO @DATA(ls_row).
    ENDSELECT.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT field1 FROM zskylint_dummy INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_003.
    DATA ls_row TYPE zskylint_dummy.
    DATA ls_key TYPE string.
    SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.
  ENDMETHOD.

  METHOD test_004.
    DATA ls_row TYPE zskylint_dummy.
    DATA ls_key TYPE string.
    SELECT SINGLE field1 FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.
  ENDMETHOD.
ENDCLASS.
