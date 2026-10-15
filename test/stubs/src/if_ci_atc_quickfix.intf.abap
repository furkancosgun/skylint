"! Transpile-only stub for the Node.js test harness.
"! Mirrors the public API used by skylint; never shipped, never linted.
INTERFACE if_ci_atc_quickfix
  PUBLIC.

  TYPES ty_code TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  METHODS replace
    IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
              code    TYPE ty_code
    RETURNING VALUE(self) TYPE REF TO if_ci_atc_quickfix.

  METHODS insert_before
    IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
              code    TYPE ty_code
    RETURNING VALUE(self) TYPE REF TO if_ci_atc_quickfix.

  METHODS insert_after
    IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
              code    TYPE ty_code
    RETURNING VALUE(self) TYPE REF TO if_ci_atc_quickfix.
ENDINTERFACE.
