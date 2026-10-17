CLASS zcl_skylint_no_commit_work DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_commit TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_COMMIT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'COMMIT_WORK'.

    METHODS is_behavior_implementation
      IMPORTING is_procedure  TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_commit_work IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-no_commit
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid COMMIT/ROLLBACK WORK; transactional control belongs to framework'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_behavior_implementation( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'COMMIT' AND <ls_statement>-keyword <> 'ROLLBACK'.
        CONTINUE.
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-no_commit ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_behavior_implementation.
    DATA lt_supers    TYPE string_table.
    DATA lv_unit_name TYPE string.

    rv_res = abap_false.
    lv_unit_name = is_procedure-id-main_unit-name.

    lt_supers = zcl_skylint_rtti_util=>get_super_classes( lv_unit_name ).
    IF    line_exists( lt_supers[ table_line = 'CL_ABAP_BEHAVIOR_HANDLER' ] )
       OR line_exists( lt_supers[ table_line = 'CL_ABAP_BEHAVIOR_SAVER' ] ).
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
