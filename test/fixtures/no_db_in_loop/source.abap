CLASS zcl_test_no_db_in_loop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_test_no_db_in_loop IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    DATA ls_row TYPE t100.
    DATA ls_key TYPE string.
    LOOP AT lt_tab INTO ls_row.
      SELECT SINGLE * FROM t100 INTO @ls_row WHERE arbgb = @ls_key.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA ls_row TYPE t100.
    DATA ls_key TYPE string.
    SELECT SINGLE * FROM t100 INTO @ls_row WHERE arbgb = @ls_key.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    DATA ls_row TYPE t100.
    DATA ls_key TYPE string.
    DO 2 TIMES.
      SELECT SINGLE * FROM t100 INTO @ls_row WHERE arbgb = @ls_key.
    ENDDO.
  ENDMETHOD.

  METHOD test_004.
    DATA ls_key TYPE string.
    UPDATE t100 SET arbgb = ls_key WHERE arbgb = ls_key.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_keys TYPE string_table.
    DO 2 TIMES.
      MODIFY ENTITY z_entity EXECUTE action_name FROM lt_keys.
    ENDDO.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_keys TYPE string_table.
    DATA lt_result TYPE string_table.
    DATA lt_failed TYPE string_table.
    LOOP AT lt_keys INTO DATA(lv_key).
      READ ENTITIES OF z_root ENTITY z_entity ALL FIELDS WITH lt_keys RESULT lt_result FAILED lt_failed.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_keys TYPE string_table.
    MODIFY ENTITY z_entity EXECUTE action_name FROM lt_keys.
  ENDMETHOD.
ENDCLASS.
