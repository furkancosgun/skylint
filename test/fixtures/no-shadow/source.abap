CLASS zcl_test_no_shadow_parent DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_inherited TYPE i.
ENDCLASS.

CLASS zcl_test_no_shadow_parent IMPLEMENTATION.
ENDCLASS.

CLASS zcl_test_no_shadow DEFINITION
  PUBLIC
  INHERITING FROM zcl_test_no_shadow_parent
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_public TYPE i.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.

  PROTECTED SECTION.
    DATA mv_protected TYPE i.

  PRIVATE SECTION.
    DATA mv_private TYPE i.
ENDCLASS.

CLASS zcl_test_no_shadow IMPLEMENTATION.
  METHOD test_001.
    DATA lv_plain TYPE i.
    lv_plain = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA mv_private TYPE i.
    mv_private = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA mv_public TYPE i.
    mv_public = 1.
  ENDMETHOD.

  METHOD test_004.
    DATA mv_protected TYPE i.
    mv_protected = 1.
  ENDMETHOD.

  METHOD test_005.
    DATA mv_inherited TYPE i.
    mv_inherited = 1.
  ENDMETHOD.

  METHOD test_006.
    DATA(mv_private) = 1.
    mv_private = mv_private + 1.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_result TYPE i.
    lv_result = me->mv_public.
    lv_result = lv_result + 1.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_public TYPE i.
    lv_public = mv_public.
    lv_public = lv_public + 1.
  ENDMETHOD.
ENDCLASS.
