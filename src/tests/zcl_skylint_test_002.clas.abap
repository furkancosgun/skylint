CLASS zcl_skylint_test_002 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS my_method.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS dynamic_calls.
ENDCLASS.


CLASS zcl_skylint_test_002 IMPLEMENTATION.
  METHOD my_method.
  ENDMETHOD.

  METHOD without_pseudo_comments.
    CALL METHOD my_method.
    CALL METHOD my_method( ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    CALL METHOD my_method. "#EC CALL_METHOD
  ENDMETHOD.

  METHOD dynamic_calls.
    DATA lv_meth TYPE string.
    DATA lv_clas TYPE string.
    DATA lt_ptab TYPE abap_parmbind_tab.
    DATA lo_obj  TYPE REF TO zcl_skylint_test_002.

    lv_meth = 'MY_METHOD'.
    lv_clas = 'ZCL_SKYLINT_TEST_002'.

    CALL METHOD (lv_meth).
    CALL METHOD lo_obj->(lv_meth).
    CALL METHOD (lv_clas)=>('MY_METHOD').
    CALL METHOD lo_obj->my_method PARAMETER-TABLE lt_ptab.
  ENDMETHOD.
ENDCLASS.
