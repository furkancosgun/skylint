CLASS zcl_skylint_test_downport DEFINITION
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_downport IMPLEMENTATION.

  METHOD test_001.
    DATA lv_text TYPE string.

    " Compliant: default attributes are all abap_false
    lv_text = VALUE #( ).
  ENDMETHOD.

  METHOD test_002.
    DATA lv_num TYPE i.

    " Compliant: classic ABAP 7.02 compliant
    lv_num = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.

    " Suppressed via pseudo comment
    lv_text = VALUE #( ). "#EC DOWNPORT_COMPAT
  ENDMETHOD.

ENDCLASS.
