CLASS zcl_skylint_test_runner DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_open_test_run
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS run
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                iv_class    TYPE string
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.
ENDCLASS.


CLASS zcl_skylint_test_runner IMPLEMENTATION.
  METHOD run.
    DATA lo_runner TYPE REF TO zcl_skylint_test_runner.
    CREATE OBJECT lo_runner.
    lo_runner->execute( io_check    = io_check
                        iv_class    = iv_class
                        it_expected = it_expected ).
  ENDMETHOD.
ENDCLASS.
