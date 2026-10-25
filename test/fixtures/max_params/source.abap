CLASS lcl_many_params DEFINITION.
  PUBLIC SECTION.
    METHODS run
      IMPORTING
        a TYPE i
        b TYPE i
        c TYPE i
        d TYPE i
        e TYPE i
        f TYPE i
        g TYPE i
        h TYPE i
        j TYPE i.
ENDCLASS.

CLASS lcl_clean DEFINITION.
  PUBLIC SECTION.
    METHODS run
      IMPORTING
        a TYPE i
        b TYPE i.
ENDCLASS.

CLASS lcl_many_two DEFINITION.
  PUBLIC SECTION.
    METHODS run
      IMPORTING
        p1 TYPE i
        p2 TYPE i
        p3 TYPE i
        p4 TYPE i
        p5 TYPE i
        p6 TYPE i
        p7 TYPE i
        p8 TYPE i
        p9 TYPE i.
ENDCLASS.

CLASS lcl_tidy DEFINITION.
  PUBLIC SECTION.
    METHODS run IMPORTING only_one TYPE i.
ENDCLASS.

CLASS lcl_bad_line DEFINITION.
  PUBLIC SECTION.
    METHODS apps_scope_token
      IMPORTING
        body TYPE string client_id TYPE string.
    CLASS-METHODS foo
      IMPORTING
        a TYPE i OPTIONAL VALUE(b) TYPE i DEFAULT 2.
ENDCLASS.

CLASS lcl_good_line DEFINITION.
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
