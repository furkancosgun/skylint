CLASS zcl_skylint_test_069 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_069 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num TYPE i.
    DATA lv_sum TYPE i VALUE 0.
    LOOP AT lt_numbers INTO lv_num.
      lv_sum = lv_sum + lv_num.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num TYPE i.
    DATA lv_sum TYPE i VALUE 0.
    LOOP AT lt_numbers INTO lv_num. "#EC PREFER_REDUCE
      lv_sum = lv_sum + lv_num.
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_sum TYPE i.
    lv_sum = REDUCE i( INIT s = 0 FOR n IN lt_numbers NEXT s = s + n ).
  ENDMETHOD.
ENDCLASS.
