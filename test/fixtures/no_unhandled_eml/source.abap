CLASS zcl_test_no_unhandled_eml DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_unhandled_eml IMPLEMENTATION.
  METHOD test_001.
    " Violation: MODIFY ENTITY without FAILED / REPORTED
    DATA lt_keys TYPE string_table.
    MODIFY ENTITY z_entity
      EXECUTE action_name
      FROM lt_keys.
  ENDMETHOD.

  METHOD test_002.
    " Compliant: MODIFY ENTITY with both FAILED and REPORTED
    DATA lt_keys TYPE string_table.
    DATA lt_failed TYPE string_table.
    DATA lt_reported TYPE string_table.
    MODIFY ENTITY z_entity
      EXECUTE action_name
      FROM lt_keys
      FAILED lt_failed
      REPORTED lt_reported.
  ENDMETHOD.

  METHOD test_003.
    " Violation: READ ENTITIES without REPORTED
    DATA lt_keys TYPE string_table.
    DATA lt_result TYPE string_table.
    DATA lt_failed TYPE string_table.
    READ ENTITIES OF z_root
      ENTITY z_entity
      ALL FIELDS WITH lt_keys
      RESULT lt_result
      FAILED lt_failed.
  ENDMETHOD.

  METHOD test_004.
    " Compliant: COMMIT ENTITIES with FAILED and REPORTED
    DATA lt_failed TYPE string_table.
    DATA lt_reported TYPE string_table.
    COMMIT ENTITIES
      RESPONSE OF z_root
      FAILED lt_failed
      REPORTED lt_reported.
  ENDMETHOD.

  METHOD test_005.
    " Compliant: pseudo-comment suppression
    DATA lt_keys TYPE string_table.
    MODIFY ENTITY z_entity EXECUTE action_name FROM lt_keys. "#EC EML_RESPONSE
  ENDMETHOD.
ENDCLASS.
