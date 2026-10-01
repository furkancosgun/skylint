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
ENDCLASS.
