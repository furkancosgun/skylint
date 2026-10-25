CLASS zcl_skylint_no_endselect DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        select_endselect TYPE if_ci_atc_check=>ty_finding_code VALUE 'ENDSELECT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'ENDSELECT'.

ENDCLASS.


CLASS zcl_skylint_no_endselect IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Avoid SELECT ... ENDSELECT Loops'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-select_endselect
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_package_size TYPE abap_bool VALUE abap_false.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SELECT'.
          lv_has_package_size = zcl_skylint_ast_util=>match_token_sequence(
                                    is_statement = <ls_statement>
                                    it_expected  = VALUE #( ( `PACKAGE` ) ( `SIZE` ) ) ).
        WHEN 'ENDSELECT'.
          IF lv_has_package_size = abap_true.
            lv_has_package_size = abap_false.
            CONTINUE.
          ENDIF.

          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-select_endselect ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
