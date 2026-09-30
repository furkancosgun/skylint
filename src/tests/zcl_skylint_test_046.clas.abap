CLASS zcl_skylint_test_046 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_struct,
        col1 TYPE i,
        col2 TYPE string,
      END OF ty_struct.

    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_046 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    DATA ls_src TYPE ty_struct.
    DATA ls_dst TYPE ty_struct.

    MOVE-CORRESPONDING ls_src TO ls_dst.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA ls_src TYPE ty_struct.
    DATA ls_dst TYPE ty_struct.

    MOVE-CORRESPONDING ls_src TO ls_dst. "#EC PREFER_CORRESPONDING
  ENDMETHOD.

  METHOD valid_code.
    DATA ls_src TYPE ty_struct.
    DATA ls_dst TYPE ty_struct.

    ls_dst = CORRESPONDING #( ls_src ).
  ENDMETHOD.

ENDCLASS.
