CLASS zcl_test_pref_filter DEFINITION
  PUBLIC
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
ENDCLASS.

CLASS zcl_test_pref_filter IMPLEMENTATION.
  METHOD test_001.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0.
        APPEND ls_row TO lt_dst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_row> TYPE i.
    LOOP AT lt_src ASSIGNING <ls_row>.
      IF <ls_row> > 0.
        APPEND <ls_row> TO lt_dst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0.
        APPEND ls_row TO lt_src.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF sy-tabix > 1.
        APPEND ls_row TO lt_dst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0.
        APPEND ls_row TO lt_dst.
        WRITE ls_row.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0 OR ls_row < 0.
        APPEND ls_row TO lt_dst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    DATA lv_other TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0.
        APPEND lv_other TO lt_dst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0.
        WRITE ls_row.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF ls_row > 0.
        APPEND ls_row TO lt_dst INDEX 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    DATA lt_src TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA ls_row TYPE i.
    LOOP AT lt_src INTO ls_row.
      IF NOT ls_row IS INITIAL.
        APPEND ls_row TO lt_dst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
