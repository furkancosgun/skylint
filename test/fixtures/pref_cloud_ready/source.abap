CLASS zcl_skylint_test_pref_cloud_ready DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA lv_data TYPE string.
    DATA itab_stable TYPE string_table.
    DATA lo_ole TYPE ole2_object.
    DATA lo_obj TYPE REF TO zcl_skylint_test_pref_cloud_ready.
    DATA lv_result TYPE i.
    DATA lt_tab TYPE string_table.

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
ENDCLASS.

CLASS zcl_skylint_test_pref_cloud_ready IMPLEMENTATION.
  METHOD test_001.
    CALL TRANSACTION 'ZTRAN'.
  ENDMETHOD.

  METHOD test_002.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename = 'test.txt'.
  ENDMETHOD.

  METHOD test_003.
    SUBMIT zreport.
  ENDMETHOD.

  METHOD test_004.
    EXPORT data = lv_data TO MEMORY ID 'SKYLINT'.
  ENDMETHOD.

  METHOD test_005.
    IMPORT data = lv_data FROM MEMORY ID 'SKYLINT'.
  ENDMETHOD.

  METHOD test_006.
    DELETE DATASET 'test.txt'.
  ENDMETHOD.

  METHOD test_007.
    SORT itab_stable.
  ENDMETHOD.

  METHOD test_008.
    CALL SCREEN 100.
  ENDMETHOD.

  METHOD test_009.
    LOOP AT lt_tab INTO DATA(lv_line).
      AT LAST.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    CREATE OBJECT lo_ole 'SAPGUI'.
  ENDMETHOD.

  METHOD test_011.
    CREATE OBJECT lo_obj TYPE zcl_skylint_test_pref_cloud_ready.
  ENDMETHOD.

  METHOD test_012.
    SUBMIT zreport. "#EC PREF_CLOUD_READY
  ENDMETHOD.

  METHOD test_013.
    COMPUTE lv_result = lv_result + 1.
  ENDMETHOD.

  METHOD test_014.
    lv_result = lv_result + 1.
  ENDMETHOD.

  METHOD test_015.
    FIELD-SYMBOLS <fs_value> TYPE i.
  ENDMETHOD.
ENDCLASS.
