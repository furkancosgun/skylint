INTERFACE lif_demo.
  METHODS do_work.
  ALIASES work FOR do_work.
ENDINTERFACE.

CLASS lcl_demo DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_demo.
    ALIASES run FOR lif_demo~do_work.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.
  METHOD lif_demo~do_work.
  ENDMETHOD.
ENDCLASS.
