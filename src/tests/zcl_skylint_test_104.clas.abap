CLASS zcl_skylint_test_104 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_104 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_idx TYPE i.

    READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY table_line = 1.
    lv_idx = sy-tabix.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_idx TYPE i.

    READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY table_line = 1. "#EC PREFER_LINE_INDEX
    lv_idx = sy-tabix.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_idx TYPE i.

    lv_idx = line_index( lt_data[ table_line = 1 ] ).
  ENDMETHOD.
ENDCLASS.
