CLASS zcl_test_no_magic_numbers DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_test_no_magic_numbers IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i.
    lv_val = 42.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_val TYPE i.
    IF lv_val > 100.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    CONSTANTS c_limit TYPE i VALUE 10.
    DATA lv_val TYPE i.
    lv_val = c_limit.
  ENDMETHOD.

  METHOD test_005.
    language_sap1_to_sap2(
      EXPORTING
        im_lang_sap1  = iv_spras
      RECEIVING
        re_lang_sap2  = rv_spras
      EXCEPTIONS
        no_assignment = 1
        OTHERS        = 2 ).
  ENDMETHOD.
ENDCLASS.

