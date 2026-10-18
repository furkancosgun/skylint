CLASS zcl_skylint_test_redun_clear DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS test_012.
    METHODS test_013.

ENDCLASS.


CLASS zcl_skylint_test_redun_clear IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    CLEAR lv_a.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE string.
    CLEAR lv_a.
    CLEAR lv_b.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i VALUE 5.
    CLEAR lv_a.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    lv_a = 5.
    CLEAR lv_a.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lt_tab TYPE string_table.
    LOOP AT lt_tab INTO DATA(lv_item).
      CLEAR lv_a.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    CLEAR lv_a. "#EC REDUNDANT_CLEAR
  ENDMETHOD.

  METHOD test_007.
    DATA lt_tab TYPE string_table.
    CLEAR lt_tab[].
  ENDMETHOD.

  METHOD test_008.
    DATA lv_name(10).
    DATA lv_name2 TYPE c.
    CLEAR lv_name.
    CLEAR lv_name2.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_data TYPE string_table.
    FREE lt_data.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = 5.
    CLEAR lv_a.
    CLEAR lv_b.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_a TYPE i.
    lv_a = 5.
    CLEAR lv_a.
  ENDMETHOD.

  METHOD test_012.
    DATA lt_tab TYPE string_table.
    lt_tab = VALUE #( ( `TEST` ) ).
    FREE lt_tab.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_a TYPE i.
    lv_a = 5.
    CLEAR lv_a. "#EC REDUNDANT_CLEAR
  ENDMETHOD.
ENDCLASS.
