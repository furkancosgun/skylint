CLASS zcl_test_modify_own_tab DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_test_modify_own_tab IMPLEMENTATION.
  METHOD test_001.
    DELETE FROM mara WHERE matnr = '100'.
  ENDMETHOD.

  METHOD test_002.
    DELETE FROM zmara WHERE matnr = '100'.
  ENDMETHOD.

  METHOD test_003.
    UPDATE mara SET matnr = '200'.
  ENDMETHOD.

  METHOD test_004.
    UPDATE zmara SET matnr = '200'.
  ENDMETHOD.

  METHOD test_005.
    INSERT INTO mara VALUES @( VALUE #( ) ).
  ENDMETHOD.

  METHOD test_006.
    INSERT INTO /company/tab VALUES @( VALUE #( ) ).
  ENDMETHOD.

  METHOD test_007.
    DATA lt_data TYPE string_table.
    MODIFY lt_data FROM 'hello' INDEX 1.
  ENDMETHOD.
ENDCLASS.
