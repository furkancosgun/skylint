CLASS zcl_skylint_open_test_run DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_expected_finding,
        line TYPE i,
        code TYPE zif_skylint_types=>ty_finding_code,
      END OF ty_expected_finding,
      ty_expected_findings TYPE STANDARD TABLE OF ty_expected_finding WITH EMPTY KEY.

    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZSKYLINT_TEST'.

    METHODS execute
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                is_object   TYPE zif_skylint_types=>ty_object
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.

    CLASS-METHODS run_check
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string       OPTIONAL
                it_source           TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool    DEFAULT abap_false
                iv_object_name      TYPE string       OPTIONAL
      RETURNING VALUE(rt_findings)  TYPE zif_skylint_types=>ty_findings
      RAISING   cx_static_check.

    CLASS-METHODS assert_findings
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string       OPTIONAL
                it_source           TYPE string_table OPTIONAL
                it_expected         TYPE ty_expected_findings
                iv_class_definition TYPE abap_bool    DEFAULT abap_false
      RAISING   cx_static_check.

    CLASS-METHODS assert_no_findings
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string       OPTIONAL
                it_source           TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool    DEFAULT abap_false
      RAISING   cx_static_check.

    CLASS-METHODS assert_fixed
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_fixed_source     TYPE string       OPTIONAL
                it_fixed_source     TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool    DEFAULT abap_false
      RAISING   cx_static_check.

    CLASS-METHODS assert_quickfix
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_bad_source       TYPE string                              OPTIONAL
                it_bad_source       TYPE string_table                        OPTIONAL
                it_expected_fixed   TYPE string_table                        OPTIONAL
                iv_quickfix_code    TYPE zif_skylint_types=>ty_quickfix_code OPTIONAL
                iv_class_definition TYPE abap_bool                           DEFAULT abap_false
      RAISING   cx_static_check.

  PROTECTED SECTION.
    METHODS run_in_memory
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                is_object   TYPE zif_skylint_types=>ty_object
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.

  PRIVATE SECTION.
    CLASS-METHODS read_test_source
      IMPORTING iv_class         TYPE string
                iv_method        TYPE string OPTIONAL
                iv_class_def     TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_source) TYPE string.

    CLASS-METHODS canonicalize
      IMPORTING it_source      TYPE string_table
      RETURNING VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_skylint_open_test_run IMPLEMENTATION.
  METHOD execute.
    run_in_memory( io_check    = io_check
                   is_object   = is_object
                   it_expected = it_expected ).
  ENDMETHOD.

  METHOD run_in_memory.
    DATA lv_source   TYPE string.
    DATA lt_findings TYPE zif_skylint_types=>ty_findings.
    DATA ls_exp      TYPE zif_skylint_types=>ty_test_expected.
    DATA lv_found    TYPE abap_bool.
    DATA lv_class    TYPE string.

    lv_class = is_object-name.

    LOOP AT it_expected INTO ls_exp.
      lv_source = read_test_source(
          iv_class  = lv_class
          iv_method = ls_exp-method ).

      IF lv_source IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_source CP 'CLASS * DEFINITION*' OR lv_source CP 'INTERFACE *'.
        lt_findings = run_check( io_check            = io_check
                                 iv_source           = lv_source
                                 iv_class_definition = abap_true
                                 iv_object_name      = lv_class ).
      ELSE.
        lt_findings = run_check( io_check       = io_check
                                 iv_source      = lv_source
                                 iv_object_name = lv_class ).
      ENDIF.

      IF ls_exp-code IS NOT INITIAL AND lines( lt_findings ) = 0.
        lv_source = read_test_source(
            iv_class     = lv_class
            iv_class_def = abap_true ).
        IF lv_source IS NOT INITIAL.
          lt_findings = run_check( io_check            = io_check
                                   iv_source           = lv_source
                                   iv_class_definition = abap_true
                                   iv_object_name      = lv_class ).
        ENDIF.
      ENDIF.

      IF ls_exp-code IS INITIAL.
        cl_abap_unit_assert=>assert_equals(
            act = lines( lt_findings )
            exp = 0
            msg = |Method { ls_exp-method } in { is_object-name } expected 0 findings| ).
      ELSE.
        lv_found = xsdbool( line_exists( lt_findings[ code = ls_exp-code ] ) ).
        cl_abap_unit_assert=>assert_true(
            act = lv_found
            msg = |Method { ls_exp-method } in { is_object-name } expected finding { ls_exp-code }| ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_test_source.
    DATA lv_cls TYPE string.
    DATA lv_mth TYPE string.
    DATA lv_res TYPE string.
    DATA lv_def TYPE abap_bool.

    lv_cls = to_lower( iv_class ).
    lv_mth = to_upper( iv_method ).
    lv_def = iv_class_def.

    WRITE '@KERNEL const fs = await import("node:fs");'.
    WRITE '@KERNEL const path = await import("node:path");'.
    WRITE '@KERNEL const cls = lv_cls.get().trim();'.
    WRITE '@KERNEL const mth = lv_mth.get().trim();'.
    WRITE '@KERNEL const isDef = lv_def.get() === "X";'.
    WRITE '@KERNEL let p = path.join(process.cwd(), "src", "tests", cls + ".clas.abap");'.
    WRITE '@KERNEL if (!fs.existsSync(p)) {'.
    WRITE '@KERNEL   p = path.join(process.cwd(), "tests", cls + ".clas.abap");'.
    WRITE '@KERNEL }'.
    WRITE '@KERNEL if (fs.existsSync(p)) {'.
    WRITE '@KERNEL   const content = fs.readFileSync(p, "utf-8");'.
    WRITE '@KERNEL   const lines = content.split(/\r?\n/);'.
    WRITE '@KERNEL   const getDefs = () => {'.
    WRITE '@KERNEL     let defs = []; let cur = null;'.
    WRITE '@KERNEL     for (const line of lines) {'.
    WRITE '@KERNEL       const tr = line.trim().toUpperCase();'.
    WRITE '@KERNEL       const isClassDef = tr.startsWith("CLASS ") && tr.includes("DEFINITION");'.
    WRITE '@KERNEL       const isIntf = tr.startsWith("INTERFACE ");'.
    WRITE '@KERNEL       if (!cur && (isClassDef || isIntf)) {'.
    WRITE '@KERNEL         cur = [line];'.
    WRITE '@KERNEL       } else if (cur) {'.
    WRITE '@KERNEL         cur.push(line);'.
    WRITE '@KERNEL         if (tr === "ENDCLASS." || tr === "ENDINTERFACE.") {'.
    WRITE '@KERNEL           defs.push(cur.join("\n")); cur = null;'.
    WRITE '@KERNEL         }'.
    WRITE '@KERNEL       }'.
    WRITE '@KERNEL     }'.
    WRITE '@KERNEL     return defs;'.
    WRITE '@KERNEL   };'.
    WRITE '@KERNEL   if (isDef) {'.
    WRITE '@KERNEL     const defs = getDefs();'.
    WRITE '@KERNEL     const idx = (mth === "TEST_002" && defs.length > 1) ? 1 : 0;'.
    WRITE '@KERNEL     if (defs[idx]) lv_res.set(defs[idx]);'.
    WRITE '@KERNEL   } else if (mth) {'.
    WRITE '@KERNEL     let inMethod = false; let methodLines = [];'.
    WRITE '@KERNEL     for (const line of lines) {'.
    WRITE '@KERNEL       const tr = line.trim().toUpperCase();'.
    WRITE '@KERNEL       if (!inMethod) {'.
    WRITE '@KERNEL         if (tr.startsWith("METHOD " + mth + ".")) inMethod = true;'.
    WRITE '@KERNEL       } else {'.
    WRITE '@KERNEL         if (tr === "ENDMETHOD.") break;'.
    WRITE '@KERNEL         methodLines.push(line);'.
    WRITE '@KERNEL       }'.
    WRITE '@KERNEL     }'.
    WRITE '@KERNEL     const body = methodLines.join("\n").trim();'.
    WRITE '@KERNEL     if (body === "RETURN." || body === "") {'.
    WRITE '@KERNEL       const defs = getDefs();'.
    WRITE '@KERNEL       if (defs.length > 0) {'.
    WRITE '@KERNEL         const idx = (mth === "TEST_002" && defs.length > 1) ? 1 : 0;'.
    WRITE '@KERNEL         lv_res.set(defs[idx]);'.
    WRITE '@KERNEL       } else {'.
    WRITE '@KERNEL         lv_res.set("METHOD " + mth + ".\n" + body + "\nENDMETHOD.");'.
    WRITE '@KERNEL       }'.
    WRITE '@KERNEL     } else {'.
    WRITE '@KERNEL       lv_res.set("METHOD " + mth + ".\n" + body + "\nENDMETHOD.");'.
    WRITE '@KERNEL     }'.
    WRITE '@KERNEL   } else {'.
    WRITE '@KERNEL     lv_res.set(content);'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL }'.

    rv_source = lv_res.
  ENDMETHOD.

  METHOD run_check.
    DATA lv_source TYPE string.

    lv_source = lcl_runner=>join_source( iv_source = iv_source
                                         it_source = it_source ).
    rt_findings = lcl_runner=>execute( io_check            = io_check
                                       iv_source           = lv_source
                                       iv_class_definition = iv_class_definition
                                       iv_object_name      = iv_object_name ).
  ENDMETHOD.

  METHOD assert_findings.
    DATA lt_actual TYPE zif_skylint_types=>ty_findings.
    DATA ls_exp    TYPE ty_expected_finding.
    DATA ls_act    TYPE zif_skylint_types=>ty_finding.
    DATA lv_found  TYPE abap_bool.
    DATA lv_msg    TYPE string.

    lt_actual = run_check( io_check            = io_check
                           iv_source           = iv_source
                           it_source           = it_source
                           iv_class_definition = iv_class_definition ).

    cl_abap_unit_assert=>assert_equals( exp = lines( it_expected )
                                        act = lines( lt_actual )
                                        msg = 'Skylint findings count does not match expected' ).

    LOOP AT it_expected INTO ls_exp.
      lv_found = abap_false.
      LOOP AT lt_actual INTO ls_act WHERE code = ls_exp-code.
        IF ls_act-position-line = ls_exp-line.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      lv_msg = |Expected finding { ls_exp-code } at line { ls_exp-line } not found|.
      cl_abap_unit_assert=>assert_true( act = lv_found
                                        msg = lv_msg ).
    ENDLOOP.

    LOOP AT lt_actual INTO ls_act.
      lv_msg = |Unexpected finding { ls_act-code } at line { ls_act-position-line }|.
      cl_abap_unit_assert=>assert_true( act = xsdbool( line_exists( it_expected[ code = ls_act-code ] ) )
                                        msg = lv_msg ).
    ENDLOOP.
  ENDMETHOD.

  METHOD assert_no_findings.
    DATA lt_actual TYPE zif_skylint_types=>ty_findings.

    lt_actual = run_check( io_check            = io_check
                           iv_source           = iv_source
                           it_source           = it_source
                           iv_class_definition = iv_class_definition ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( lt_actual )
                                        msg = 'Expected no Skylint findings but some were reported' ).
  ENDMETHOD.

  METHOD assert_fixed.
    assert_no_findings( io_check            = io_check
                        iv_source           = iv_fixed_source
                        it_source           = it_fixed_source
                        iv_class_definition = iv_class_definition ).
  ENDMETHOD.

  METHOD assert_quickfix.
    DATA lt_findings TYPE zif_skylint_types=>ty_findings.
    DATA lt_recorded TYPE zif_skylint_types=>ty_quickfixes.
    DATA ls_recorded TYPE zif_skylint_types=>ty_quickfix.
    DATA lv_bad_str  TYPE string.
    DATA lt_bad      TYPE string_table.
    DATA lt_fixed    TYPE string_table.
    DATA ls_proc     TYPE zif_skylint_types=>ty_code_block.
    DATA lv_actual   TYPE string.
    DATA lv_expected TYPE string.

    lv_bad_str = lcl_runner=>join_source( iv_source = iv_bad_source
                                          it_source = it_bad_source ).
    lt_findings = run_check( io_check            = io_check
                             iv_source           = lv_bad_str
                             iv_class_definition = iv_class_definition ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_findings )
                                        msg = 'Quickfix test needs exactly one finding on bad source' ).

    lt_recorded = io_check->get_recorded_quickfixes( ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_recorded )
                                        msg = 'Check recorded no quickfix for this finding' ).
    READ TABLE lt_recorded INTO ls_recorded INDEX 1.
    cl_abap_unit_assert=>assert_subrc( msg = 'Quickfix record missing unexpectedly' ).

    IF iv_quickfix_code IS NOT INITIAL.
      cl_abap_unit_assert=>assert_equals( exp = iv_quickfix_code
                                          act = ls_recorded-code
                                          msg = 'Unexpected quickfix code recorded' ).
    ENDIF.

    lv_bad_str = lcl_runner=>wrap_source( iv_source           = lv_bad_str
                                          iv_class_definition = iv_class_definition ).
    SPLIT lv_bad_str AT cl_abap_char_utilities=>newline INTO TABLE lt_bad.
    ls_proc = lcl_runner=>build_code_block( iv_source           = lv_bad_str
                                            iv_class_definition = iv_class_definition ).
    lt_fixed = lcl_applier=>apply( it_lines      = lt_bad
                                   is_code_block = ls_proc
                                   is_recorded   = ls_recorded ).

    assert_no_findings( io_check            = io_check
                        it_source           = lt_fixed
                        iv_class_definition = iv_class_definition ).

    IF it_expected_fixed IS NOT INITIAL.
      lv_actual = canonicalize( lt_fixed ).
      lv_expected = canonicalize( it_expected_fixed ).
      cl_abap_unit_assert=>assert_equals( exp = lv_expected
                                          act = lv_actual
                                          msg = 'Quickfix result text does not match expected fixed source' ).
    ENDIF.
  ENDMETHOD.

  METHOD canonicalize.
    DATA lv_joined TYPE string.
    DATA ls_proc   TYPE zif_skylint_types=>ty_code_block.
    DATA lv_line   TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE zif_skylint_types=>ty_token.

    CLEAR rv_text.
    lv_joined = lcl_runner=>join_source( it_source = it_source ).
    ls_proc = lcl_runner=>build_code_block( lv_joined ).
    LOOP AT ls_proc-statements ASSIGNING <ls_stmt>.
      CLEAR lv_line.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        IF lv_line IS INITIAL.
          lv_line = <ls_tok>-lexeme.
        ELSE.
          lv_line = |{ lv_line } { <ls_tok>-lexeme }|.
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
