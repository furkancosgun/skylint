CLASS zcl_skylint_test_runner DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS run
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                it_source   TYPE string_table
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.

  PRIVATE SECTION.
    CLASS-METHODS run_all
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                it_source   TYPE string_table
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.

    CLASS-METHODS extract_snippet
      IMPORTING it_source       TYPE string_table
                iv_method       TYPE string
      EXPORTING et_snippet      TYPE string_table
                ev_is_class_def TYPE abap_bool
                ev_abs_offset   TYPE i.

    CLASS-METHODS extract_method
      IMPORTING it_source  TYPE string_table
                iv_method  TYPE string
      EXPORTING et_snippet TYPE string_table
                ev_found   TYPE abap_bool.

    CLASS-METHODS extract_class_def
      IMPORTING it_source           TYPE string_table
                iv_method           TYPE string
      RETURNING VALUE(rt_snippet)   TYPE string_table.

    CLASS-METHODS run_check
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                it_snippet          TYPE string_table
                it_full_source      TYPE string_table
                iv_class_definition TYPE abap_bool DEFAULT abap_false
                iv_abs_offset       TYPE i DEFAULT 0
                iv_object_name      TYPE string OPTIONAL
      RETURNING VALUE(rt_findings)  TYPE zif_skylint_types=>ty_findings
      RAISING   cx_static_check.

ENDCLASS.


CLASS zcl_skylint_test_runner IMPLEMENTATION.
  METHOD run.
    run_all( io_check    = io_check
             it_source   = it_source
             it_expected = it_expected ).
  ENDMETHOD.

  METHOD run_all.
    DATA lt_snippet  TYPE string_table.
    DATA lv_is_def   TYPE abap_bool.
    DATA lv_offset   TYPE i.
    DATA lt_findings TYPE zif_skylint_types=>ty_findings.
    DATA ls_exp      TYPE zif_skylint_types=>ty_test_expected.
    DATA lv_found    TYPE abap_bool.
    FIELD-SYMBOLS <ls_finding> TYPE zif_skylint_types=>ty_finding.

    LOOP AT it_expected INTO ls_exp.
      extract_snippet( EXPORTING it_source       = it_source
                                 iv_method       = ls_exp-method
                       IMPORTING et_snippet      = lt_snippet
                                 ev_is_class_def = lv_is_def
                                 ev_abs_offset   = lv_offset ).

      IF lt_snippet IS INITIAL.
        CONTINUE.
      ENDIF.

      lt_findings = run_check( io_check            = io_check
                               it_snippet          = lt_snippet
                               it_full_source      = it_source
                               iv_class_definition = lv_is_def
                               iv_abs_offset       = lv_offset ).

      IF ls_exp-code IS INITIAL.
        cl_abap_unit_assert=>assert_equals( exp = 0
                                           act = lines( lt_findings )
                                           msg = |Method { ls_exp-method } expected 0 findings| ).
      ELSE.
        lv_found = abap_false.
        LOOP AT lt_findings ASSIGNING <ls_finding> WHERE code = ls_exp-code.
          IF <ls_finding>-position-line <> ls_exp-line.
            CONTINUE.
          ENDIF.
          IF <ls_finding>-position-column <> ls_exp-column.
            CONTINUE.
          ENDIF.
          lv_found = abap_true.
          EXIT.
        ENDLOOP.
        cl_abap_unit_assert=>assert_true(
            act = lv_found
            msg = |{ ls_exp-method }: expected { ls_exp-code } at { ls_exp-line }:{ ls_exp-column }| ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_snippet.
    DATA lt_method TYPE string_table.
    DATA lv_found  TYPE abap_bool.
    DATA lv_line   TYPE string.
    DATA lv_inner  TYPE string.
    DATA lv_idx    TYPE i.

    CLEAR: et_snippet, ev_is_class_def, ev_abs_offset.

    extract_method( EXPORTING it_source  = it_source
                              iv_method  = iv_method
                    IMPORTING et_snippet = lt_method
                              ev_found   = lv_found ).

    IF lv_found = abap_true.
      CLEAR lv_inner.
      LOOP AT lt_method INTO lv_line.
        lv_idx = sy-tabix.
        IF lv_idx = 1 OR lv_idx = lines( lt_method ).
          CONTINUE.
        ENDIF.
        IF lv_inner IS INITIAL.
          lv_inner = lv_line.
        ELSE.
          lv_inner = lv_inner && cl_abap_char_utilities=>newline && lv_line.
        ENDIF.
      ENDLOOP.
      lv_inner = condense( to_upper( lv_inner ) ).
      IF lv_inner IS INITIAL OR lv_inner = 'RETURN.'.
        et_snippet = extract_class_def( it_source = it_source
                                        iv_method = iv_method ).
        ev_is_class_def = abap_true.
        RETURN.
      ENDIF.
      et_snippet = lt_method.
      ev_is_class_def = abap_false.
      LOOP AT it_source INTO lv_line.
        IF to_upper( condense( lv_line ) ) = to_upper( condense( lt_method[ 1 ] ) ).
          ev_abs_offset = sy-tabix - 1.
          EXIT.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    et_snippet = extract_class_def( it_source = it_source
                                              iv_method = iv_method ).
    ev_is_class_def = abap_true.
  ENDMETHOD.

  METHOD extract_method.
    DATA lv_line  TYPE string.
    DATA lv_upper TYPE string.
    DATA lv_want  TYPE string.
    DATA lv_in    TYPE abap_bool.

    CLEAR: et_snippet, ev_found.
    lv_want = to_upper( condense( iv_method ) ).
    IF lv_want IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_source INTO lv_line.
      lv_upper = to_upper( condense( lv_line ) ).
      IF lv_in = abap_false.
        IF lv_upper = |METHOD { lv_want }.|.
          lv_in = abap_true.
          APPEND lv_line TO et_snippet.
        ENDIF.
      ELSE.
        APPEND lv_line TO et_snippet.
        IF lv_upper = 'ENDMETHOD.'.
          ev_found = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF ev_found = abap_false.
      CLEAR et_snippet.
    ENDIF.
  ENDMETHOD.

  METHOD extract_class_def.
    DATA lt_blocks TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.
    DATA lt_cur    TYPE string_table.
    DATA lv_line   TYPE string.
    DATA lv_upper  TYPE string.
    DATA lv_in     TYPE abap_bool.
    DATA lv_num    TYPE i.
    DATA lv_off    TYPE i.
    DATA lv_mth    TYPE string.
    DATA lv_idx    TYPE i.

    CLEAR rt_snippet.
    LOOP AT it_source INTO lv_line.
      lv_upper = to_upper( lv_line ).
      IF lv_in = abap_false.
        IF ( lv_upper CS 'CLASS ' AND lv_upper CS 'DEFINITION' ) OR lv_upper CS 'INTERFACE '.
          lv_in = abap_true.
          CLEAR lt_cur.
          APPEND lv_line TO lt_cur.
        ENDIF.
      ELSE.
        APPEND lv_line TO lt_cur.
        IF condense( lv_upper ) = 'ENDCLASS.' OR condense( lv_upper ) = 'ENDINTERFACE.'.
          APPEND lt_cur TO lt_blocks.
          CLEAR: lt_cur, lv_in.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lines( lt_blocks ) = 0.
      RETURN.
    ENDIF.

    lv_mth = to_upper( iv_method ).
    lv_off = strlen( lv_mth ) - 1.
    IF lv_off >= 0 AND lv_mth+lv_off(1) CO '0123456789'.
      FIND REGEX '(\d+)$' IN lv_mth SUBMATCHES lv_line.
      IF sy-subrc = 0.
        lv_num = lv_line.
      ENDIF.
    ENDIF.

    IF lv_num > 0 AND lv_num MOD 2 = 0 AND lines( lt_blocks ) > 1.
      lv_idx = 2.
    ELSE.
      lv_idx = 1.
    ENDIF.
    READ TABLE lt_blocks INTO rt_snippet INDEX lv_idx.
    IF sy-subrc <> 0.
      CLEAR rt_snippet.
    ENDIF.
  ENDMETHOD.

  METHOD run_check.
    DATA lv_snippet TYPE string.
    DATA lv_full    TYPE string.

    lv_snippet = lcl_runner=>join_source( it_source = it_snippet ).
    lv_full = lcl_runner=>join_source( it_source = it_full_source ).
    rt_findings = lcl_runner=>execute( io_check            = io_check
                                       iv_source           = lv_snippet
                                       iv_full_source      = lv_full
                                       iv_class_definition = iv_class_definition
                                       iv_abs_offset       = iv_abs_offset
                                       iv_object_name      = iv_object_name ).
  ENDMETHOD.
ENDCLASS.
