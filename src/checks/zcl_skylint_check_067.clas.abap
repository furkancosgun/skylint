CLASS zcl_skylint_check_067 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_COMMIT_WORK'.
ENDCLASS.


CLASS zcl_skylint_check_067 IMPLEMENTATION.
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

    "TODO behavior implementations oldugunu compiler uzerinden anlamamiz lazim
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMMIT' OR keyword = 'ROLLBACK'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-no_commit ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
