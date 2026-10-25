CLASS zcl_skylint_test_instance_of DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001
      IMPORTING
        io_obj TYPE REF TO object.
    METHODS bad_002
      IMPORTING
        io_obj TYPE REF TO object.
    METHODS good_001
      IMPORTING
        io_obj TYPE REF TO object.
    METHODS do_something.
    METHODS do_other.
ENDCLASS.
CLASS zcl_skylint_test_instance_of IMPLEMENTATION.
  METHOD bad_001.
    IF io_obj IS INSTANCE OF zcl_skylint_test_instance_of.
      do_something( ).
    ENDIF.
  ENDMETHOD.
  METHOD bad_002.
    CASE TYPE OF io_obj.
      WHEN TYPE zcl_skylint_test_instance_of.
        do_other( ).
    ENDCASE.
  ENDMETHOD.
  METHOD good_001.
    do_something( ).
  ENDMETHOD.
  METHOD do_something.
  ENDMETHOD.
  METHOD do_other.
  ENDMETHOD.
ENDCLASS.
