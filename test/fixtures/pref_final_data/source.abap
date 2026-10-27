CLASS zcl_test_prefer_final_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_pair,
             item TYPE i,
           END OF ty_pair.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    DATA lv_flag TYPE abap_bool.
    METHODS test_004.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.
    METHODS test_015.
    METHODS test_016.
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

  METHOD test_006.
    DATA(lv_count) = 10. "#EC PREF_FINAL_DATA
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

  METHOD test_009.
    DATA(ls_pair) = VALUE ty_pair( item = 1 ).
    WRITE ls_pair-item.
  ENDMETHOD.

  METHOD test_010.
    DATA(lt_tab) = VALUE string_table( ( `A` ) ).
    WRITE lines( lt_tab ).
  ENDMETHOD.

  METHOD test_011.
    DATA(lt_tab) = VALUE string_table( ( `A` ) ).
    APPEND `B` TO lt_tab.
    WRITE lines( lt_tab ).
  ENDMETHOD.

  METHOD test_012.
    DATA(lt_tab) = VALUE string_table( ( `A` ) ).
    MODIFY lt_tab FROM `B` INDEX 1.
    WRITE lines( lt_tab ).
  ENDMETHOD.

  METHOD test_013.
    DATA(lt_tab) = VALUE string_table( ( `A` ) ).
    DELETE lt_tab INDEX 1.
    WRITE lines( lt_tab ).
  ENDMETHOD.

  METHOD test_014.
    DATA lt_tab TYPE string_table.
    APPEND `A` TO lt_tab.
    APPEND `B` TO lt_tab.
    LOOP AT lt_tab INTO DATA(lv_line).
      WRITE lv_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_015.
    SELECT * FROM t000 INTO DATA(ls_row).
      WRITE sy-subrc.
    ENDSELECT.
  ENDMETHOD.

  METHOD test_016.
    SELECT SINGLE * FROM t000 INTO DATA(ls_row).
    WRITE sy-subrc.
  ENDMETHOD.
ENDCLASS.
