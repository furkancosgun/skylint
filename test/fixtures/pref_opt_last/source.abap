CLASS lcl_bad_opt DEFINITION.
  PUBLIC SECTION.
    METHODS test_001
      IMPORTING
        iv_opt TYPE i OPTIONAL
        iv_req TYPE i.
ENDCLASS.

CLASS lcl_good_opt DEFINITION.
  PUBLIC SECTION.
    METHODS test_002
      IMPORTING
        iv_req TYPE i
        iv_opt TYPE i OPTIONAL.
ENDCLASS.

CLASS lcl_bad_def DEFINITION.
  PUBLIC SECTION.
    METHODS test_003
      IMPORTING
        iv_def TYPE i DEFAULT 0
        iv_req TYPE i.
ENDCLASS.

CLASS lcl_suppressed DEFINITION.
  PUBLIC SECTION.
    METHODS test_004 "#EC PREF_OPTIONAL_LAST
      IMPORTING
        iv_opt TYPE i OPTIONAL
        iv_req TYPE i.
ENDCLASS.
