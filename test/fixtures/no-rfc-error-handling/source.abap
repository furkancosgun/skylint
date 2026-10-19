CLASS zcl_test_no_rfc_err DEFINITION
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
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_test_no_rfc_err IMPLEMENTATION.
  METHOD test_001.
    CALL FUNCTION 'Z_RFC'
      DESTINATION 'ABC'.
  ENDMETHOD.

  METHOD test_002.
    CALL FUNCTION 'Z_RFC'
      DESTINATION 'ABC'
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_msg
        communication_failure = 2 MESSAGE lv_msg2
        OTHERS                = 3.
  ENDMETHOD.

  METHOD test_003.
    CALL FUNCTION 'Z_RFC'
      DESTINATION 'ABC'
      STARTING NEW TASK
      IN GROUP lv_group
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_msg
        communication_failure = 2 MESSAGE lv_msg2
        OTHERS                = 3.
  ENDMETHOD.

  METHOD test_004.
    CALL FUNCTION 'Z_RFC'
      DESTINATION 'ABC'
      STARTING NEW TASK
      IN GROUP lv_group
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_msg
        communication_failure = 2 MESSAGE lv_msg2.
  ENDMETHOD.

  METHOD test_005.
    WRITE 1.
  ENDMETHOD.
  METHOD test_006.
    CALL FUNCTION 'Z_RFC'
      STARTING NEW TASK
      IN GROUP lv_group
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_msg
        communication_failure = 2 MESSAGE lv_msg2
        resource_failure      = 3 MESSAGE lv_msg3
        OTHERS                = 4.
  ENDMETHOD.

  METHOD test_007.
    CALL FUNCTION 'Z_RFC'
      DESTINATION 'ABC'
      EXCEPTIONS
        OTHERS = 1.
  ENDMETHOD.

  METHOD test_008.
    CALL FUNCTION 'Z_RFC'
      DESTINATION 'ABC'
      EXCEPTIONS
        communication_failure = 2 MESSAGE lv_msg2
        OTHERS                = 3.
  ENDMETHOD.
ENDCLASS.
