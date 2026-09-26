CLASS zcl_skylint_test_052 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS bad_method
      IMPORTING
        iv_val TYPE i
      EXPORTING
        ev_res TYPE i.

    METHODS bad_method_pc
      IMPORTING
        iv_val TYPE i
      EXPORTING
        ev_res TYPE i. "#EC PREFER_RETURNING

    METHODS good_method
      IMPORTING
        iv_val        TYPE i
      RETURNING
        VALUE(rv_res) TYPE i.

ENDCLASS.


CLASS zcl_skylint_test_052 IMPLEMENTATION.

  METHOD bad_method.
    ev_res = iv_val.
  ENDMETHOD.

  METHOD bad_method_pc.
    ev_res = iv_val.
  ENDMETHOD.

  METHOD good_method.
    rv_res = iv_val.
  ENDMETHOD.

ENDCLASS.
