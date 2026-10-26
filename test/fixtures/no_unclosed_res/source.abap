CLASS zcl_test_no_unclosed_res DEFINITION
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
ENDCLASS.

CLASS zcl_test_no_unclosed_res IMPLEMENTATION.
  METHOD test_001.
    DATA lv_file TYPE string VALUE '/tmp/file1.txt'.
    OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_file TYPE string VALUE '/tmp/file2.txt'.
    OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    CLOSE DATASET lv_file.
  ENDMETHOD.

  METHOD test_003.
    DATA dbcur TYPE cursor.
    OPEN CURSOR @dbcur FOR SELECT * FROM t100.
  ENDMETHOD.

  METHOD test_004.
    DATA dbcur TYPE cursor.
    OPEN CURSOR @dbcur FOR SELECT * FROM t100.
    CLOSE CURSOR @dbcur.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_file TYPE string VALUE '/tmp/file3.txt'.
    CLOSE DATASET lv_file.
    OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDMETHOD.

  METHOD test_006.
    DATA dbcur TYPE cursor.
    OPEN CURSOR WITH HOLD @dbcur FOR SELECT * FROM t100.
    CLOSE CURSOR @dbcur.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_file TYPE string VALUE '/tmp/file4.txt'.
    OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. "#EC NO_UNCLOSED_RES
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.
ENDCLASS.
