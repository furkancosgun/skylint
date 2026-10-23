.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_pref_reduce IMPLEMENTATION.

  METHOD test_001.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_sum     TYPE i.

    LOOP AT lt_numbers INTO lv_num.
      lv_sum = lv_sum + lv_num.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_sum     TYPE i.
    DATA lv_count   TYPE i.

    " Compliant: multiple statements in loop body
    LOOP AT lt_numbers INTO lv_num.
      lv_sum = lv_sum + lv_num.
      lv_count = lv_count + 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_sum     TYPE i.

    " Compliant: complex condition inside loop body
    LOOP AT lt_numbers INTO lv_num.
      IF lv_num > 0.
        lv_sum = lv_sum + lv_num.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_sum     TYPE i.

    " Suppressed via pseudo comment
    LOOP AT lt_numbers INTO lv_num. "#EC PREF_REDUCE
      lv_sum = lv_sum + lv_num.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_sum     TYPE i.

    " Compliant: already using REDUCE #( )
    lv_sum = REDUCE #(
      INIT res = 0
      FOR n IN lt_numbers
      NEXT res = res + n ).
  ENDMETHOD.

ENDCLASS.
