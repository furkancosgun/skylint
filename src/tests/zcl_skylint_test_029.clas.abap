CLASS zcl_skylint_test_029 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_029 IMPLEMENTATION.
  METHOD with_finding.
    METHODS run IMPORTING a TYPE i b TYPE i c TYPE i d TYPE i
    e TYPE i f TYPE i g TYPE i h TYPE i j TYPE i.
  ENDMETHOD.

  METHOD clean_code.
    METHODS run IMPORTING a TYPE i b TYPE i.
  ENDMETHOD.
ENDCLASS.
