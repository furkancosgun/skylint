CLASS lcl_state DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA gv_counter TYPE i.
    CLASS-DATA gv_flag TYPE abap_bool READ-ONLY.
    DATA mv_instance TYPE i.
    METHODS good_local.
    CLASS-METHODS bad_local.
  PRIVATE SECTION.
    CLASS-DATA gv_private TYPE string.
ENDCLASS.

CLASS lcl_state IMPLEMENTATION.
  METHOD bad_local.
    STATICS sv_count TYPE i.
    sv_count = sv_count + 1.
  ENDMETHOD.

  METHOD good_local.
    DATA lv_count TYPE i.
    lv_count = 1.
  ENDMETHOD.
ENDCLASS.
