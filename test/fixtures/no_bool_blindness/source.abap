CLASS lcl_bad DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001
      IMPORTING iv_active TYPE abap_bool.
    CLASS-METHODS bad_002
      IMPORTING iv_flag   TYPE abap_bool
                iv_name   TYPE string
      RETURNING VALUE(rv_ok) TYPE abap_bool.
ENDCLASS.

CLASS lcl_good DEFINITION.
  PUBLIC SECTION.
    METHODS good_001
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_ok) TYPE abap_bool.
    METHODS good_002
      IMPORTING iv_name TYPE string
      EXPORTING ev_active TYPE abap_bool.
ENDCLASS.

INTERFACE lif_good.
  METHODS good_003
    IMPORTING iv_name TYPE string.
ENDINTERFACE.
