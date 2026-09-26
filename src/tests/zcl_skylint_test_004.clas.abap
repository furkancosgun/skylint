CLASS zcl_skylint_test_004 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
ENDCLASS.


CLASS zcl_skylint_test_004 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TYPES ty_strings TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TYPES ty_strings TYPE STANDARD TABLE OF string WITH DEFAULT KEY. "#EC DEFAULT_KEY
  ENDMETHOD.
ENDCLASS.
