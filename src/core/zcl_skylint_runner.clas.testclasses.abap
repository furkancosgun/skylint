CLASS ltcl_runner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_create_default FOR TESTING RAISING cx_static_check.
    METHODS test_run_procedure  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_runner IMPLEMENTATION.

  METHOD test_create_default.
    DATA lo_runner TYPE REF TO zcl_skylint_runner.
    DATA lt_checks TYPE zcl_skylint_runner=>ty_check_list.

    lo_runner = zcl_skylint_runner=>create_default( ).
    cl_abap_unit_assert=>assert_bound( act = lo_runner
                                       msg = 'Runner should be instantiated' ).

    lt_checks = lo_runner->get_registered_checks( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_checks )
                                        exp = 79
                                        msg = 'Should register all active checks' ).
  ENDMETHOD.

  METHOD test_run_procedure.
    DATA lo_runner   TYPE REF TO zcl_skylint_runner.
    DATA ls_proc     TYPE zif_skylint_types=>ty_procedure.
    DATA lt_findings TYPE zif_skylint_types=>ty_findings.

    lo_runner = zcl_skylint_runner=>create_default( ).

    " Describe lines is check 001: DESCRIBE TABLE lt_tab LINES lv_cnt.
    ls_proc-statements = VALUE #(
        ( keyword  = 'DESCRIBE'
          position = VALUE #( line = 2 column = 1 )
          tokens   = VALUE #(
              ( lexeme = 'DESCRIBE' position = VALUE #( line = 2 column = 1 ) )
              ( lexeme = 'TABLE'    position = VALUE #( line = 2 column = 10 ) )
              ( lexeme = 'LT_TAB'   position = VALUE #( line = 2 column = 16 ) )
              ( lexeme = 'LINES'    position = VALUE #( line = 2 column = 23 ) )
              ( lexeme = 'LV_CNT'   position = VALUE #( line = 2 column = 29 ) )
              ( lexeme = '.'        position = VALUE #( line = 2 column = 35 ) ) ) ) ).

    lt_findings = lo_runner->run_procedure( ls_proc ).

    cl_abap_unit_assert=>assert_not_initial( act = lt_findings
                                             msg = 'Runner should find violations' ).
  ENDMETHOD.

ENDCLASS.
