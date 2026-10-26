CLASS zcl_skylint_test_pref_when_others DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_pref_when_others IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN 1.
        lv_x = 1.
      WHEN 2.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN 1.
        lv_x = 1.
      WHEN OTHERS.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN OTHERS.
        lv_x = 1.
      WHEN 2.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN 1.
        lv_x = 1.
    ENDCASE.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    CASE lv_x.
      WHEN 1.
        CASE lv_y.
          WHEN 1.
            lv_y = 1.
          WHEN 2.
            lv_y = 2.
        ENDCASE.
      WHEN OTHERS.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
