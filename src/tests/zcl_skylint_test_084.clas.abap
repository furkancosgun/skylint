CLASS zcl_skylint_test_084 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_084 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    IF sy-uname = 'ADMIN'.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    IF sy-uname = 'ADMIN'. "#EC AVOID_HARDCODED_USER
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_allowed_user TYPE string VALUE 'ADMIN'.
    IF sy-uname = lv_allowed_user.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
