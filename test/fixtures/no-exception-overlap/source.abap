CLASS zcl_test_no_exc_overlap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_test_no_exc_overlap IMPLEMENTATION.
  METHOD test_001.
    CALL FUNCTION 'SOMETHING'
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_message
        communication_failure = 1 MESSAGE lv_message
        OTHERS                = 1.
  ENDMETHOD.

  METHOD test_002.
    CALL FUNCTION 'SOMETHING'
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_message
        communication_failure = 2 MESSAGE lv_message
        OTHERS                = 3.
  ENDMETHOD.

  METHOD test_003.
    WRITE 1.
  ENDMETHOD.

  METHOD test_004.
    CALL FUNCTION 'SOMETHING'
      EXCEPTIONS
        first  = 1
        second = 2
        OTHERS = 1.
  ENDMETHOD.

  METHOD test_005.
    CALL FUNCTION 'SOMETHING'
      EXCEPTIONS
        first  = 1
        second = 2
        OTHERS = 3.
  ENDMETHOD.

  METHOD test_006.
    WRITE 1.
  ENDMETHOD.
ENDCLASS.
