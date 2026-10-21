CLASS lcl_bad_ctor DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.

CLASS lcl_bad_ctor IMPLEMENTATION.
  METHOD constructor.
    DATA lv_val TYPE i.
    lv_val = 1.
    lv_val = 2.
    lv_val = 3.
    lv_val = 4.
    lv_val = 5.
    lv_val = 6.
    lv_val = 7.
    lv_val = 8.
    lv_val = 9.
    lv_val = 10.
    lv_val = 11.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_good_ctor DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.

CLASS lcl_good_ctor IMPLEMENTATION.
  METHOD constructor.
    DATA lv_x TYPE i.
    lv_x = 1.
  ENDMETHOD.
ENDCLASS.
