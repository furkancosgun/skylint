CLASS zcl_skylint_test_001 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.

ENDCLASS.


CLASS zcl_skylint_test_001 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TEST-SEAM seam1.
      DATA lv_a TYPE i.
      lv_a = 1.
    END-TEST-SEAM.

    IF 1 = 1.
      TEST-SEAM seam2.
      END-TEST-SEAM.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TEST-SEAM seam1. "#EC TEST_SEAM_USAGE
      DATA lv_a TYPE i.
      lv_a = 1.
    END-TEST-SEAM.

    IF 1 = 1.
      TEST-SEAM seam2. "#EC TEST_SEAM_USAGE
      END-TEST-SEAM.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
