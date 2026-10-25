CLASS lcl_super DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001.
    METHODS bad_002.
    METHODS bad_003.
    METHODS good_001.
ENDCLASS.
CLASS lcl_super IMPLEMENTATION.
  METHOD bad_001.
    DATA lv_dummy TYPE i.
  ENDMETHOD.
  METHOD bad_002.
    DATA lv_dummy TYPE i.
  ENDMETHOD.
  METHOD bad_003.
    DATA lv_dummy TYPE i.
  ENDMETHOD.
  METHOD good_001.
    DATA lv_dummy TYPE i.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_test_empty_ovr DEFINITION INHERITING FROM lcl_super.
  PUBLIC SECTION.
    METHODS bad_001 REDEFINITION.
    METHODS bad_002 REDEFINITION.
    METHODS bad_003 REDEFINITION.
    METHODS good_001 REDEFINITION.
    METHODS do_something.
ENDCLASS.
CLASS zcl_test_empty_ovr IMPLEMENTATION.
  METHOD bad_001.
    super->bad_001( ).
  ENDMETHOD.
  METHOD bad_002.
    super->bad_002( ).
    RETURN.
  ENDMETHOD.
  METHOD bad_003.
    CHECK 1 = 1.
    super->bad_003( ).
    EXIT.
  ENDMETHOD.
  METHOD good_001.
    super->good_001( ).
    do_something( ).
  ENDMETHOD.
  METHOD do_something.
  ENDMETHOD.
ENDCLASS.
