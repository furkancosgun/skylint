CLASS zcl_test_prefer_new_operator DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_val TYPE i OPTIONAL
        iv_txt TYPE string OPTIONAL
        io_sub TYPE REF TO zcl_test_prefer_new_operator OPTIONAL
      EXCEPTIONS
        failed.
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
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
ENDCLASS.

CLASS zcl_test_prefer_new_operator IMPLEMENTATION.
  METHOD constructor.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    DATA lv_cls TYPE string.
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_other TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_other.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    lo_obj = NEW #( ).
  ENDMETHOD.

  METHOD test_005.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_006.
    RAISE EXCEPTION NEW cx_sy_zerodivide( ).
  ENDMETHOD.

  METHOD test_007.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj TYPE zcl_test_prefer_new_operator EXPORTING iv_val = 10.
  ENDMETHOD.

  METHOD test_008.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj EXPORTING iv_val = 1 iv_txt = 'A'.
  ENDMETHOD.

  METHOD test_009.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj EXCEPTIONS failed = 1.
  ENDMETHOD.

  METHOD test_010.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj EXPORTING io_sub = NEW zcl_test_prefer_new_operator( ).
  ENDMETHOD.

  METHOD test_011.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    DATA lt_ptab TYPE abap_parmbind_tab.
    DATA lv_cls TYPE string VALUE 'ZCL_TEST_PREFER_NEW_OPERATOR'.
    CREATE OBJECT lo_obj TYPE (lv_cls) PARAMETER-TABLE lt_ptab.
  ENDMETHOD.

  METHOD test_012.
    RAISE EXCEPTION TYPE cx_sy_zerodivide EXPORTING textid = cx_sy_zerodivide=>cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_013.
    RAISE EXCEPTION TYPE zcx_custom MESSAGE e001(sy).
  ENDMETHOD.

  METHOD test_014.
    RAISE RESUMABLE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_015.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    lo_obj = NEW zcl_test_prefer_new_operator( ).
  ENDMETHOD.

  METHOD test_016.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj. "#EC PREF_NEW_OPERATOR
    RAISE EXCEPTION TYPE cx_sy_zerodivide. "#EC PREF_RAISE_EXC_NEW
  ENDMETHOD.

  METHOD test_017.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.
ENDCLASS.
