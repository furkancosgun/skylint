CLASS ltcl_test_util DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS describe_finding          FOR TESTING RAISING cx_static_check.
    METHODS describe_clean            FOR TESTING RAISING cx_static_check.
    METHODS quickfix_roundtrip        FOR TESTING RAISING cx_static_check.
    METHODS test_chain_unrolling      FOR TESTING RAISING cx_static_check.
    METHODS test_compiler_assignment  FOR TESTING RAISING cx_static_check.
    METHODS test_compiler_method_call FOR TESTING RAISING cx_static_check.
    METHODS test_compiler_db_refs     FOR TESTING RAISING cx_static_check.
    METHODS test_compiler_system_var  FOR TESTING RAISING cx_static_check.
    METHODS test_token_types          FOR TESTING RAISING cx_static_check.
    METHODS test_statement_types      FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_util IMPLEMENTATION.
  METHOD describe_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_001( )
        it_source   = VALUE #( ( `DESCRIBE TABLE lt_tab LINES lv_cnt.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_001=>c_finding_codes-describe_lines ) ) ).
  ENDMETHOD.

  METHOD describe_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_001( )
        it_source = VALUE #( ( `lv_cnt = lines( lt_tab ).` ) ) ).
  ENDMETHOD.

  METHOD quickfix_roundtrip.
    DATA lo_check TYPE REF TO zcl_skylint_check_006.

    lo_check = NEW #( ).
    zcl_skylint_test_util=>assert_findings(
        io_check    = lo_check
        it_source   = VALUE #( ( `lo_obj->run( EXPORTING iv_in = lv_x ).` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_006=>c_finding_codes-omit_exporting ) ) ).

    zcl_skylint_test_util=>assert_fixed(
        io_check        = lo_check
        it_fixed_source = VALUE #( ( `lo_obj->run( iv_in = lv_x ).` ) ) ).
  ENDMETHOD.

  METHOD test_chain_unrolling.
    DATA ls_proc TYPE zif_skylint_types=>ty_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.

    ls_proc = lcl_runner=>build_procedure( `DATA: lv_a TYPE i, lv_b TYPE string.` ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_proc-statements )
                                        exp = 4
                                        msg = 'Chain should unroll into independent statements' ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 2.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-keyword
                                        exp = 'DATA' ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 3.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-keyword
                                        exp = 'DATA' ).
  ENDMETHOD.

  METHOD test_compiler_assignment.
    DATA ls_proc TYPE zif_skylint_types=>ty_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.

    ls_proc = lcl_runner=>build_procedure( `lv_val = 100.` ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 2.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-keyword
                                        exp = 'COMPUTE'
                                        msg = 'Implicit assignment must normalize to COMPUTE keyword' ).
  ENDMETHOD.

  METHOD test_compiler_method_call.
    DATA ls_proc TYPE zif_skylint_types=>ty_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.
    DATA ls_ref  TYPE zif_skylint_types=>ty_compiler_reference.

    ls_proc = lcl_runner=>build_procedure( `lo_worker->do_work( iv_param = 1 ).` ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 2.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-keyword
                                        exp = '+CALL_METHOD'
                                        msg = 'Functional method call must normalize to +CALL_METHOD' ).

    READ TABLE ls_stmt-tokens INTO ls_tok INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = xsdbool( lines( ls_tok-references ) > 0 )
                                        exp = abap_true
                                        msg = 'Method call token must contain compiler references' ).

    READ TABLE ls_tok-references INTO ls_ref INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_ref-kind
                                        exp = zif_skylint_types=>compiler_reference_kinds-method ).
    cl_abap_unit_assert=>assert_equals( act = ls_ref-usage_mode
                                        exp = zif_skylint_types=>usage_modes-read ).
  ENDMETHOD.

  METHOD test_compiler_db_refs.
    DATA ls_proc TYPE zif_skylint_types=>ty_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.
    DATA ls_ref  TYPE zif_skylint_types=>ty_compiler_reference.

    ls_proc = lcl_runner=>build_procedure( `SELECT * FROM sflight INTO TABLE @DATA(lt_flights).` ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 2.
    cl_abap_unit_assert=>assert_subrc( ).

    READ TABLE ls_stmt-tokens INTO ls_tok INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).

    READ TABLE ls_tok-references INTO ls_ref INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals( act = ls_ref-kind
                                        exp = zif_skylint_types=>compiler_reference_kinds-data ).
    cl_abap_unit_assert=>assert_equals( act = ls_ref-usage_mode
                                        exp = zif_skylint_types=>usage_modes-read_database
                                        msg = 'SELECT statement must produce read_database reference' ).
  ENDMETHOD.

  METHOD test_compiler_system_var.
    DATA ls_proc TYPE zif_skylint_types=>ty_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.
    DATA ls_ref  TYPE zif_skylint_types=>ty_compiler_reference.

    ls_proc = lcl_runner=>build_procedure( `sy-subrc = 4.` ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 2.
    cl_abap_unit_assert=>assert_subrc( ).

    READ TABLE ls_stmt-tokens INTO ls_tok INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).

    READ TABLE ls_tok-references INTO ls_ref INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals( act = ls_ref-kind
                                        exp = zif_skylint_types=>compiler_reference_kinds-data ).
    cl_abap_unit_assert=>assert_equals( act = ls_ref-usage_mode
                                        exp = zif_skylint_types=>usage_modes-write
                                        msg = 'Modification to sy-subrc must produce write reference' ).
  ENDMETHOD.

  METHOD test_token_types.
    DATA lo_lexer TYPE REF TO lcl_lexer.
    DATA lt_toks  TYPE zif_skylint_types=>ty_tokens.
    DATA ls_tok   TYPE zif_skylint_types=>ty_token.

    lo_lexer = NEW #( `lv_val = 'hello'. ##NO_TEXT " comment` ).
    lt_toks = lo_lexer->run( ).

    READ TABLE lt_toks INTO ls_tok INDEX 1.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-type
                                        exp = zif_skylint_types=>token_types-identifier ).

    READ TABLE lt_toks INTO ls_tok INDEX 3.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-type
                                        exp = zif_skylint_types=>token_types-literal ).

    READ TABLE lt_toks INTO ls_tok INDEX 5.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-type
                                        exp = zif_skylint_types=>token_types-pragma ).

    READ TABLE lt_toks INTO ls_tok INDEX 6.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-type
                                        exp = zif_skylint_types=>token_types-comment ).
  ENDMETHOD.

  METHOD test_statement_types.
    DATA ls_proc TYPE zif_skylint_types=>ty_procedure.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.

    ls_proc = lcl_runner=>build_procedure(
        `DATA lv_x TYPE i.` && cl_abap_char_utilities=>newline &&
        `lv_x = 1.` && cl_abap_char_utilities=>newline &&
        `lo_obj->do_it( ).` ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 2.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-type
                                        exp = zif_skylint_types=>statement_types-standard ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 3.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-type
                                        exp = zif_skylint_types=>statement_types-compute ).

    READ TABLE ls_proc-statements INTO ls_stmt INDEX 4.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_stmt-type
                                        exp = zif_skylint_types=>statement_types-method_direct ).
  ENDMETHOD.
ENDCLASS.
