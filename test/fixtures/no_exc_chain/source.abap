CLASS zcl_skylint_test_no_exc_chain DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_skylint_test_no_exc_chain IMPLEMENTATION.
  METHOD test_001.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION NEW cx_root( ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION NEW cx_root( previous = lx_err ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION TYPE cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_004.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION TYPE cx_root EXPORTING previous = lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_005.
    RAISE EXCEPTION TYPE cx_root.
  ENDMETHOD.

  METHOD test_006.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION TYPE cx_root EXPORTING previous = lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_007.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION lx_err.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
