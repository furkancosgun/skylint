CLASS lcl_bad DEFINITION.
  PUBLIC SECTION.
    METHODS apps_scope_token
      IMPORTING
        body TYPE string client_id TYPE string.
    CLASS-METHODS foo
      IMPORTING
        a TYPE i OPTIONAL VALUE(b) TYPE i DEFAULT 2.
ENDCLASS.
CLASS lcl_bad IMPLEMENTATION.
  METHOD apps_scope_token.
    RETURN.
  ENDMETHOD.
  METHOD foo.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_good DEFINITION.
  PUBLIC SECTION.
    METHODS apps_scope_token
      IMPORTING
        body TYPE string
        client_id TYPE string.
    CLASS-METHODS foo
      IMPORTING
        a TYPE i OPTIONAL
        VALUE(b) TYPE i DEFAULT 2.
ENDCLASS.
CLASS lcl_good IMPLEMENTATION.
  METHOD apps_scope_token.
    RETURN.
  ENDMETHOD.
  METHOD foo.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_skylint_test_param_ln DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_param_ln IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.
