CLASS zcl_test_no_useless_cont DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_useless_cont IMPLEMENTATION.
  METHOD test_001.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      <fs> = 'A'.
      CONTINUE.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    WHILE lv_flag = abap_true.
      CLEAR lv_flag.
      CONTINUE.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_count TYPE i.
    DO 5 TIMES.
      lv_count += 1.
      CONTINUE.
    ENDDO.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      IF <fs> = 'X'.
        CONTINUE.
      ENDIF.
      <fs> = 'B'.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      <fs> = 'A'.
      CONTINUE ##NO_USELESS_CONT. "#EC NO_USELESS_CONT
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
