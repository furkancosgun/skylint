"! Transpile-only stub for the Node.js test harness.
"! Mirrors the public API used by skylint; never shipped, never linted.
CLASS cl_ci_atc_quickfixes DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_quickfix_code TYPE c LENGTH 10.

    METHODS create_quickfix
      IMPORTING quickfix_code TYPE ty_quickfix_code
      RETURNING VALUE(result) TYPE REF TO if_ci_atc_quickfix.
ENDCLASS.

CLASS cl_ci_atc_quickfixes IMPLEMENTATION.
  METHOD create_quickfix.
  ENDMETHOD.
ENDCLASS.
