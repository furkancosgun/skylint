CLASS zcl_test_no_obsolete_statement DEFINITION
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
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
    METHODS test_018.
    METHODS test_020.
    METHODS test_021.
    METHODS test_022.
    METHODS test_023.
    METHODS test_026.
    METHODS test_028.
    METHODS test_029.
    METHODS test_030.
    METHODS test_031.
    METHODS test_032.
    METHODS test_033.
    METHODS test_034.
    METHODS test_035.
    METHODS test_036.
    METHODS test_037.
    METHODS test_038.
    METHODS test_039.
    METHODS test_042.
    METHODS test_043.
    METHODS test_044.
    METHODS test_045.
    METHODS test_046.
    METHODS test_047.
ENDCLASS.

CLASS zcl_test_no_obsolete_statement IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    REFRESH lt_tab.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    CLEAR lt_tab.
  ENDMETHOD.

  METHOD test_005.
    BREAK-POINT.
  ENDMETHOD.

  METHOD test_006.
    STATICS sv_stat TYPE i.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_val TYPE i.
    EXPORT lv_val TO MEMORY ID 'KEY'.
  ENDMETHOD.

  METHOD test_008.
    PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      AT NEW table_line.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    DATA lv_i TYPE i.
    LOOP AT lt_tab INTO lv_i.
      SUM.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    ADD lv_x TO lv_y.
  ENDMETHOD.

  METHOD test_012.
    TABLES spfli.
  ENDMETHOD.

  METHOD test_013.
    DEFINE my_macro.
      DATA lv_dummy TYPE i.
    END-OF-DEFINITION.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_src TYPE p.
    DATA lv_dst TYPE p.
    PACK lv_src TO lv_dst.
  ENDMETHOD.

  METHOD test_015.
    DATA lv_src TYPE c LENGTH 10.
    DATA lv_dst TYPE p.
    UNPACK lv_src TO lv_dst.
  ENDMETHOD.

  METHOD test_016.
    DATA lv_fg TYPE i.
    EXTRACT lv_fg.
  ENDMETHOD.

  METHOD test_017.
    DATA: BEGIN OF COMMON PART,
            lv_shared TYPE i,
          END OF COMMON PART.
  ENDMETHOD.

  METHOD test_018.
    DATA lv_val TYPE i.
    FREE MEMORY ID 'KEY'.
  ENDMETHOD.


  METHOD test_020.
    CONTEXTS my_context.
  ENDMETHOD.

  METHOD test_021.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY INITIAL SIZE 10.
  ENDMETHOD.

  METHOD test_022.
    DATA lv_x TYPE i.
    CATCH SYSTEM-EXCEPTIONS conversion_errors = 1.
      lv_x = 1.
    ENDCATCH.
  ENDMETHOD.

  METHOD test_023.
    DATA lv_src TYPE i.
    DATA lr_ref TYPE REF TO i.
    GET REFERENCE OF lv_src INTO lr_ref.
  ENDMETHOD.



  METHOD test_026.
    SET EXTENDED CHECK ON.
  ENDMETHOD.

  METHOD test_028.
    FIELD-SYMBOLS <fs> TYPE i.
  ENDMETHOD.

  METHOD test_029.
    PARAMETER p_name TYPE string.
  ENDMETHOD.

  METHOD test_030.
    SELECT matnr FROM mara.
  ENDMETHOD.

  METHOD test_031.
    SELECT COUNT(*) FROM mara.
  ENDMETHOD.

  METHOD test_032.
    SELECT COUNT( * ) FROM mara.
  ENDMETHOD.

  METHOD test_033.
    SELECT matnr FROM mara INTO TABLE @DATA(lt_matnr).
  ENDMETHOD.

  METHOD test_034.
    EXIT FROM SQL.
  ENDMETHOD.

  METHOD test_035.
    DATA lt_values TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    FIELD-SYMBOLS <fs> TYPE i.
    SORT lt_values BY <fs>.
  ENDMETHOD.

  METHOD test_036.
    DATA lt_values TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    SORT lt_values BY table_line.
  ENDMETHOD.

  METHOD test_037.
    CALL TRANSFORMATION id SOURCE node = 1 OBJECTS a = 1.
  ENDMETHOD.

  METHOD test_038.
    FIND REGEX 'a' IN 'abc'.
  ENDMETHOD.

  METHOD test_039.
    cl_abap_regex=>create_posix( pattern = `a` ).
  ENDMETHOD.



  METHOD test_042.
    LOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_043.
    SORT.
  ENDMETHOD.

  METHOD test_044.
    FREE MEMORY.
  ENDMETHOD.

  METHOD test_045.
    TYPES ty_occurs TYPE i OCCURS 10.
  ENDMETHOD.

  METHOD test_046.
    DATA lt_occurs TYPE i OCCURS 10.
  ENDMETHOD.

  METHOD test_047.
    DATA lt_header TYPE STANDARD TABLE OF i WITH HEADER LINE.
  ENDMETHOD.
ENDCLASS.

