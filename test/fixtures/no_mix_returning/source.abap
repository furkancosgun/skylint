CLASS lcl_bad DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001
      EXPORTING ev_foo TYPE i
      RETURNING VALUE(rv_bar) TYPE string.
    CLASS-METHODS bad_002
      CHANGING cv_foo TYPE i
      RETURNING VALUE(rv_bar) TYPE string.
ENDCLASS.

CLASS lcl_good DEFINITION.
  PUBLIC SECTION.
    METHODS good_001
      IMPORTING iv_foo TYPE i
      RETURNING VALUE(rv_bar) TYPE string.
    CLASS-METHODS good_002
      IMPORTING iv_foo TYPE i
      EXPORTING ev_bar TYPE string.
ENDCLASS.
