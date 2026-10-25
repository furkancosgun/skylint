CLASS zcl_test_pref_func_module DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_pref_func_module IMPLEMENTATION.
  METHOD test_001.
    DATA lv_guid TYPE string.
    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        ev_guid_32 = lv_guid.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_guid TYPE string.
    lv_guid = cl_system_uuid=>create_uuid_c32_static( ).
  ENDMETHOD.

  METHOD test_003.
    DATA lv_res TYPE i.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      IMPORTING
        ran_int = lv_res.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_name TYPE string.
    DATA lv_res TYPE i.
    CALL FUNCTION lv_name
      IMPORTING
        ran_int = lv_res.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_guid TYPE string.
    CALL FUNCTION 'GUID_CREATE' "#EC PREF_FUNC_MOD
      IMPORTING
        ev_guid_32 = lv_guid.
  ENDMETHOD.
ENDCLASS.
