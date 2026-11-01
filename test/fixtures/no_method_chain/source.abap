CLASS lcl_chain DEFINITION.
  PUBLIC SECTION.
    METHODS meth1 RETURNING VALUE(ro_self) TYPE REF TO lcl_chain.
    METHODS meth2 RETURNING VALUE(ro_self) TYPE REF TO lcl_chain.
    METHODS run.
ENDCLASS.

CLASS lcl_chain IMPLEMENTATION.
  METHOD meth1.
    ro_self = me.
  ENDMETHOD.
  METHOD meth2.
    ro_self = me.
  ENDMETHOD.
  METHOD run.
    DATA lo_c TYPE REF TO lcl_chain.
    lo_c = NEW #( ).
    lo_c->meth1( )->meth2( ).
    lo_c->meth1( ).
  ENDMETHOD.
ENDCLASS.
