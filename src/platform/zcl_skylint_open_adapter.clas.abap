CLASS zcl_skylint_open_adapter DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config OPTIONAL.

    METHODS lint ABSTRACT
      IMPORTING is_code_block      TYPE zif_skylint_types=>ty_code_block
      RETURNING VALUE(rt_findings) TYPE zif_skylint_types=>ty_findings.

  PROTECTED SECTION.
    DATA ms_config TYPE zif_skylint_types=>ty_config.
ENDCLASS.


CLASS zcl_skylint_open_adapter IMPLEMENTATION.
  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.
ENDCLASS.