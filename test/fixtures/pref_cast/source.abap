CLASS zcl_test_prefer_cast DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_prefer_cast IMPLEMENTATION.
  METHOD test_001.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_child ?= lo_parent.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_child = CAST #( lo_parent ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    MOVE lo_parent ?TO lo_child.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_parent = lo_child.
  ENDMETHOD.
ENDCLASS.
