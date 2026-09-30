CLASS zcl_skylint_test_055 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS without_pseudo_comments.
    CLASS-METHODS with_pseudo_comments.
    CLASS-METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_055 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    " Static only
  ENDMETHOD.

  METHOD with_pseudo_comments.
    " Static only "#EC AVOID_STATIC_CLS
  ENDMETHOD.

  METHOD valid_code.
    " Static only
  ENDMETHOD.
ENDCLASS.
