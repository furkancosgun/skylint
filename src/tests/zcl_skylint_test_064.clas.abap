CLASS zcl_skylint_test_064 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_064 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE string.
    SELECT SINGLE obj_name FROM tadir INTO @lv_val WHERE obj_name = 'TEST'.
    lv_val = 'DONE'.
    DATA lv_str TYPE string VALUE 'Hello World'.
    FIND 'World' IN lv_str.
    RETURN.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE string.
    SELECT SINGLE obj_name FROM tadir INTO @lv_val WHERE obj_name = 'TEST'. "#EC CHECK_SUBRC
    lv_val = 'DONE'.
    DATA lv_str TYPE string VALUE 'Hello World'.
    FIND 'World' IN lv_str. "#EC CHECK_SUBRC
    RETURN.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE string.
    SELECT SINGLE obj_name FROM tadir INTO @lv_val WHERE obj_name = 'TEST'.
    IF sy-subrc = 0.
      lv_val = 'FOUND'.
    ENDIF.
    DATA lv_str TYPE string VALUE 'Hello World'.
    FIND 'World' IN lv_str.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
