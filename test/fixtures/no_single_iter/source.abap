CLASS zcl_test_no_single_iter DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_single_iter IMPLEMENTATION.
  METHOD test_001.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      EXIT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DO 5 TIMES.
      RETURN.
    ENDDO.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      IF <fs> = 'A'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      CHECK <fs> IS NOT INITIAL.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <fs> TYPE string.
    LOOP AT lt_items ASSIGNING <fs>.
      EXIT ##NO_SINGLE_ITER. "#EC NO_SINGLE_ITER
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
