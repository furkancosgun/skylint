CLASS zcl_skylint_test_031 DEFINITION
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


CLASS zcl_skylint_test_031 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_entries TYPE tt_entries.
    DATA lt_res TYPE tt_entries.
    SELECT obj_name FROM tadir FOR ALL ENTRIES IN @lt_entries WHERE obj_name = @lt_entries-obj_name INTO TABLE @lt_res.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_entries TYPE tt_entries.
    DATA lt_res TYPE tt_entries.
    SELECT obj_name FROM tadir FOR ALL ENTRIES IN @lt_entries WHERE obj_name = @lt_entries-obj_name INTO TABLE @lt_res. "#EC FAE_NO_CHECK
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_entries TYPE tt_entries.
    DATA lt_res TYPE tt_entries.
    IF lt_entries IS NOT INITIAL.
      SELECT obj_name FROM tadir FOR ALL ENTRIES IN @lt_entries WHERE obj_name = @lt_entries-obj_name INTO TABLE @lt_res.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
