CLASS zcl_skylint_test_050 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS bad_method
      EXPORTING
        ev_a TYPE i
        ev_b TYPE string.

    METHODS bad_method_pc
      EXPORTING
        ev_a TYPE i
        ev_b TYPE string. "#EC OUTPUT_PARAMS

    METHODS good_method
      IMPORTING
        iv_a          TYPE i
      RETURNING
        VALUE(rv_res) TYPE i.

ENDCLASS.


CLASS zcl_skylint_test_050 IMPLEMENTATION.

  METHOD bad_method.
    ev_a = 1.
    ev_b = 'A'.
  ENDMETHOD.

  METHOD bad_method_pc.
    ev_a = 1.
    ev_b = 'B'.
  ENDMETHOD.

  METHOD good_method.
    rv_res = iv_a.
  ENDMETHOD.

ENDCLASS.
