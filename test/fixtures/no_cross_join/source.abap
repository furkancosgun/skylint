CLASS zcl_skylint_test_cross_join DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_cross_join IMPLEMENTATION.
  METHOD test_001.
    SELECT FROM mara CROSS JOIN makt FIELDS mara~matnr INTO TABLE @DATA(lt_data).
  ENDMETHOD.

  METHOD test_002.
    SELECT FROM mara INNER JOIN makt ON mara~matnr = makt~matnr FIELDS mara~matnr INTO TABLE @DATA(lt_data).
  ENDMETHOD.

  METHOD test_003.
    SELECT FROM mara CROSS JOIN makt FIELDS mara~matnr INTO TABLE @DATA(lt_data). "#EC NO_CROSS_JOIN
  ENDMETHOD.
ENDCLASS.
