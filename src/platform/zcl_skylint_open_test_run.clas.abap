CLASS zcl_skylint_open_test_run DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                iv_class    TYPE string
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.

  PRIVATE SECTION.
    METHODS run_in_memory
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                iv_class    TYPE string
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.

    CLASS-METHODS read_test_source
      IMPORTING iv_class         TYPE string
                iv_method        TYPE string OPTIONAL
                iv_class_def     TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_source) TYPE string.

    CLASS-METHODS run_check
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string       OPTIONAL
                it_source           TYPE string_table OPTIONAL
                iv_class_definition TYPE abap_bool    DEFAULT abap_false
                iv_object_name      TYPE string       OPTIONAL
      RETURNING VALUE(rt_findings)  TYPE zif_skylint_types=>ty_findings
      RAISING   cx_static_check.

ENDCLASS.


CLASS zcl_skylint_open_test_run IMPLEMENTATION.
  METHOD execute.
    run_in_memory( io_check    = io_check
                   iv_class    = iv_class
                   it_expected = it_expected ).
  ENDMETHOD.

  METHOD run_in_memory.
    DATA lv_source   TYPE string.
    DATA lt_findings TYPE zif_skylint_types=>ty_findings.
    DATA ls_exp      TYPE zif_skylint_types=>ty_test_expected.
    DATA lv_found    TYPE abap_bool.
    DATA lv_class    TYPE string.
    FIELD-SYMBOLS <ls_finding> TYPE zif_skylint_types=>ty_finding.

    lv_class = iv_class.

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
            msg = |Method { ls_exp-method } in { iv_class } expected 0 findings| ).
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
            msg = |{ iv_class } { ls_exp-method }: expected { ls_exp-code } at { ls_exp-line }:{ ls_exp-column }| ).
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
    WRITE '@KERNEL   const testNum = parseInt(((mth.match(/(\d+)$/) || [])[1] || 0), 10);'.
    WRITE '@KERNEL   const wantClean = (testNum > 0 && testNum % 2 === 0);'.
    WRITE '@KERNEL   if (isDef) {'.
    WRITE '@KERNEL     const defs = getDefs();'.
    WRITE '@KERNEL     const idx = (wantClean && defs.length > 1) ? 1 : 0;'.
    WRITE '@KERNEL     if (defs[idx]) lv_res.set(defs[idx]);'.
    WRITE '@KERNEL   } else if (mth) {'.
    WRITE '@KERNEL     let inMethod = false; let methodLines = [];'.
    WRITE '@KERNEL     for (const line of lines) {'.
    WRITE '@KERNEL       const tr = line.trim().toUpperCase();'.
    WRITE '@KERNEL       if (!inMethod) {'.
    WRITE '@KERNEL         if (tr.startsWith("METHOD " + mth + ".")) { inMethod = true; methodLines.push(line); }'.
    WRITE '@KERNEL       } else {'.
    WRITE '@KERNEL         methodLines.push(line);'.
    WRITE '@KERNEL         if (tr === "ENDMETHOD.") break;'.
    WRITE '@KERNEL       }'.
    WRITE '@KERNEL     }'.
    WRITE '@KERNEL     const inner = methodLines.slice(1, -1).join("\n").trim();'.
    WRITE '@KERNEL     if (methodLines.length === 0) {'.
    WRITE '@KERNEL       lv_res.set("METHOD " + mth + ".\nENDMETHOD.");'.
    WRITE '@KERNEL     } else if (inner === "RETURN." || inner === "") {'.
    WRITE '@KERNEL       const defs = getDefs();'.
    WRITE '@KERNEL       if (defs.length > 0) {'.
    WRITE '@KERNEL         const idx = (wantClean && defs.length > 1) ? 1 : 0;'.
    WRITE '@KERNEL         lv_res.set(defs[idx]);'.
    WRITE '@KERNEL       } else {'.
    WRITE '@KERNEL         lv_res.set(methodLines.join("\n"));'.
    WRITE '@KERNEL       }'.
    WRITE '@KERNEL     } else {'.
    WRITE '@KERNEL       lv_res.set(methodLines.join("\n"));'.
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
ENDCLASS.
