CLASS ty_pair DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_pair,
             item TYPE i,
           END OF ty_pair.
ENDCLASS.

CLASS ty_pair IMPLEMENTATION.
ENDCLASS.

CLASS zcl_test_prefer_final_data DEFINITION
  PUBLIC
  FINAL
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
ENDCLASS.

CLASS zcl_test_prefer_final_data IMPLEMENTATION.
  METHOD test_001.
    DATA(lv_count) = 10.
    WRITE lv_count.
  ENDMETHOD.

  METHOD test_002.
    DATA(lv_count) = 10.
    lv_count = 20.
    WRITE lv_count.
  ENDMETHOD.

  METHOD test_003.
    DATA(lv_count) = 10.
    lv_count += 1.
    WRITE lv_count.
  ENDMETHOD.

  METHOD test_004.
    DATA(ls_pair) = VALUE ty_pair( item = 1 ).
    ls_pair-item = 2.
    WRITE ls_pair-item.
  ENDMETHOD.

  METHOD test_005.
    FINAL(lv_count) = 10.
    WRITE lv_count.
  ENDMETHOD.

  METHOD test_006.
    DATA(lv_count) = 10. " #EC PREF_FINAL
    WRITE lv_count.
  ENDMETHOD.
  METHOD test_007.
    DATA(lv_count) = 10.
    WRITE lv_count.
    WRITE lv_count.
  ENDMETHOD.

  METHOD test_008.
    DATA(lv_count) = 10.
    IF lv_flag = abap_true.
      lv_count = 20.
    ENDIF.
    WRITE lv_count.
  ENDMETHOD.
ENDCLASS.
