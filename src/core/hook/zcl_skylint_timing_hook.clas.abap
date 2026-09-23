CLASS zcl_skylint_timing_hook DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_hook.

    METHODS get_start
      RETURNING VALUE(rv_start) TYPE timestampl.

    METHODS get_end
      RETURNING VALUE(rv_end) TYPE timestampl.

  PRIVATE SECTION.
    DATA mv_start TYPE timestampl.
    DATA mv_end   TYPE timestampl.
ENDCLASS.


CLASS zcl_skylint_timing_hook IMPLEMENTATION.
  METHOD zif_skylint_hook~verify_prerequisites.
  ENDMETHOD.

  METHOD zif_skylint_hook~set_attributes.
  ENDMETHOD.

  METHOD zif_skylint_hook~on_before_check.
    GET TIME STAMP FIELD mv_start.
  ENDMETHOD.

  METHOD zif_skylint_hook~on_after_check.
    GET TIME STAMP FIELD mv_end.
  ENDMETHOD.

  METHOD get_start.
    rv_start = mv_start.
  ENDMETHOD.

  METHOD get_end.
    rv_end = mv_end.
  ENDMETHOD.
ENDCLASS.
