CLASS zcl_skylint_test_union DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_union IMPLEMENTATION.
  METHOD test_001.
    DATA lt_data TYPE STANDARD TABLE OF tadir-pgmid.
    SELECT pgmid FROM tadir
      UNION ALL
      SELECT pgmid FROM tadir
      INTO TABLE @lt_data.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_data TYPE STANDARD TABLE OF tadir-pgmid.
    SELECT pgmid FROM tadir
      UNION
      SELECT pgmid FROM tadir
      INTO TABLE @lt_data.
  ENDMETHOD.
ENDCLASS.
