CLASS zcl_test_pref_loop_where DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             status TYPE i,
             name   TYPE string,
           END OF ty_row.
    DATA lt_rows TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_test_pref_loop_where IMPLEMENTATION.

  METHOD test_001.
    FIELD-SYMBOLS <ls_row> TYPE ty_row.
    LOOP AT lt_rows ASSIGNING <ls_row>.
      IF <ls_row>-status <> 1.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    FIELD-SYMBOLS <ls_row> TYPE ty_row.
    LOOP AT lt_rows ASSIGNING <ls_row>. "#EC PREF_LOOP_WHERE
      IF <ls_row>-status <> 1.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    FIELD-SYMBOLS <ls_row> TYPE ty_row.
    LOOP AT lt_rows ASSIGNING <ls_row> WHERE status = 2.
      <ls_row>-name = 'ok'.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    FIELD-SYMBOLS <ls_row> TYPE ty_row.
    DATA lv_dummy TYPE i.
    LOOP AT lt_rows ASSIGNING <ls_row>.
      IF <ls_row>-status <> 1.
        lv_dummy = 1.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    FIELD-SYMBOLS <ls_row> TYPE ty_row.
    LOOP AT lt_rows ASSIGNING <ls_row>.
      <ls_row>-name = 'first'.
      IF <ls_row>-status <> 1.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    FIELD-SYMBOLS <ls_row> TYPE ty_row.
    LOOP AT lt_rows ASSIGNING <ls_row>.
      LOOP AT lt_rows ASSIGNING <ls_row>.
        IF <ls_row>-status <> 1.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
