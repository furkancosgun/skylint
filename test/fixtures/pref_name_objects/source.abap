CLASS lcl_good DEFINITION.
  PUBLIC SECTION.
    TYPES ty_valid_type TYPE i.
    TYPES ty_valid_str TYPE string.
    EVENTS state_changed.
    METHODS on_state_changed FOR EVENT state_changed OF lcl_good.
ENDCLASS.

CLASS lcl_good IMPLEMENTATION.
  METHOD on_state_changed.
  ENDMETHOD.
ENDCLASS.

CLASS bad_class DEFINITION.
  PUBLIC SECTION.
    EVENTS bad_event.
ENDCLASS.

CLASS bad_class IMPLEMENTATION.
ENDCLASS.

INTERFACE lif_good.
  METHODS execute.
ENDINTERFACE.

INTERFACE bad_intf.
  METHODS run.
ENDINTERFACE.

CLASS lcx_valid_error DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.

CLASS lcx_valid_error IMPLEMENTATION.
  METHOD constructor.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_my_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_success FOR TESTING.
    METHODS should_calculate FOR TESTING.
    METHODS verify_result FOR TESTING.
ENDCLASS.

CLASS ltcl_my_test IMPLEMENTATION.
  METHOD test_success.
  ENDMETHOD.
  METHOD should_calculate.
  ENDMETHOD.
  METHOD verify_result.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_bad_test_class DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_ok FOR TESTING.
ENDCLASS.

CLASS lcl_bad_test_class IMPLEMENTATION.
  METHOD test_ok.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_types_and_events DEFINITION.
  PUBLIC SECTION.
    TYPES invalid_type TYPE i.
    METHODS handle_event FOR EVENT state_changed OF lcl_good.
ENDCLASS.

CLASS lcl_types_and_events IMPLEMENTATION.
  METHOD handle_event.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_proc_types DEFINITION.
  PUBLIC SECTION.
    METHODS run_proc.
ENDCLASS.

CLASS lcl_proc_types IMPLEMENTATION.
  METHOD run_proc.
    TYPES ty_ok TYPE i.
    TYPES bad_local_type TYPE i.
    DEFINE _ok_macro.
    END-OF-DEFINITION.
    DEFINE bad_macro.
    END-OF-DEFINITION.
  ENDMETHOD.
ENDCLASS.
