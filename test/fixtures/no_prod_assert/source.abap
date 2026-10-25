CLASS zcl_test_no_prod_assert DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_test_no_prod_assert IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    ASSERT lv_x > 0.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x <= 0.
      RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
