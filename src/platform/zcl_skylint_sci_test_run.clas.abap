CLASS zcl_skylint_sci_test_run DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                is_object   TYPE zif_skylint_types=>ty_object
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.
ENDCLASS.


CLASS zcl_skylint_sci_test_run IMPLEMENTATION.
  METHOD execute.
    " Adapter for SAP NetWeaver / S/4HANA On-Premise Code Inspector test driver
    RETURN.
  ENDMETHOD.
ENDCLASS.
