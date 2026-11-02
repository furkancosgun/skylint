CLASS zcl_skylint_test_lead_wildcard DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_lead_wildcard IMPLEMENTATION.
  METHOD test_001.
    SELECT * FROM t000 WHERE mandt LIKE '%00' INTO TABLE @DATA(lt_data).
  ENDMETHOD.

  METHOD test_002.
    SELECT * FROM t000 WHERE mandt LIKE '100%' INTO TABLE @DATA(lt_data).
  ENDMETHOD.

  METHOD test_003.
    SELECT * FROM t000 WHERE mandt LIKE '+00' INTO TABLE @DATA(lt_data).
  ENDMETHOD.

  METHOD test_004.
    DATA lv_pattern TYPE string.
    SELECT * FROM t000 WHERE mandt LIKE lv_pattern INTO TABLE @DATA(lt_data).
  ENDMETHOD.

  METHOD test_005.
    SELECT * FROM t000 WHERE mandt LIKE '%00' INTO TABLE @DATA(lt_data). "#EC NO_LEAD_WILDCARD
  ENDMETHOD.
ENDCLASS.
