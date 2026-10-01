CLASS zcl_skylint_test_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_expected_finding,
        line TYPE i,
        code TYPE if_ci_atc_check=>ty_finding_code,
      END OF ty_expected_finding,
      ty_expected_findings TYPE STANDARD TABLE OF ty_expected_finding WITH EMPTY KEY.

    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZSKYLINT_TEST'.

    CLASS-METHODS run_check
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string OPTIONAL
                it_source           TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_findings)  TYPE if_ci_atc_check=>ty_findings
      RAISING cx_static_check.

    CLASS-METHODS assert_findings
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string OPTIONAL
                it_source           TYPE string_table OPTIONAL
                it_expected         TYPE ty_expected_findings
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RAISING cx_static_check.

    CLASS-METHODS assert_no_findings
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string OPTIONAL
                it_source           TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RAISING cx_static_check.

    CLASS-METHODS assert_fixed
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_fixed_source     TYPE string OPTIONAL
                it_fixed_source     TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RAISING cx_static_check.

    CLASS-METHODS assert_quickfix
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_bad_source       TYPE string OPTIONAL
                it_bad_source       TYPE string_table OPTIONAL
                it_expected_fixed   TYPE string_table OPTIONAL
                iv_quickfix_code    TYPE zcl_skylint_check_base=>ty_quickfix_code OPTIONAL
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RAISING cx_static_check.

  PRIVATE SECTION.
    CLASS-METHODS canonicalize
      IMPORTING it_source       TYPE string_table
      RETURNING VALUE(rv_text)  TYPE string.

ENDCLASS.


CLASS zcl_skylint_test_util IMPLEMENTATION.
  METHOD run_check.
    DATA lv_source TYPE string.

    lv_source = lcl_runner=>join_source( iv_source = iv_source
                                         it_source = it_source ).
    rt_findings = lcl_runner=>execute( io_check            = io_check
                                       iv_source           = lv_source
                                       iv_class_definition = iv_class_definition ).
  ENDMETHOD.

  METHOD assert_findings.
    DATA lt_actual TYPE if_ci_atc_check=>ty_findings.
    DATA ls_exp    TYPE ty_expected_finding.
    DATA ls_act    TYPE if_ci_atc_check=>ty_finding.
    DATA lv_found  TYPE abap_bool.
    DATA lv_msg    TYPE string.

    lt_actual = run_check( io_check            = io_check
                           iv_source           = iv_source
                           it_source           = it_source
                           iv_class_definition = iv_class_definition ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actual )
                                       exp = lines( it_expected )
                                       msg = 'ATC findings count does not match expected' ).

    LOOP AT it_expected INTO ls_exp.
      lv_found = abap_false.
      LOOP AT lt_actual INTO ls_act WHERE code = ls_exp-code.
        IF ls_act-location-position-line = ls_exp-line.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      lv_msg = |Expected finding { ls_exp-code } at line { ls_exp-line } not found|.
      cl_abap_unit_assert=>assert_true( act = lv_found
                                       msg = lv_msg ).
    ENDLOOP.

    LOOP AT lt_actual INTO ls_act.
      lv_msg = |Unexpected finding { ls_act-code } at line { ls_act-location-position-line }|.
      cl_abap_unit_assert=>assert_true( act = xsdbool( line_exists( it_expected[ code = ls_act-code ] ) )
                                       msg = lv_msg ).
    ENDLOOP.
  ENDMETHOD.

  METHOD assert_no_findings.
    DATA lt_actual TYPE if_ci_atc_check=>ty_findings.

    lt_actual = run_check( io_check            = io_check
                           iv_source           = iv_source
                           it_source           = it_source
                           iv_class_definition = iv_class_definition ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actual )
                                       exp = 0
                                       msg = 'Expected no ATC findings but some were reported' ).
  ENDMETHOD.

  METHOD assert_fixed.
    assert_no_findings( io_check            = io_check
                        iv_source           = iv_fixed_source
                        it_source             = it_fixed_source
                        iv_class_definition = iv_class_definition ).
  ENDMETHOD.

  METHOD assert_quickfix.
    DATA lt_findings TYPE if_ci_atc_check=>ty_findings.
    DATA lt_recorded TYPE zcl_skylint_check_base=>ty_recorded_quickfixes.
    DATA ls_recorded TYPE zcl_skylint_check_base=>ty_recorded_quickfix.
    DATA lv_bad_str  TYPE string.
    DATA lt_bad      TYPE string_table.
    DATA lt_fixed    TYPE string_table.
    DATA ls_proc     TYPE if_ci_atc_source_code_provider=>ty_procedure.
    DATA lv_actual   TYPE string.
    DATA lv_expected TYPE string.

    lv_bad_str = lcl_runner=>join_source( iv_source = iv_bad_source
                                          it_source = it_bad_source ).
    lt_findings = run_check( io_check            = io_check
                             iv_source           = lv_bad_str
                             iv_class_definition = iv_class_definition ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_findings )
                                       exp = 1
                                       msg = 'Quickfix test needs exactly one finding on bad source' ).

    lt_recorded = io_check->get_recorded_quickfixes( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_recorded )
                                       exp = 1
                                       msg = 'Check recorded no quickfix for this finding' ).
    READ TABLE lt_recorded INTO ls_recorded INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = sy-subrc
                                       exp = 0
                                       msg = 'Quickfix record missing unexpectedly' ).

    IF iv_quickfix_code IS NOT INITIAL.
      cl_abap_unit_assert=>assert_equals( act = ls_recorded-quickfix_code
                                         exp = iv_quickfix_code
                                         msg = 'Unexpected quickfix code recorded' ).
    ENDIF.

    lv_bad_str = lcl_runner=>wrap_source( iv_source           = lv_bad_str
                                                     iv_class_definition = iv_class_definition ).
    SPLIT lv_bad_str AT cl_abap_char_utilities=>newline INTO TABLE lt_bad.
    ls_proc = lcl_runner=>build_procedure( iv_source           = lv_bad_str
                                           iv_class_definition = iv_class_definition ).
    lt_fixed = lcl_applier=>apply( it_lines     = lt_bad
                                   is_procedure = ls_proc
                                   is_recorded  = ls_recorded ).

    assert_no_findings( io_check            = io_check
                        it_source           = lt_fixed
                        iv_class_definition = iv_class_definition ).

    IF it_expected_fixed IS NOT INITIAL.
      lv_actual = canonicalize( lt_fixed ).
      lv_expected = canonicalize( it_expected_fixed ).
      cl_abap_unit_assert=>assert_equals( act = lv_actual
                                         exp = lv_expected
                                         msg = 'Quickfix result text does not match expected fixed source' ).
    ENDIF.
  ENDMETHOD.

  METHOD canonicalize.
    DATA lv_joined TYPE string.
    DATA ls_proc   TYPE if_ci_atc_source_code_provider=>ty_procedure.
    DATA lv_line   TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_text.
    lv_joined = lcl_runner=>join_source( it_source = it_source ).
    ls_proc = lcl_runner=>build_procedure( lv_joined ).
    LOOP AT ls_proc-statements ASSIGNING <ls_stmt>.
      CLEAR lv_line.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        IF lv_line IS INITIAL.
          lv_line = <ls_tok>-lexeme.
        ELSE.
          lv_line = lv_line && ` ` && <ls_tok>-lexeme.
        ENDIF.
      ENDLOOP.
      IF rv_text IS INITIAL.
        rv_text = lv_line.
      ELSE.
        rv_text = rv_text && cl_abap_char_utilities=>newline && lv_line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
