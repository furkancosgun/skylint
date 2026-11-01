INTERFACE lif_base.
  METHODS do_work.
ENDINTERFACE.

INTERFACE lif_demo.
  INTERFACES lif_base.
  ALIASES work FOR lif_base~do_work.
ENDINTERFACE.

CLASS lcl_demo DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_demo.
    ALIASES run FOR lif_base~do_work.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.
  METHOD lif_base~do_work.
  ENDMETHOD.
ENDCLASS.
