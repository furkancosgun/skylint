CLASS zcl_skylint_test_038 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_entry,
        obj_name TYPE string,
      END OF ty_entry.
    TYPES tt_entries TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_038 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF tadir WITH DEFAULT KEY.
    SELECT * FROM tadir INTO TABLE @lt_data.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF tadir WITH DEFAULT KEY.
    SELECT * FROM tadir INTO TABLE @lt_data. "#EC SELECT_PERF
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE tt_entries.
    SELECT obj_name FROM tadir INTO TABLE @lt_data.
  ENDMETHOD.
ENDCLASS.
