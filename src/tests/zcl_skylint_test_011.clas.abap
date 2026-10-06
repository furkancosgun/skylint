CLASS zcl_skylint_test_011 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_011 IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    READ TABLE lt_tab TRANSPORTING NO FIELDS.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    READ TABLE lt_tab INTO ls_row INDEX 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    DATA lv_key TYPE string.
    READ TABLE lt_tab TRANSPORTING NO FIELDS WITH KEY table_line = lv_key.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    IF line_exists( lt_tab[ 1 ] ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

