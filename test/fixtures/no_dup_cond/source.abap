CLASS zcl_test_no_duplicate_conditio DEFINITION
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
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.
ENDCLASS.


CLASS zcl_test_no_duplicate_conditio IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 1.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 2.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_type TYPE i.
    DATA lv_x TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 1.
    lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_type TYPE i.
    DATA lv_x TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 2.
    lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1 OR lv_b = 2 OR lv_a = 1.
    lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1 OR lv_b = 2.
    lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1 AND lv_b = 2 OR lv_a = 1.
    lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF ( lv_a = 1 OR lv_b = 2 ) OR ( lv_a = 1 OR lv_b = 2 ).
    lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a BETWEEN 1 AND 5 AND lv_b = 2.
    lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_a TYPE i.
    CHECK lv_a = 1 OR lv_a = 1.
    lv_a = 2.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_a TYPE i.
    WHILE lv_a = 1 OR lv_a = 1.
    lv_a = 2.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_a TYPE i.
    IF ( lv_a = 1 AND lv_a = 1 ).
    lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF ( lv_a = 1 ).
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_a TYPE i.
    IF ( lv_a = 1 ) AND ( lv_a = 1 ).
    lv_a = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
