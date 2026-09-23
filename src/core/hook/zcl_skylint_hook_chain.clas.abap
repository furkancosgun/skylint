CLASS zcl_skylint_hook_chain DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_hooks TYPE STANDARD TABLE OF REF TO zif_skylint_hook WITH EMPTY KEY.

    METHODS register_hook
      IMPORTING io_hook TYPE REF TO zif_skylint_hook.

    METHODS register_many
      IMPORTING it_hooks TYPE ty_hooks.

    METHODS execute_before.

    METHODS execute_after.

    METHODS execute_set_attributes
      IMPORTING it_attributes TYPE if_ci_atc_check_meta_data=>ty_attributes
      RAISING   cx_static_check.

    METHODS execute_verify
      RETURNING VALUE(rt_findings) TYPE if_ci_atc_check=>ty_findings.

    METHODS clear.

    METHODS get_count
      RETURNING VALUE(rv_count) TYPE i.

    METHODS get_hooks
      RETURNING VALUE(rt_hooks) TYPE ty_hooks.

  PRIVATE SECTION.
    DATA mt_hooks TYPE ty_hooks.
ENDCLASS.


CLASS zcl_skylint_hook_chain IMPLEMENTATION.
  METHOD register_hook.
    INSERT io_hook INTO TABLE mt_hooks.
  ENDMETHOD.

  METHOD register_many.
    LOOP AT it_hooks ASSIGNING FIELD-SYMBOL(<ls_hook>).
      INSERT <ls_hook> INTO TABLE mt_hooks.
    ENDLOOP.
  ENDMETHOD.

  METHOD execute_before.
    LOOP AT mt_hooks ASSIGNING FIELD-SYMBOL(<ls_hook>).
      <ls_hook>->on_before_check( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD execute_after.
    LOOP AT mt_hooks ASSIGNING FIELD-SYMBOL(<ls_hook>).
      <ls_hook>->on_after_check( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD execute_set_attributes.
    LOOP AT mt_hooks ASSIGNING FIELD-SYMBOL(<ls_hook>).
      <ls_hook>->set_attributes( it_attributes ).
    ENDLOOP.
  ENDMETHOD.

  METHOD execute_verify.
    LOOP AT mt_hooks ASSIGNING FIELD-SYMBOL(<ls_hook>).
      DATA(lt_one) = <ls_hook>->verify_prerequisites( ).
      INSERT LINES OF lt_one INTO TABLE rt_findings.
    ENDLOOP.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_hooks.
  ENDMETHOD.

  METHOD get_count.
    rv_count = lines( mt_hooks ).
  ENDMETHOD.

  METHOD get_hooks.
    rt_hooks = mt_hooks.
  ENDMETHOD.
ENDCLASS.
