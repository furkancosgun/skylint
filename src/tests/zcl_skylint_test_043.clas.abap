CLASS zcl_skylint_test_043 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS bad_method
      EXCEPTIONS
        failed.

    METHODS bad_method_pc
      EXCEPTIONS
        failed. "#EC CLASS_EXCEPTIONS

    METHODS good_method
      RAISING
        cx_static_check.

ENDCLASS.


CLASS zcl_skylint_test_043 IMPLEMENTATION.

  METHOD bad_method.
  ENDMETHOD.

  METHOD bad_method_pc.
  ENDMETHOD.

  METHOD good_method.
  ENDMETHOD.

ENDCLASS.
