CLASS zcl_test_no_obs_control DEFINITION
  PUBLIC FINAL
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
    METHODS test_011.
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.
ENDCLASS.

CLASS zcl_test_no_obs_control IMPLEMENTATION.
  METHOD test_001.
    BREAK-POINT.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 1.
  ENDMETHOD.

  METHOD test_003.
    PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      AT NEW table_line.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    DATA lv_i TYPE i.
    LOOP AT lt_tab INTO lv_i.
      SUM.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DEFINE my_macro.
      DATA lv_dummy TYPE i.
    END-OF-DEFINITION.
  ENDMETHOD.

  METHOD test_007.
    SET EXTENDED CHECK ON.
  ENDMETHOD.

  METHOD test_008.
    BREAK developer.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      AT FIRST.
      ENDAT.
      AT END OF table_line.
      ENDAT.
      AT LAST.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    EXIT FROM SQL.
  ENDMETHOD.

  METHOD test_011.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    FIELD-SYMBOLS <fs> TYPE i.
    SORT lt_tab BY <fs>.
    SORT lt_tab BY (sy-cprog).
  ENDMETHOD.

  METHOD test_012.
    SELECT COUNT( * ) FROM t000.
    SELECT COUNT(*) FROM t000.
    SELECT * FROM t000.
  ENDMETHOD.

  METHOD test_013.
    DO 10 TIMES.
      EXIT.
    ENDDO.
  ENDMETHOD.

  METHOD test_014.
    CATCH SYSTEM-EXCEPTIONS arithmetic_errors = 4.
      DATA lv_res TYPE i.
      lv_res = 1 / 0.
    ENDCATCH.
  ENDMETHOD.
ENDCLASS.
