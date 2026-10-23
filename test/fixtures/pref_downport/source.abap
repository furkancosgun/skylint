CLASS zcl_skylint_test_downport DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_downport IMPLEMENTATION.

  METHOD test_001.
    DATA new TYPE i.
    DATA lv_text TYPE string.
    DATA lt_data TYPE string_table.

    " Compliant: default attributes are all abap_false
    new = 1.
    new += 2.
    lt_data = VALUE string_table( ( |Line: { new }| ) ).
    lt_data = VALUE #( ( `Item` ) ).
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
