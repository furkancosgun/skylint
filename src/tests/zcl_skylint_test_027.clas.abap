CLASS zcl_skylint_test_027 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_public_bad TYPE i.
    DATA mv_public_suppressed TYPE i. "#EC NUM_PUBLIC_ATTR
    DATA mv_public_ok TYPE i READ-ONLY.
    CONSTANTS c_my_const TYPE i VALUE 10.

  PROTECTED SECTION.
    DATA mv_prot TYPE i.

  PRIVATE SECTION.
    DATA mv_priv TYPE i.
ENDCLASS.


CLASS zcl_skylint_test_027 IMPLEMENTATION.
ENDCLASS.
