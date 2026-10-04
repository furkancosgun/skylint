CLASS ltcl_check_054 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic procedure is always ZSKYLINT_TEST=>TEST,
    " which never matches '*CONSTRUCTOR*', so check returns early even when
    " the statement count exceeds the threshold (11 statements below).
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_054 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_054( )
                                               it_source = VALUE #( ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` )
                                                                    ( `lv_val = 1.` ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_054( )
                                               it_source = VALUE #( ( `lv_val = 1.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD constructor.
    DATA lv_val TYPE i.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.
ENDCLASS.
