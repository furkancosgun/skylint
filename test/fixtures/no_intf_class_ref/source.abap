CLASS lcl_service DEFINITION.
  PUBLIC SECTION.
    METHODS run.
ENDCLASS.

CLASS lcl_service IMPLEMENTATION.
  METHOD run.
  ENDMETHOD.
ENDCLASS.

INTERFACE lif_other.
  METHODS do_other.
ENDINTERFACE.

INTERFACE lif_demo.
  DATA mo_service TYPE REF TO lcl_service.
  DATA mo_other TYPE REF TO lif_other.
ENDINTERFACE.
