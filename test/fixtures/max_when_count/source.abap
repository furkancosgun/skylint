CLASS zcl_skylint_test_max_when DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_max_when IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i VALUE 1.
    CASE lv_val.
      WHEN 1.
        CLEAR lv_val.
      WHEN 2.
        CLEAR lv_val.
      WHEN 3.
        CLEAR lv_val.
      WHEN 4.
        CLEAR lv_val.
      WHEN 5.
        CLEAR lv_val.
      WHEN 6.
        CLEAR lv_val.
      WHEN 7.
        CLEAR lv_val.
      WHEN 8.
        CLEAR lv_val.
      WHEN 9.
        CLEAR lv_val.
      WHEN 10.
        CLEAR lv_val.
      WHEN OTHERS.
        CLEAR lv_val.
    ENDCASE.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i VALUE 1.
    CASE lv_val.
      WHEN 1.
        CLEAR lv_val.
      WHEN 2.
        CLEAR lv_val.
      WHEN OTHERS.
        CLEAR lv_val.
    ENDCASE.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i VALUE 1.
    DATA lv_b TYPE i VALUE 2.
    CASE lv_a.
      WHEN 1.
        CASE lv_b.
          WHEN 1.
            CLEAR lv_b.
          WHEN 2.
            CLEAR lv_b.
          WHEN OTHERS.
            CLEAR lv_b.
        ENDCASE.
      WHEN 2.
        CLEAR lv_a.
      WHEN OTHERS.
        CLEAR lv_a.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
