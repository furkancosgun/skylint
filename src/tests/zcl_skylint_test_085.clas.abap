CLASS zcl_skylint_test_085 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_085 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE TABLE OF tadir.
    SELECT * FROM tadir USING CLIENT '100' INTO TABLE @lt_data.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE TABLE OF tadir.
    SELECT * FROM tadir USING CLIENT '100' INTO TABLE @lt_data. "#EC AVOID_CLIENT_SPEC
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE TABLE OF tadir.
    SELECT * FROM tadir INTO TABLE @lt_data.
  ENDMETHOD.
ENDCLASS.
