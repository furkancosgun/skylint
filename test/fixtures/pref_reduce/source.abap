CLASS zcl_skylint_test_pref_reduce DEFINITION.
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
    METHODS test_014.
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

  METHOD test_006.
    TYPES: BEGIN OF ty_row,
             lv_sum_total TYPE i,
           END OF ty_row.
    DATA lt_rows TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA ls_row  TYPE ty_row.
    DATA lv_sum  TYPE i.

    LOOP AT lt_rows INTO ls_row.
      lv_sum = lv_sum + ls_row-lv_sum_total.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    TYPES: BEGIN OF ty_item,
             price TYPE i,
             qty   TYPE i,
           END OF ty_item.
    DATA lt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    DATA ls_item  TYPE ty_item.
    DATA lv_sum   TYPE i.

    LOOP AT lt_items INTO ls_item.
      lv_sum = lv_sum + ( ls_item-price * ls_item-qty ).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_008.
    TYPES: BEGIN OF ty_item,
             price    TYPE i,
             qty      TYPE i,
             discount TYPE i,
           END OF ty_item.
    DATA lt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    DATA ls_item  TYPE ty_item.
    DATA lv_sum   TYPE i.

    LOOP AT lt_items INTO ls_item.
      lv_sum = lv_sum + ( ( ls_item-price * ls_item-qty ) + ls_item-discount ).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_009.
    TYPES: BEGIN OF ty_person,
             name TYPE string,
           END OF ty_person.
    DATA lt_people TYPE STANDARD TABLE OF ty_person WITH EMPTY KEY.
    DATA ls_person TYPE ty_person.
    DATA lv_text   TYPE string.

    LOOP AT lt_people INTO ls_person.
      lv_text = lv_text && |{ ls_person-name }, |.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    TYPES: BEGIN OF ty_person,
             first_name TYPE string,
             last_name  TYPE string,
           END OF ty_person.
    DATA lt_people TYPE STANDARD TABLE OF ty_person WITH EMPTY KEY.
    DATA ls_person TYPE ty_person.
    DATA lv_names  TYPE string.

    LOOP AT lt_people INTO ls_person.
      lv_names = lv_names && ( ls_person-first_name && ls_person-last_name ).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_011.
    TYPES: BEGIN OF ty_item,
             price  TYPE i,
             active TYPE abap_bool,
           END OF ty_item.
    DATA lt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    DATA ls_item  TYPE ty_item.
    DATA lv_sum   TYPE i.

    LOOP AT lt_items INTO ls_item.
      IF ( ls_item-active = abap_true AND ( ls_item-price > 0 ) ).
        lv_sum = lv_sum + ls_item-price.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_012.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_sum     TYPE i.

    LOOP AT lt_numbers INTO lv_num WHERE table_line > 0.
      lv_sum = lv_sum + lv_num.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_013.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_sum     TYPE i.
    DATA lv_flag    TYPE abap_bool.

    LOOP AT lt_numbers INTO lv_num.
      lv_sum = lv_sum + ( lv_num * 2 ).
      lv_flag = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_014.
    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_num     TYPE i.
    DATA lv_val     TYPE i.

    LOOP AT lt_numbers INTO lv_num.
      lv_val = lv_num * 2.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
