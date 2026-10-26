CLASS zcl_skylint_test_no_loop_into DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_item,
        id     TYPE i,
        status TYPE c LENGTH 1,
        type   TYPE c LENGTH 1,
      END OF ty_item,
      tt_items TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

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
ENDCLASS.

CLASS zcl_skylint_test_no_loop_into IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE ty_tab.
    DATA ls_row TYPE i.
    LOOP AT lt_tab INTO ls_row.
      ls_row = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE ty_tab.
    FIELD-SYMBOLS <ls_row> TYPE i.
    LOOP AT lt_tab ASSIGNING <ls_row>.
      <ls_row> = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_ref TYPE REF TO ty_tab.
    DATA ls_row TYPE i.
    LOOP AT lt_ref->* INTO ls_row.
      ls_row = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE ty_tab.
    DATA lr_row TYPE REF TO i.
    LOOP AT lt_tab REFERENCE INTO lr_row.
      lr_row->* = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_tab TYPE ty_tab.
    LOOP AT lt_tab INTO DATA(ls_inline).
      ls_inline = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_tab TYPE tt_items.
    DATA ls_row TYPE ty_item.
    LOOP AT lt_tab INTO ls_row WHERE ( status = 'A' ).
      ls_row-id = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_tab TYPE tt_items.
    FIELD-SYMBOLS <ls_row> TYPE ty_item.
    LOOP AT lt_tab ASSIGNING <ls_row> WHERE ( status = 'A' ).
      <ls_row>-id = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_tab TYPE tt_items.
    LOOP AT lt_tab TRANSPORTING NO FIELDS WHERE ( id = 10 ).
      EXIT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_tab TYPE tt_items.
    DATA ls_row TYPE ty_item.
    LOOP AT lt_tab INTO ls_row FROM 1 TO 10 WHERE ( status = 'A' AND ( type = 'B' OR type = 'C' ) ).
      ls_row-id = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    DATA lt_tab TYPE tt_items.
    DATA lr_row TYPE REF TO ty_item.
    LOOP AT lt_tab REFERENCE INTO lr_row WHERE ( status = 'A' AND id > 5 ).
      lr_row->id = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_011.
    DATA lt_tab TYPE tt_items.
    FIELD-SYMBOLS <ls_row> TYPE ty_item.
    LOOP AT lt_tab ASSIGNING <ls_row> FROM 1 TO 5 WHERE ( ( status = 'A' ) AND ( id = 10 ) ).
      <ls_row>-id = 1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
