CLASS zcl_skylint_test_022 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_022 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lo_obj TYPE REF TO zcl_skylint_test_022.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lo_obj TYPE REF TO zcl_skylint_test_022.
    CREATE OBJECT lo_obj. "#EC PREF_NEW
  ENDMETHOD.

  METHOD valid_code.
    DATA lo_obj TYPE REF TO zcl_skylint_test_022.
    DATA lv_cls TYPE string VALUE 'ZCL_SKYLINT_TEST_022'.
    lo_obj = NEW #( ).
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.
ENDCLASS.
