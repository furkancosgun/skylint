CLASS zcl_skylint_test_045 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_045 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TABLES tadir.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TABLES tadir. "#EC LOCAL_TABLES
  ENDMETHOD.

  METHOD valid_code.
    DATA ls_tadir TYPE tadir.
    ls_tadir-obj_name = 'TEST'.
  ENDMETHOD.
ENDCLASS.
