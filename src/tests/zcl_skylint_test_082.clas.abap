CLASS zcl_skylint_test_082 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_082 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_str TYPE string VALUE 'Hello World'.
    FIND 'World' IN lv_str.
    RETURN.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_str TYPE string VALUE 'Hello World'.
    FIND 'World' IN lv_str. "#EC CHECK_FIND_SUBRC
    RETURN.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_str TYPE string VALUE 'Hello World'.
    FIND 'World' IN lv_str.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
