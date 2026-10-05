CLASS zcl_skylint_test_029 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS run_with_many_params
      IMPORTING
        a TYPE i b TYPE i c TYPE i d TYPE i
        e TYPE i f TYPE i g TYPE i h TYPE i j TYPE i.
    METHODS run_clean
      IMPORTING
        a TYPE i b TYPE i.
ENDCLASS.

CLASS zcl_skylint_test_029 IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD run_with_many_params.
    RETURN.
  ENDMETHOD.

  METHOD run_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.
