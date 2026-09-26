CLASS zcl_skylint_test_054 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_054 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    DATA lt_code TYPE STANDARD TABLE OF string.
    INSERT REPORT 'ZTEST' FROM lt_code.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_code TYPE STANDARD TABLE OF string.
    INSERT REPORT 'ZTEST' FROM lt_code. "#EC DANGEROUS_STMT
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_code TYPE STANDARD TABLE OF string.
    INSERT 'LINE' INTO TABLE lt_code.
  ENDMETHOD.

ENDCLASS.
