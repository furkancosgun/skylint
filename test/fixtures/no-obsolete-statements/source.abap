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
    METHODS test_019.
    METHODS test_020.
    METHODS test_021.
    METHODS test_022.
    METHODS test_023.
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

  METHOD test_019.
    DATA lt_t1 TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    DATA lt_t2 TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    DATA ls_wa TYPE i.
    PROVIDE field1 FROM lt_t1 INTO ls_wa.
    ENDPROVIDE.
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
ENDCLASS.
