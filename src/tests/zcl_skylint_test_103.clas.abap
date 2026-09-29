CLASS zcl_skylint_test_103 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_103 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY table_line = 1.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY table_line = 1. "#EC PREFER_LINE_EXISTS
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_exists TYPE abap_bool.
    IF line_exists( lt_data[ table_line = 1 ] ).
      lv_exists = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
