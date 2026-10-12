"! Transpile-only stub for the Node.js test harness.
"! Mirrors the public API used by skylint; never shipped, never linted.
CLASS cl_ci_atc_assistant_factory DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS create_quickfixes
      RETURNING VALUE(quickfixes) TYPE REF TO cl_ci_atc_quickfixes.

    METHODS create_quickfix_context
      IMPORTING descriptor TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor
      RETURNING VALUE(result) TYPE REF TO cl_ci_atc_quickfix_context.

    METHODS create_finding_details
      RETURNING VALUE(details) TYPE REF TO cl_ci_atc_finding_details.
ENDCLASS.

CLASS cl_ci_atc_assistant_factory IMPLEMENTATION.
  METHOD create_quickfixes.
  ENDMETHOD.

  METHOD create_quickfix_context.
  ENDMETHOD.

  METHOD create_finding_details.
  ENDMETHOD.
ENDCLASS.
