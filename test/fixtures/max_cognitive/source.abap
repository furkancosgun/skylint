CLASS zcl_skylint_test_max_cognitive DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_max_cognitive IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      lv_x = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      IF lv_x = 2.
        IF lv_x = 3.
          IF lv_x = 4.
            IF lv_x = 5.
              IF lv_x = 6.
                lv_x = 7.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      IF lv_x = 2.
        IF lv_x = 3.
          IF lv_x = 4.
            IF lv_x = 5.
              IF lv_x = 6.
                lv_x = 7.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
