CLASS zcl_skylint_test_no_loop_into DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
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
ENDCLASS.
