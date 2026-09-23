INTERFACE zif_skylint_hook PUBLIC.

  "! Hook executed before any procedure is analyzed.
  "! Reusable by any class via hook chain - keep signature minimal.
  METHODS on_before_check.

  "! Hook executed after all procedures are analyzed.
  METHODS on_after_check.

  "! Hook for attribute handling - delegates to registered hooks.
  "!
  "! @parameter it_attributes |
  "! @raising cx_static_check |
  METHODS set_attributes
    IMPORTING it_attributes TYPE if_ci_atc_check_meta_data=>ty_attributes
    RAISING   cx_static_check.

  "! Hook for prerequisite verification.
  "!
  "! @parameter rt_findings |
  METHODS verify_prerequisites
    RETURNING VALUE(rt_findings) TYPE if_ci_atc_check=>ty_findings.

ENDINTERFACE.
