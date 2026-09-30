CLASS zcl_skylint_check_038 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SELECT_PERF'.

    METHODS is_select_star
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_038 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Select performance (Avoid SELECT * and SELECT ... ENDSELECT)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-select_star
                                       text = 'Avoid SELECT *; specify required columns explicitly' )
                                     ( code = c_finding_codes-select_endselect
                                       text = 'Avoid SELECT ... ENDSELECT loop; use array fetch INTO TABLE' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SELECT'.
          IF is_select_star( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-select_star ).
          ENDIF.
        WHEN 'ENDSELECT'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-select_endselect ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_select_star.
    rv_res = abap_false.

    IF matches_token_at( is_statement = is_statement
                         iv_index     = 2
                         iv_expected  = `*` ) = abap_true.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    IF matches_token_at( is_statement      = is_statement
                         iv_index          = 2
                         iv_expected       = `SINGLE`
                         iv_case_sensitive = abap_true ) = abap_true
       AND matches_token_at( is_statement = is_statement
                             iv_index     = 3
                             iv_expected  = `*` ) = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
