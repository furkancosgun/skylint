"! Transpile-only stub for the Node.js test harness.
"! Mirrors the public API used by skylint; never shipped, never linted.
CLASS cl_ci_atc_finding_details DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS attach_quickfixes
      IMPORTING quickfixes TYPE REF TO cl_ci_atc_quickfixes
      RETURNING VALUE(result) TYPE REF TO cl_ci_atc_finding_details.
ENDCLASS.

CLASS cl_ci_atc_finding_details IMPLEMENTATION.
  METHOD attach_quickfixes.
    result = me.
  ENDMETHOD.
ENDCLASS.
