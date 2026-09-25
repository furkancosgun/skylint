INTERFACE if_ci_atc_unit_test_case PUBLIC.

  METHODS execute_and_assert
    IMPORTING
      expected_findings TYPE if_ci_atc_unit_asserter=>ty_expected_findings
      asserter_config   TYPE if_ci_atc_unit_asserter=>ty_asserter_config OPTIONAL
    RAISING
      cx_static_check.

ENDINTERFACE.
