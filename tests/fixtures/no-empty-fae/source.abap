CLASS zcl_skylint_test_031 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_entry,
        field1 TYPE c LENGTH 10,
      END OF ty_entry.
    TYPES tt_entry TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_031 IMPLEMENTATION.
  METHOD test_001.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
  ENDMETHOD.

  METHOD test_002.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF s IS NOT INITIAL.
      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA t TYPE tt_entry.
    DATA r2 TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @r2 FOR ALL ENTRIES IN @t WHERE field1 = @t-field1.
  ENDMETHOD.

  METHOD test_004.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF lines( s ) > 0.
      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
