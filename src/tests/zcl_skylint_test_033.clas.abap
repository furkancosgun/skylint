CLASS zcl_skylint_test_033 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_033 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lx_root TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_sy_zerodivide( ).
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE cx_no_check.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lx_root TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_sy_zerodivide( ).
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE cx_no_check. "#EC LOST_PREVIOUS
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    DATA lx_root TYPE REF TO cx_root.
    TRY.
        RAISE EXCEPTION NEW cx_sy_zerodivide( ).
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE cx_no_check EXPORTING previous = lx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
