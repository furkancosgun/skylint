CLASS zcl_skylint_test_070 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_070 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_tab TYPE string.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM (lv_tab) INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_where TYPE string.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab WHERE (lv_where).
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab WHERE field1 = 'X'.
  ENDMETHOD.
ENDCLASS.
