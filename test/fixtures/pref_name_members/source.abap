CLASS lcl_good DEFINITION.
  PUBLIC SECTION.
    DATA mv_data TYPE i.
    METHODS do_work
      IMPORTING iv_param TYPE i
      RETURNING VALUE(rv_res) TYPE i.
ENDCLASS.

CLASS lcl_good IMPLEMENTATION.
  METHOD do_work.
    rv_res = iv_param.
  ENDMETHOD.
ENDCLASS.

CLASS bad_class DEFINITION.
  PUBLIC SECTION.
    METHODS bad_meth
      IMPORTING bad_param TYPE i.
ENDCLASS.

CLASS bad_class IMPLEMENTATION.
  METHOD bad_meth.
  ENDMETHOD.
ENDCLASS.

INTERFACE lif_good.
  METHODS execute.
ENDINTERFACE.

CLASS lcl_bad_attrs DEFINITION.
  PUBLIC SECTION.
    DATA bad_attr TYPE i.
    DATA bad_attr_suppressed TYPE i. "#EC PREF_NAME_MEMBERS
ENDCLASS.

CLASS lcl_bad_attrs IMPLEMENTATION.
ENDCLASS.

CLASS lcl_param_edge DEFINITION.
  PUBLIC SECTION.
    METHODS compliant_method
      IMPORTING iv_in TYPE i
      EXPORTING ev_out TYPE i
      CHANGING cv_chg TYPE i
      RETURNING VALUE(rv_res) TYPE i.
    METHODS bad_exporting
      EXPORTING bad_out TYPE i.
    METHODS bad_changing
      CHANGING bad_chg TYPE i.
    METHODS bad_returning
      RETURNING VALUE(bad_res) TYPE i.
    METHODS test_reference
      CHANGING REFERENCE(cv_valid) TYPE i
               REFERENCE(bad_ref) TYPE i.
    METHODS test_paren_spaces
      EXPORTING VALUE(ev_spaced) TYPE i
                VALUE(bad_spaced) TYPE i.
ENDCLASS.

CLASS lcl_param_edge IMPLEMENTATION.
  METHOD compliant_method.
    rv_res = iv_in.
    ev_out = 1.
    cv_chg = 2.
  ENDMETHOD.
  METHOD bad_exporting.
    bad_out = 1.
  ENDMETHOD.
  METHOD bad_changing.
    bad_chg = 1.
  ENDMETHOD.
  METHOD bad_returning.
    bad_res = 1.
  ENDMETHOD.
  METHOD test_reference.
    cv_valid = 1.
    bad_ref = 2.
  ENDMETHOD.
  METHOD test_paren_spaces.
    ev_spaced = 1.
    bad_spaced = 2.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_events_and_tests DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    EVENTS state_changed.
    METHODS on_state_changed FOR EVENT state_changed OF lcl_events_and_tests
      IMPORTING sender.
    METHODS test_feature FOR TESTING.
ENDCLASS.

CLASS lcl_events_and_tests IMPLEMENTATION.
  METHOD on_state_changed.
  ENDMETHOD.
  METHOD test_feature.
  ENDMETHOD.
ENDCLASS.

CLASS lcx_custom_error DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    DATA error_code TYPE i.
    METHODS constructor
      IMPORTING
        custom_msg TYPE string OPTIONAL.
ENDCLASS.

CLASS lcx_custom_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_statics DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA gv_valid TYPE i.
    CLASS-DATA invalid_stat TYPE i.
    DATA: BEGIN OF ms_valid,
            field TYPE i,
          END OF ms_valid.
    DATA: BEGIN OF invalid_struct,
            field TYPE i,
          END OF invalid_struct.
ENDCLASS.

CLASS lcl_statics IMPLEMENTATION.
ENDCLASS.
