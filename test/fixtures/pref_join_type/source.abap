CLASS zcl_test_prefer_join_type DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_test_prefer_join_type IMPLEMENTATION.
  METHOD test_001.
    SELECT * FROM mara
      JOIN makt ON mara~matnr = makt~matnr
      INTO TABLE @DATA(lt_rows).
  ENDMETHOD.

  METHOD test_002.
    SELECT * FROM mara
      INNER JOIN makt ON mara~matnr = makt~matnr
      INTO TABLE @DATA(lt_rows).
  ENDMETHOD.

  METHOD test_003.
    SELECT * FROM mara
      LEFT OUTER JOIN makt ON mara~matnr = makt~matnr
      INTO TABLE @DATA(lt_rows).
  ENDMETHOD.
ENDCLASS.
