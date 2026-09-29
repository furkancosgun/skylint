CLASS zcl_skylint_test_061 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_061 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_str TYPE string VALUE 'Hello World'.
    DATA lv_res TYPE string.
    lv_res = COND string( WHEN 1 = 1 THEN 'Yes' ELSE 'No' ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_str TYPE string VALUE 'Hello World'. "#EC STRING_BACKTICK
    DATA lv_res TYPE string.
    lv_res = COND string( WHEN 1 = 1 THEN 'Yes' ELSE 'No' ). "#EC STRING_BACKTICK
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_str TYPE string VALUE `Hello World`.
    DATA lv_res TYPE string.
    lv_res = COND string( WHEN 1 = 1 THEN `Yes` ELSE `No` ).
    DATA lv_char TYPE c LENGTH 10 VALUE 'char literal'.
  ENDMETHOD.
ENDCLASS.
