CLASS zcl_skylint_test_pref_naming DEFINITION
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_pref_naming IMPLEMENTATION.
  METHOD test_001.
    DATA lv_value TYPE i.
    CONSTANTS lc_max TYPE i VALUE 100.
    STATICS sv_count TYPE i.
    FIELD-SYMBOLS <ls_item> TYPE any.
    DATA(lv_num) = 1.
    ASSIGN lv_num TO FIELD-SYMBOL(<lv_ptr>).
  ENDMETHOD.

  METHOD test_002.
    DATA bad_var TYPE i.
    CONSTANTS bad_const TYPE i VALUE 1.
    STATICS bad_static TYPE i.
    FIELD-SYMBOLS <bad_fs> TYPE any.
  ENDMETHOD.

  METHOD test_003.
    DATA(bad_inline) = 1.
    ASSIGN bad_inline TO FIELD-SYMBOL(<bad_inline_fs>).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_good DEFINITION.
  PUBLIC SECTION.
    DATA mv_data TYPE i.
    METHODS do_work
      IMPORTING iv_param TYPE i
      RETURNING VALUE(rv_res) TYPE i.
    EVENTS state_changed.
    METHODS on_state_changed FOR EVENT state_changed OF lcl_good.
ENDCLASS.

CLASS lcl_good IMPLEMENTATION.
  METHOD do_work.
    rv_res = iv_param.
  ENDMETHOD.
  METHOD on_state_changed.
  ENDMETHOD.
ENDCLASS.

CLASS bad_class DEFINITION.
  PUBLIC SECTION.
    DATA bad_attr TYPE i.
    METHODS bad_meth
      IMPORTING bad_param TYPE i.
    EVENTS bad_event.
ENDCLASS.

CLASS bad_class IMPLEMENTATION.
  METHOD bad_meth.
  ENDMETHOD.
ENDCLASS.

INTERFACE lif_good.
  DATA mv_flag TYPE abap_bool.
  METHODS execute.
ENDINTERFACE.

INTERFACE bad_intf.
  METHODS run.
ENDINTERFACE.

CLASS bad_global DEFINITION PUBLIC.
ENDCLASS.

CLASS bad_global IMPLEMENTATION.
ENDCLASS.

INTERFACE bad_gintf PUBLIC.
ENDINTERFACE.
