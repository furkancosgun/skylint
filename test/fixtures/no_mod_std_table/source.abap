CLASS zcl_test_modify_own_tab DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_003.
    METHODS test_005.
    METHODS test_007.
ENDCLASS.

CLASS zcl_test_modify_own_tab IMPLEMENTATION.
  METHOD test_001.
    DELETE FROM t100 WHERE sprsl = 'E'.
  ENDMETHOD.

  METHOD test_003.
    UPDATE t100 SET text = '200'.
  ENDMETHOD.

  METHOD test_005.
    INSERT INTO t100 VALUES @( VALUE #( ) ).
  ENDMETHOD.

  METHOD test_007.
    DATA lt_data TYPE string_table.
    MODIFY lt_data FROM 'hello' INDEX 1.
  ENDMETHOD.
ENDCLASS.
