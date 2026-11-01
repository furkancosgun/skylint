INTERFACE lif_other.
  METHODS do_other.
ENDINTERFACE.

INTERFACE lif_demo.
  DATA mo_service TYPE REF TO cl_abap_typedescr.
  DATA mo_other TYPE REF TO lif_other.
ENDINTERFACE.

INTERFACE lif_self.
  DATA mo_self TYPE REF TO lif_self.
ENDINTERFACE.
