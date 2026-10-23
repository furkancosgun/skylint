CLASS zcl_test_no_client_specified DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_client_specified IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy USING CLIENT '100' INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy CLIENT SPECIFIED INTO TABLE @lt_tab WHERE mandt = '100'.
  ENDMETHOD.

  METHOD test_004.
    DATA ls_row TYPE zskylint_dummy.
    SELECT SINGLE * FROM zskylint_dummy INTO @ls_row.
  ENDMETHOD.
ENDCLASS.
