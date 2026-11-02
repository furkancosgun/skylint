CLASS zcl_skylint_test_pref_clamp DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_pref_clamp IMPLEMENTATION.
  METHOD test_001.
    DATA lv TYPE i VALUE 5.
    DATA lo TYPE i VALUE 1.
    DATA hi TYPE i VALUE 10.
    IF lv < lo.
      lv = lo.
    ELSEIF lv > hi.
      lv = hi.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv TYPE i VALUE 5.
    DATA lo TYPE i VALUE 1.
    DATA hi TYPE i VALUE 10.
    IF lv < lo.
      lv = lo.
    ENDIF.
    IF lv > hi.
      lv = hi.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv TYPE i VALUE 5.
    DATA lo TYPE i VALUE 1.
    DATA hi TYPE i VALUE 10.
    lv = nmin( val1 = hi
               val2 = nmax( val1 = lo
                            val2 = lv ) ).
  ENDMETHOD.

  METHOD test_004.
    DATA lv TYPE i VALUE 5.
    DATA lo TYPE i VALUE 1.
    DATA hi TYPE i VALUE 10.
    IF lv < lo.
      lv = lo.
    ELSEIF lv > hi.
      lv = 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
