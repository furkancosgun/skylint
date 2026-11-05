CLASS /skyl/cl_no_read_in_loop DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        read_with_key TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RD_WKEY',
        read_where    TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RD_WHRE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_READ_LOOP'.

    DATA mv_check_with_key TYPE abap_bool VALUE abap_true.
    DATA mv_check_where    TYPE abap_bool VALUE abap_true.

    METHODS check_read_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS is_index_or_binary
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_result) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_read_in_loop IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid linear READ TABLE scans inside loop iterations'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-read_with_key
                                       text = 'READ TABLE ... WITH KEY inside a loop scans the table on every pass' )
                                     ( code = c_finding_codes-read_where
                                       text = 'READ TABLE ... WHERE inside a loop scans the table on every pass' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_WITH_KEY'
                                                                value = REF #( mv_check_with_key ) )
                                                              ( name  = 'CHECK_WHERE'
                                                                value = REF #( mv_check_where ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_depth = 0.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_depth += 1.
        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_depth > 0.
            lv_depth -= 1.
          ENDIF.
        WHEN 'READ'.
          IF lv_depth > 0.
            check_read_statement( <ls_statement> ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_read_statement.
    DATA lv_pos TYPE i.

    IF /skyl/cl_ast_util=>match_token_sequence( is_statement = is_statement
                                                it_expected  = VALUE #( ( `READ` ) ( `TABLE` ) ) ) = abap_false.
      RETURN.
    ENDIF.

    IF is_index_or_binary( is_statement ) = abap_true.
      RETURN.
    ENDIF.

    lv_pos = /skyl/cl_ast_util=>find_token( is_statement = is_statement
                                            iv_lexeme    = 'WHERE' ).
    IF mv_check_where = abap_true AND lv_pos > 0.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-read_where ).
      RETURN.
    ENDIF.

    lv_pos = /skyl/cl_ast_util=>find_token_sequence( is_statement = is_statement
                                                     it_expected  = VALUE #( ( `WITH` ) ( `KEY` ) ) ).
    IF mv_check_with_key = abap_true AND lv_pos > 0.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-read_with_key ).
    ENDIF.
  ENDMETHOD.

  METHOD is_index_or_binary.
    rv_result = xsdbool(    /skyl/cl_ast_util=>find_token_sequence(
                                is_statement = is_statement
                                it_expected  = VALUE #( ( `BINARY` ) ( `SEARCH` ) ) )  > 0
                         OR /skyl/cl_ast_util=>find_token( is_statement = is_statement
                                                           iv_lexeme    = 'INDEX' )    > 0 ).
  ENDMETHOD.
ENDCLASS.
