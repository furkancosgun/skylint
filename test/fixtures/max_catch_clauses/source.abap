CLASS zcl_skylint_test_max_catch DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_max_catch IMPLEMENTATION.
  METHOD test_001.
    TRY.
        cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_sy_zerodivide.
        CLEAR sy-subrc.
      CATCH cx_sy_conversion_overflow.
        CLEAR sy-subrc.
      CATCH cx_sy_arithmetic_overflow.
        CLEAR sy-subrc.
      CATCH cx_root.
        CLEAR sy-subrc.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    TRY.
        cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_sy_zerodivide.
        CLEAR sy-subrc.
      CATCH cx_root.
        CLEAR sy-subrc.
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    TRY.
        TRY.
            cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_sy_zerodivide.
            CLEAR sy-subrc.
          CATCH cx_root.
            CLEAR sy-subrc.
        ENDTRY.
      CATCH cx_sy_arithmetic_overflow.
        CLEAR sy-subrc.
      CATCH cx_root.
        CLEAR sy-subrc.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
