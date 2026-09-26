CLASS zcl_skylint_test_034 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS bad_method
      IMPORTING
        iv_1 TYPE i
        iv_2 TYPE i
        iv_3 TYPE i
        iv_4 TYPE i
        iv_5 TYPE i
        iv_6 TYPE i
        iv_7 TYPE i
        iv_8 TYPE i
        iv_9 TYPE i.

    METHODS bad_method_suppressed
      IMPORTING
        iv_1 TYPE i
        iv_2 TYPE i
        iv_3 TYPE i
        iv_4 TYPE i
        iv_5 TYPE i
        iv_6 TYPE i
        iv_7 TYPE i
        iv_8 TYPE i
        iv_9 TYPE i ##PARAM_COUNT.

    METHODS good_method
      IMPORTING
        iv_1 TYPE i
        iv_2 TYPE i.
ENDCLASS.


CLASS zcl_skylint_test_034 IMPLEMENTATION.
  METHOD bad_method.
    RETURN.
  ENDMETHOD.

  METHOD bad_method_suppressed.
    RETURN.
  ENDMETHOD.

  METHOD good_method.
    RETURN.
  ENDMETHOD.
ENDCLASS.
