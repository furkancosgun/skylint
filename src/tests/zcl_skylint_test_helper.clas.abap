CLASS zcl_skylint_test_helper DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS create_test_procedure
      IMPORTING it_statements       TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rs_procedure) TYPE if_ci_atc_source_code_provider=>ty_procedure.

ENDCLASS.


CLASS zcl_skylint_test_helper IMPLEMENTATION.
  METHOD create_test_procedure.
    rs_procedure-id-name    = 'TEST_METHOD'.
    rs_procedure-statements = it_statements.
  ENDMETHOD.
ENDCLASS.
