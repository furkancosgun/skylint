CLASS zcl_skylint_check_032 DEFINITION
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
    DATA mv_check_select_star TYPE abap_bool VALUE abap_true.
    DATA mv_check_endselect   TYPE abap_bool VALUE abap_true.

    METHODS is_select_star
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_032 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Select performance (Avoid SELECT * and SELECT ... ENDSELECT)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity = if_ci_atc_check=>finding_severities-warning
                                     ( code = c_finding_codes-select_star
                                       text = 'Avoid SELECT *; specify required columns explicitly' )
                                     ( code = c_finding_codes-select_endselect
                                       text = 'Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_SELECT_STAR'
                                                                value = REF #( mv_check_select_star ) )
                                                              ( name  = 'CHECK_ENDSELECT'
                                                                value = REF #( mv_check_endselect ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_check_star      TYPE abap_bool.
    DATA lv_check_endselect TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'CHECK_SELECT_STAR'
                   IMPORTING ev_value = lv_check_star ).
    get_attribute( EXPORTING iv_name  = 'CHECK_ENDSELECT'
                   IMPORTING ev_value = lv_check_endselect ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SELECT'.
          IF lv_check_star = abap_true AND is_select_star( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-select_star ).
          ENDIF.
        WHEN 'ENDSELECT'.
          IF lv_check_endselect = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-select_endselect ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_select_star.
    rv_res = abap_false.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = `*` ) = abap_true.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    IF     zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 2
                                                   iv_expected  = `SINGLE` )   = abap_true
       AND zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 3
                                                   iv_expected  = `*` )        = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
