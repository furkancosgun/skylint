CLASS lcl_dead_store DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_struct,
             id TYPE i,
           END OF ty_struct.

    METHODS fill
      EXPORTING ev_value TYPE i.
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
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
ENDCLASS.

CLASS lcl_dead_store IMPLEMENTATION.
  METHOD fill.
    ev_value = 0.
  ENDMETHOD.

  METHOD test_001.
    DATA lv_value TYPE i.
    lv_value = 1.
    lv_value = 2.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_value TYPE i.
    lv_value = 1.
    WRITE lv_value.
    lv_value = 2.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_value TYPE i.
    DATA lv_flag TYPE abap_bool.
    lv_value = 1.
    IF lv_flag = abap_true.
      lv_value = 2.
    ENDIF.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_value TYPE i.
    lv_value = 1.
    lv_value += 1.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_values TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_value TYPE i.
    LOOP AT lt_values INTO lv_value.
      lv_value = 1.
      lv_value = 2.
      WRITE lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_value TYPE i.
    FIELD-SYMBOLS <lv_value> TYPE i.
    lv_value = 1.
    ASSIGN lv_value TO <lv_value>.
    lv_value = 2.
    WRITE <lv_value>.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_value TYPE i.
    lv_value = 1.
    fill( IMPORTING ev_value = lv_value ).
    lv_value = 2.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_values TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_value TYPE i.
    lv_value = 1.
    READ TABLE lt_values INTO lv_value INDEX 1.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_value TYPE i.
    lv_value = 1.
    lv_value = 2.
  ENDMETHOD.

  METHOD test_010.
    DATA ls_item TYPE ty_struct.
    ls_item = VALUE #( ).
    ls_item-id = 1.
    ls_item = VALUE #( ).
    WRITE ls_item-id.
  ENDMETHOD.

  METHOD test_011.
    DATA ls_item TYPE ty_struct.
    ls_item = VALUE #( id = 1 ).
    WRITE ls_item-id.
    ls_item = VALUE #( id = 2 ).
    WRITE ls_item-id.
  ENDMETHOD.

  METHOD test_012.
    STATICS sv_value TYPE i.
    sv_value = 1.
    sv_value = 2.
    WRITE sv_value.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_value TYPE i.
    lv_value = 1.
    CLEAR lv_value.
    lv_value = 2.
    WRITE lv_value.
  ENDMETHOD.

  METHOD test_014.
    DATA lt_values TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_value TYPE i.
    lv_value = 1.
    LOOP AT lt_values INTO lv_value.
      WRITE lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_015.
    DATA lv_value TYPE i.
    DATA lv_other TYPE i.
    lv_value = 1.
    lv_other = 2.
    lv_value = 3.
    WRITE lv_value.
    WRITE lv_other.
  ENDMETHOD.

  METHOD test_016.
    DATA lv_raw TYPE x LENGTH 4.
    lv_raw(1) = 'AA'.
    lv_raw+1(1) = 'BB'.
    lv_raw+2(1) = 'CC'.
    WRITE lv_raw.
  ENDMETHOD.

  METHOD test_017.
    DATA ls_item TYPE ty_struct.
    DATA lv_id   TYPE i.
    ls_item = VALUE #( id = 1 ).
    ls_item-id = 2.
    lv_id = ls_item-id.
    WRITE lv_id.
  ENDMETHOD.
ENDCLASS.
