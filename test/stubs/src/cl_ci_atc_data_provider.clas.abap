"! Transpile-only stub for the Node.js test harness.
"! Mirrors the public API used by skylint; never shipped, never linted.
CLASS cl_ci_atc_data_provider DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get_code_provider
      RETURNING VALUE(provider) TYPE REF TO if_ci_atc_source_code_provider.
ENDCLASS.

CLASS cl_ci_atc_data_provider IMPLEMENTATION.
  METHOD get_code_provider.
  ENDMETHOD.
ENDCLASS.
