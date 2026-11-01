CLASS lcl_demo DEFINITION.
  PUBLIC SECTION.
    METHODS run IMPORTING iv_param TYPE any.
    METHODS run_cseq IMPORTING iv_text TYPE csequence.
    METHODS good IMPORTING iv_param TYPE i.
    METHODS test_001.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.
  METHOD run.
  ENDMETHOD.
  METHOD run_cseq.
  ENDMETHOD.
  METHOD good.
  ENDMETHOD.
  METHOD test_001.
    FIELD-SYMBOLS <fs_untyped>.
    FIELD-SYMBOLS <fs_clike> TYPE clike.
    FIELD-SYMBOLS <fs_typed> TYPE i.
  ENDMETHOD.
ENDCLASS.
