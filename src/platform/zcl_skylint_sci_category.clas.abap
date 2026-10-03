CLASS zcl_skylint_sci_category DEFINITION
  PUBLIC
  INHERITING FROM cl_ci_category_root FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_skylint_sci_category IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    description = 'SkyLint'.
    category    = 'CL_CI_CATEGORY_TOP'.
    position    = '0001'.
  ENDMETHOD.
ENDCLASS.
