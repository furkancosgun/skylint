CLASS zcl_test_one_exc_class DEFINITION.
  PUBLIC SECTION.
    DATA mv_flags TYPE abap_bool.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_one_exc_class IMPLEMENTATION.

  METHOD test_001.
    IF mv_flags = abap_true.
      RAISE EXCEPTION TYPE cx_smth_first.
    ENDIF.
    RAISE EXCEPTION TYPE cx_smth_second.
  ENDMETHOD.

  METHOD test_002.
    RAISE EXCEPTION TYPE cx_smth_first.
    RAISE EXCEPTION TYPE cx_smth_first.
  ENDMETHOD.

  METHOD test_003.
    RAISE EXCEPTION NEW cx_smth_first( ).
    RAISE EXCEPTION NEW cx_smth_second( ).
  ENDMETHOD.

  METHOD test_004.
    RAISE EXCEPTION TYPE cx_smth_first.
    RAISE EXCEPTION TYPE cx_smth_second. "#EC ONE_EXC_CLASS
  ENDMETHOD.

  METHOD test_005.
    RAISE EXCEPTION TYPE cx_smth_first.
    RAISE EXCEPTION TYPE cx_smth_second.
    RAISE EXCEPTION TYPE cx_smth_third.
  ENDMETHOD.

ENDCLASS.
