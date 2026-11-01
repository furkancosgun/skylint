CLASS lcl_test_enum DEFINITION.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_status,
        open   TYPE string VALUE 'O',
        closed TYPE string VALUE 'C',
      END OF c_status.
    CONSTANTS c_single TYPE i VALUE 1.
    METHODS test_001.
ENDCLASS.

CLASS lcl_test_enum IMPLEMENTATION.
  METHOD test_001.
    CONSTANTS:
      BEGIN OF c_modes,
        read  TYPE i VALUE 1,
        write TYPE i VALUE 2,
      END OF c_modes.
    DATA lv_mode TYPE i.
    lv_mode = c_modes-read.
  ENDMETHOD.
ENDCLASS.
