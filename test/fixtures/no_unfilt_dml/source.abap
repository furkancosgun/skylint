CLASS zcl_test_no_unfilt_dml DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_unfilt_dml IMPLEMENTATION.
  METHOD test_001.
    DELETE FROM ztab.
  ENDMETHOD.

  METHOD test_002.
    DELETE FROM ztab WHERE arbgb = 1.
  ENDMETHOD.

  METHOD test_003.
    UPDATE ztab SET arbgb = 1.
  ENDMETHOD.

  METHOD test_004.
    UPDATE ztab SET arbgb = 1 WHERE arbgb = 1.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_rows TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DELETE lt_rows.
  ENDMETHOD.
ENDCLASS.
