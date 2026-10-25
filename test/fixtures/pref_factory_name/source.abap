CLASS lcl_service DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS build RETURNING VALUE(ro_obj) TYPE REF TO lcl_service.
    CLASS-METHODS create_instance RETURNING VALUE(ro_obj) TYPE REF TO lcl_service.
    CLASS-METHODS do_other RETURNING VALUE(rv_res) TYPE i.
ENDCLASS.
