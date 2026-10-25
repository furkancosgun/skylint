CLASS zcl_skylint_test_returns DEFINITION.
  PUBLIC SECTION.
    METHODS bad_method.
    METHODS good_method.
ENDCLASS.
CLASS zcl_skylint_test_returns IMPLEMENTATION.
  METHOD bad_method.
    IF 1 = 2.
      RETURN.
    ENDIF.
    IF 2 = 3.
      RETURN.
    ENDIF.
    IF 3 = 4.
      RETURN.
    ENDIF.
    IF 4 = 5.
      RETURN.
    ENDIF.
    IF 5 = 6.
      RETURN.
    ENDIF.
    IF 6 = 7.
      RETURN.
    ENDIF.
    IF 7 = 8.
      RETURN.
    ENDIF.
  ENDMETHOD.
  METHOD good_method.
    IF 1 = 2.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
