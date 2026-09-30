CLASS zcl_skylint_test_067 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_067 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    FIELD-SYMBOLS <fs_generic> TYPE any.
    FIELD-SYMBOLS <fs_data> TYPE data.
    FIELD-SYMBOLS <fs_clike> TYPE clike.
    FIELD-SYMBOLS <fs_table> TYPE any table.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    FIELD-SYMBOLS <fs_generic> TYPE any.       "#EC GENERIC_FS
    FIELD-SYMBOLS <fs_data> TYPE data.         "#EC GENERIC_FS
    FIELD-SYMBOLS <fs_clike> TYPE clike.       "#EC GENERIC_FS
    FIELD-SYMBOLS <fs_table> TYPE any table.   "#EC GENERIC_FS
  ENDMETHOD.

  METHOD valid_code.
    FIELD-SYMBOLS <fs_str> TYPE string.
    FIELD-SYMBOLS <fs_int> TYPE i.
    FIELD-SYMBOLS <fs_tab> TYPE string_table.
  ENDMETHOD.
ENDCLASS.
