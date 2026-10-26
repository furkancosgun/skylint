CLASS zcl_skylint_test_no_catch_reraise DEFINITION
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
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
ENDCLASS.

CLASS zcl_skylint_test_no_catch_reraise IMPLEMENTATION.
  METHOD test_001.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        lv_flag = abap_true.
        RAISE EXCEPTION lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDTRY.
  ENDMETHOD.

  METHOD test_004.
    TRY.
        RAISE EXCEPTION NEW cx_sy_zerodivide( ).
      CATCH cx_sy_zerodivide.
        RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDTRY.
  ENDMETHOD.

  METHOD test_005.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION TYPE cx_root EXPORTING previous = lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_006.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION NEW cx_root( ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_007.
    DATA lx_err TYPE REF TO cx_root.
    DATA lv_cleaned TYPE abap_bool.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION lx_err.
      CLEANUP.
        lv_cleaned = abap_true.
    ENDTRY.
  ENDMETHOD.

  METHOD test_008.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION NEW cx_sy_zerodivide( previous = lx_err ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_009.
    DATA lx_zero TYPE REF TO cx_sy_zerodivide.
    DATA lx_err TYPE REF TO cx_root.
    DATA lv_logged TYPE abap_bool.
    TRY.
        RAISE EXCEPTION NEW cx_sy_zerodivide( ).
      CATCH cx_sy_zerodivide INTO lx_zero.
        lv_logged = abap_true.
        RAISE EXCEPTION lx_zero.
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_010.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
        RAISE EXCEPTION NEW cx_root( textid = ( cx_root=>cx_root ) previous = lx_err ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_011.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_root( ).
      CATCH cx_root INTO lx_err.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.