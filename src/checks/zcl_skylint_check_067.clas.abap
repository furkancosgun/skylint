CLASS zcl_skylint_check_067 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_commit TYPE zif_skylint_types=>ty_finding_code VALUE 'NO_COMMIT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_COMMIT_WORK'.

    METHODS is_behavior_implementation
      IMPORTING is_code_block  TYPE zif_skylint_types=>ty_code_block
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_067 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-no_commit
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid COMMIT/ROLLBACK WORK; transactional control belongs to framework'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_behavior_implementation( is_code_block ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMMIT' OR keyword = 'ROLLBACK'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-no_commit ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_behavior_implementation.
    DATA lt_supers    TYPE string_table.
    DATA lv_unit_name TYPE string.

    rv_res = abap_false.
    lv_unit_name = is_code_block-object_name.

    lt_supers = zcl_skylint_rtti_util=>get_super_classes( lv_unit_name ).
    IF    line_exists( lt_supers[ table_line = 'CL_ABAP_BEHAVIOR_HANDLER' ] )
       OR line_exists( lt_supers[ table_line = 'CL_ABAP_BEHAVIOR_SAVER' ] ).
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
