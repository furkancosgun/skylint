CLASS zcl_skylint_no_select_star DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        select_star      TYPE if_ci_atc_check=>ty_finding_code VALUE 'SELECTSTAR',
        select_endselect TYPE if_ci_atc_check=>ty_finding_code VALUE 'ENDSELECT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SELECT_STAR'.

    DATA mv_check_select_star TYPE abap_bool VALUE abap_true.
    DATA mv_check_endselect   TYPE abap_bool VALUE abap_true.

    METHODS is_select_star
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_select_star IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Select performance (Avoid SELECT * and SELECT ... ENDSELECT)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity = if_ci_atc_check=>finding_severities-warning
                                     ( code           = c_finding_codes-select_star
                                       text           = 'Avoid SELECT *; specify required columns explicitly' )
                                     ( code           = c_finding_codes-select_endselect
                                       text           = 'Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_SELECT_STAR'
                                                                value = REF #( mv_check_select_star ) )
                                                              ( name  = 'CHECK_ENDSELECT'
                                                                value = REF #( mv_check_endselect ) ) ) ) ).
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

          IF mv_check_select_star = abap_true AND is_select_star( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-select_star ).
          ENDIF.
        WHEN 'ENDSELECT'.
          IF lv_has_package_size = abap_true.
            lv_has_package_size = abap_false.
            CONTINUE.
          ENDIF.

          IF mv_check_endselect = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-select_endselect ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_select_star.
    FIELD-SYMBOLS <ls_token> LIKE LINE OF is_statement-tokens.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme = '*' OR <ls_token>-lexeme CP '*~#**'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
