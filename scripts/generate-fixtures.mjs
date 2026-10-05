import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const testsDir = path.join(rootDir, 'src', 'tests');

if (!fs.existsSync(testsDir)) {
  fs.mkdirSync(testsDir, { recursive: true });
}

function extractStringLines(block) {
  const lines = [];
  const regex = /`([^`]*)`/g;
  let m;
  while ((m = regex.exec(block)) !== null) {
    lines.push(m[1]);
  }
  return lines;
}

function extractMethodBody(content, methodName) {
  const regex = new RegExp(`METHOD\\s+${methodName}\\.([\\s\\S]*?)ENDMETHOD\\.`, 'i');
  const match = content.match(regex);
  if (!match) return [];
  return extractStringLines(match[1]);
}

const checkFiles = fs.readdirSync(checksDir)
  .filter(f => f.endsWith('.clas.testclasses.abap'))
  .sort();

console.log(`Generating global test fixtures in ${testsDir}...`);

const customFixtures = {
  '002': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO ${cls}.
    CALL METHOD lo_obj->run.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    lo_obj->run( ).
  ENDMETHOD.
ENDCLASS.`,

  '004': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF NOT lv_x IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.
ENDCLASS.`,

  '005': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    me->run( ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    lo_obj->run( ).
  ENDMETHOD.
ENDCLASS.`,

  '006': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run IMPORTING iv_in TYPE i OPTIONAL.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_x TYPE i.
    lo_obj->run( EXPORTING iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_x TYPE i.
    lo_obj->run( iv_in = lv_x ).
  ENDMETHOD.
ENDCLASS.`,

  '008': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA: lv_a TYPE i,
          lv_b TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
  ENDMETHOD.
ENDCLASS.`,

  '009': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_c TYPE string.
    CONCATENATE lv_a lv_b INTO lv_c.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_c TYPE string.
    lv_c = |{ lv_a }{ lv_b }|.
  ENDMETHOD.
ENDCLASS.`,

  '010': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_validator TYPE REF TO ${cls}.
    IF lo_validator->is_valid( ) = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_validator TYPE REF TO ${cls}.
    DATA lv_flag TYPE abap_bool.
    IF lo_validator->is_valid( ).
    ENDIF.
    IF lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.`,

  '020': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lv_code TYPE c LENGTH 1.
    IF 'X' = lv_code.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_code TYPE c LENGTH 1.
    IF lv_code = 'X'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.`,

  '022': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lo_obj TYPE REF TO ${cls}.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_cls TYPE string.
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.
ENDCLASS.`,

  '023': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_002.
    RAISE EXCEPTION NEW cx_sy_zerodivide( ).
  ENDMETHOD.
ENDCLASS.`,

  '025': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run
      IMPORTING iv_in TYPE i OPTIONAL
      RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD run.
    rv_val = iv_in.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run RECEIVING rv_val = lv_x.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x.
  ENDMETHOD.
ENDCLASS.`,

  '026': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS do_work.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD do_work.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO ${cls}.
    lo_obj->do_work( ).
  ENDMETHOD.

  METHOD test_002.
    ${cls}=>do_work( ).
  ENDMETHOD.
ENDCLASS.`,

  '027': (cls) => `CLASS lcl_mutable DEFINITION.
  PUBLIC SECTION.
    DATA mv_attr TYPE i.
ENDCLASS.
CLASS lcl_mutable IMPLEMENTATION.
ENDCLASS.

CLASS lcl_clean DEFINITION.
  PUBLIC SECTION.
    DATA mv_attr TYPE i READ-ONLY.
ENDCLASS.
CLASS lcl_clean IMPLEMENTATION.
ENDCLASS.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '029': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS run_with_many_params
      IMPORTING
        a TYPE i b TYPE i c TYPE i d TYPE i
        e TYPE i f TYPE i g TYPE i h TYPE i j TYPE i.
    METHODS run_clean
      IMPORTING
        a TYPE i b TYPE i.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD run_with_many_params.
    RETURN.
  ENDMETHOD.

  METHOD run_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '030': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    DATA ls_row TYPE zskylint_dummy.
    DATA ls_key TYPE string.
    LOOP AT lt_tab INTO ls_row.
      SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA ls_row TYPE zskylint_dummy.
    DATA ls_key TYPE string.
    SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.
  ENDMETHOD.
ENDCLASS.`,

  '031': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_entry,
        field1 TYPE c LENGTH 10,
      END OF ty_entry.
    TYPES tt_entry TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN s WHERE field1 = s-field1.
  ENDMETHOD.

  METHOD test_002.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF s IS NOT INITIAL.
      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN s WHERE field1 = s-field1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.`,

  '032': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    SELECT * FROM zskylint_dummy INTO @DATA(ls_row).
    ENDSELECT.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab.
  ENDMETHOD.
ENDCLASS.`,

  '036': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run IMPORTING iv_param TYPE i.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_val TYPE i.
    lo_obj->run( iv_param = lv_val ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    DATA lv_val TYPE i.
    lo_obj->run( lv_val ).
  ENDMETHOD.
ENDCLASS.`,

  '038': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    MOVE-CORRESPONDING ls_src TO ls_dst.
  ENDMETHOD.

  METHOD test_002.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    ls_dst = CORRESPONDING #( ls_src ).
  ENDMETHOD.
ENDCLASS.`,

  '042': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS get_value_exporting EXPORTING ev_val TYPE i.
    METHODS get_value_returning RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD get_value_exporting.
    RETURN.
  ENDMETHOD.

  METHOD get_value_returning.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '043': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS get_data_classic EXCEPTIONS not_found.
    METHODS get_data_clean RAISING cx_static_check.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD get_data_classic.
    RETURN.
  ENDMETHOD.

  METHOD get_data_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '045': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    CALL TRANSACTION 'VA01'.
  ENDMETHOD.

  METHOD test_002.
    CALL TRANSACTION 'VA01' WITH AUTHORITY-CHECK.
  ENDMETHOD.
ENDCLASS.`,

  '046': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy UP TO 1 ROWS INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy UP TO 1 ROWS INTO TABLE @lt_tab ORDER BY field1.
  ENDMETHOD.
ENDCLASS.`,

  '048': (cls) => `CLASS lcl_not_final DEFINITION.
ENDCLASS.
CLASS lcl_not_final IMPLEMENTATION.
ENDCLASS.

CLASS lcl_clean DEFINITION FINAL.
ENDCLASS.
CLASS lcl_clean IMPLEMENTATION.
ENDCLASS.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '049': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RAISE SHORTDUMP TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_002.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.
ENDCLASS.`,

  '052': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      AT NEW ls_row.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      CONTINUE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.`,

  '053': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lv_orig TYPE i.
    DATA lv_x LIKE lv_orig.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_y TYPE i.
  ENDMETHOD.
ENDCLASS.`,

  '054': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD constructor.
    DATA lv_val TYPE i.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '055': (cls) => `CLASS lcl_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS run.
ENDCLASS.
CLASS lcl_helper IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_clean DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS run.
    METHODS execute.
ENDCLASS.
CLASS lcl_clean IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.
  METHOD execute.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '056': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD get_status.
    rv_flag = abap_true.
  ENDMETHOD.

  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.`,

  '057': (cls) => `CLASS lcl_l1 DEFINITION.
ENDCLASS.
CLASS lcl_l1 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_l2 DEFINITION INHERITING FROM lcl_l1.
ENDCLASS.
CLASS lcl_l2 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_l3 DEFINITION INHERITING FROM lcl_l2.
ENDCLASS.
CLASS lcl_l3 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_l4 DEFINITION INHERITING FROM lcl_l3.
ENDCLASS.
CLASS lcl_l4 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_child DEFINITION INHERITING FROM lcl_l4.
ENDCLASS.
CLASS lcl_child IMPLEMENTATION.
ENDCLASS.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '058': (cls) => `CLASS lcl_god DEFINITION.
  PUBLIC SECTION.
    DATA mv_a1 TYPE i.
    DATA mv_a2 TYPE i.
    DATA mv_a3 TYPE i.
    DATA mv_a4 TYPE i.
    DATA mv_a5 TYPE i.
    DATA mv_a6 TYPE i.
    DATA mv_a7 TYPE i.
    DATA mv_a8 TYPE i.
    DATA mv_a9 TYPE i.
    DATA mv_a10 TYPE i.
    DATA mv_a11 TYPE i.
    DATA mv_a12 TYPE i.
    DATA mv_a13 TYPE i.
    DATA mv_a14 TYPE i.
    DATA mv_a15 TYPE i.
    DATA mv_a16 TYPE i.
    DATA mv_a17 TYPE i.
    DATA mv_a18 TYPE i.
    DATA mv_a19 TYPE i.
    DATA mv_a20 TYPE i.
    DATA mv_a21 TYPE i.
ENDCLASS.
CLASS lcl_god IMPLEMENTATION.
ENDCLASS.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '059': (cls) => `INTERFACE lif_test.
  DATA mv_state TYPE i.
ENDINTERFACE.

INTERFACE lif_clean.
  CONSTANTS c_version TYPE i VALUE 1.
ENDINTERFACE.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '060': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    TRY.
    CATCH cx_static_check.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.`,

  '061': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001 EXCEPTIONS error.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    MESSAGE e001(00) WITH 'test' RAISING error.
  ENDMETHOD.

  METHOD test_002.
    MESSAGE 'clean' TYPE 'I'.
  ENDMETHOD.
ENDCLASS.`,

  '062': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    TRY.
      TRY.
      CATCH cx_root.
      ENDTRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.`,

  '064': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    READ TABLE lt_tab INDEX 1 TRANSPORTING NO FIELDS.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    READ TABLE lt_tab INDEX 1 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.`,

  '065': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO ${cls}.
    lo_obj->test_002( ).
  ENDMETHOD.
ENDCLASS.`,

  '066': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy USING CLIENT '100' INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab.
  ENDMETHOD.
ENDCLASS.`,

  '068': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_row,
        field1 TYPE i,
      END OF ty_row.

    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab FROM ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab FROM ls_row TRANSPORTING field1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.`,

  '069': (cls) => `CLASS lcl_test_naming DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS bad_name FOR TESTING.
    METHODS test_clean FOR TESTING.
ENDCLASS.

CLASS lcl_test_naming IMPLEMENTATION.
  METHOD bad_name.
    RETURN.
  ENDMETHOD.

  METHOD test_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '070': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lv_tab TYPE string.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM (lv_tab) INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @lt_tab.
  ENDMETHOD.
ENDCLASS.`,

  '071': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS do_work.
    METHODS do_work_clean FINAL.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD do_work.
    RETURN.
  ENDMETHOD.

  METHOD do_work_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.`,

  '074': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_row,
        flag TYPE abap_bool,
      END OF ty_row.

    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    DATA ls_val TYPE i.
    LOOP AT lt_tab INTO ls_row.
      IF ls_row-flag = abap_true.
        ls_val = 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    DATA ls_val TYPE i.
    LOOP AT lt_tab INTO ls_row.
      ls_val = 1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.`,

  '079': (cls) => `CLASS ${cls} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS meth_escaped IMPORTING !iv_param TYPE i.
    METHODS meth_clean IMPORTING iv_param TYPE i.
ENDCLASS.

CLASS ${cls} IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD meth_escaped.
    RETURN.
  ENDMETHOD.

  METHOD meth_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.`
};

const varTypes = {
  lv_a: 'i',
  lv_b: 'i',
  lv_c: 'i',
  lv_d: 'i',
  lv_e: 'i',
  lv_f: 'i',
  lv_x: 'i',
  lv_y: 'i',
  lv_val: 'i',
  lv_flag: 'abap_bool',
  lv_cnt: 'i',
  lv_text: 'string',
  lv_msg: 'string',
  lv_lin: 'i',
  lv_wrd: 'string',
  lv_cls: 'string',
  lv_type: 'i',
  lv_tab: 'string',
  lt_tab: 'string_table',
  lt_mara: 'string_table',
  lt_prog: 'string_table',
  ls_row: 'string',
  ls_val: 'i',
  ls_key: 'string',
  lo_obj: 'REF TO object'
};

function injectDeclarations(lines) {
  const code = lines.join('\n');
  const needed = [];

  for (const [varName, varType] of Object.entries(varTypes)) {
    const regex = new RegExp(`\\b${varName}\\b`, 'i');
    if (regex.test(code)) {
      const declRegex = new RegExp(`(DATA|FIELD-SYMBOLS)\\s+.*\\b${varName}\\b`, 'i');
      if (!declRegex.test(code)) {
        needed.push(`    DATA ${varName} TYPE ${varType}.`);
      }
    }
  }

  const declBlock = needed.join('\n');
  const bodyBlock = lines.map(l => '    ' + l).join('\n');

  if (needed.length > 0) {
    return declBlock + '\n' + bodyBlock;
  }
  return bodyBlock.length > 0 ? bodyBlock : '    RETURN.';
}

for (const f of checkFiles) {
  const match = f.match(/check_(\d+)/i);
  if (!match) continue;
  const num = match[1];
  const className = `zcl_skylint_test_${num}`;
  const filePath = path.join(checksDir, f);
  const content = fs.readFileSync(filePath, 'utf8');

  let abapCode = '';
  if (customFixtures[num]) {
    abapCode = customFixtures[num](className);
  } else {
    const findingLines = extractMethodBody(content, 'test_finding');
    const cleanLines = extractMethodBody(content, 'test_clean');

    const findingBody = injectDeclarations(findingLines);
    const cleanBody = injectDeclarations(cleanLines);

    abapCode = `CLASS ${className} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS ${className} IMPLEMENTATION.
  METHOD test_001.
${findingBody}
  ENDMETHOD.

  METHOD test_002.
${cleanBody}
  ENDMETHOD.
ENDCLASS.
`;
  }

  const xmlCode = `<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>${className.toUpperCase()}</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>skylint: Fixture for Check ${num}</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
`;

  fs.writeFileSync(path.join(testsDir, `${className}.clas.abap`), abapCode + '\n', 'utf8');
  fs.writeFileSync(path.join(testsDir, `${className}.clas.xml`), xmlCode, 'utf8');
}

console.log(`✓ Successfully generated ${checkFiles.length} fixtures in src/tests/!`);
