CLASS zcl_test_no_empty_fae DEFINITION
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
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_test_no_empty_fae IMPLEMENTATION.
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

  METHOD test_005.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    CHECK s IS NOT INITIAL.
    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
  ENDMETHOD.

  METHOD test_006.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF s IS INITIAL.
      RETURN.
    ENDIF.
    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
  ENDMETHOD.

  METHOD test_007.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF s IS NOT INITIAL.
      " closed block
    ENDIF.
    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
  ENDMETHOD.

  METHOD test_008.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF s IS INITIAL.
      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
