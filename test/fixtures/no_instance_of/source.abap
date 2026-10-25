CLASS zcl_skylint_test_instance_of DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001.
    METHODS bad_002.
    METHODS good_001.
ENDCLASS.
CLASS zcl_skylint_test_instance_of IMPLEMENTATION.
  METHOD bad_001.
    IF io_obj IS INSTANCE OF cl_foo.
      do_something( ).
    ENDIF.
  ENDMETHOD.
  METHOD bad_002.
    CASE TYPE OF io_obj.
      WHEN TYPE cl_bar.
        do_other( ).
    ENDCASE.
  ENDMETHOD.
  METHOD good_001.
    io_obj->execute( ).
  ENDMETHOD.
ENDCLASS.
