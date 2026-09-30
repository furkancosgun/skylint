CLASS zcl_skylint_test_050 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_050 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_status TYPE i VALUE 0.
    IF lv_status = 42.
      lv_status = 99.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_status TYPE i VALUE 0.
    IF lv_status = 42. "#EC MAGIC_NUMBER
      lv_status = 99.  "#EC MAGIC_NUMBER
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    CONSTANTS c_max_limit TYPE i VALUE 42.
    DATA lv_status TYPE i VALUE 0.
    IF lv_status = c_max_limit.
      lv_status = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
