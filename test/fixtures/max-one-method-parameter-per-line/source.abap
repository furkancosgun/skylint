CLASS lcl_bad DEFINITION.
  PUBLIC SECTION.
    METHODS apps_scope_token
      IMPORTING
        body TYPE string client_id TYPE string.
    CLASS-METHODS foo
      IMPORTING
        a TYPE i OPTIONAL VALUE(b) TYPE i DEFAULT 2.
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
