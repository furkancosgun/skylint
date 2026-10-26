CLASS zcl_skylint_no_loop_into DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        loop_copy TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_LOOPIN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_LOOP_INTO'.

    METHODS is_reference_table
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name  TYPE if_ci_atc_source_code_provider=>ty_full_name
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_loop_into IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer ASSIGNING over LOOP INTO copy targets'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-loop_copy
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Loop copies each row; use ASSIGNING with a field symbol'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_count       TYPE i.
    DATA lv_at          TYPE i.
    DATA ls_table_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_reference   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      lv_count = zcl_skylint_ast_util=>token_count( <ls_statement> ).
      lv_at = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                iv_lexeme    = 'AT' ).
      IF lv_at = 0 OR lv_at >= lv_count.
        CONTINUE.
      ENDIF.

      IF     zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                iv_lexeme    = 'INTO' ) = 0
          OR zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                iv_lexeme    = 'ASSIGNING' ) > 0
          OR zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                iv_lexeme    = 'REFERENCE' ) > 0.
        CONTINUE.
      ENDIF.

      ls_table_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                        iv_index     = lv_at + 1 ).
      ls_reference = zcl_skylint_ast_util=>get_reference( is_token = ls_table_token
                                                          iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF is_reference_table( it_statements = is_procedure-statements
                             iv_full_name  = ls_reference-full_name ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-loop_copy ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_reference_table.
    DATA lv_idx TYPE i.
    DATA lv_seq TYPE i.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    IF iv_full_name IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'DATA'.
        CONTINUE.
      ENDIF.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_idx = sy-tabix.
        IF <ls_token>-references IS INITIAL.
          CONTINUE.
        ENDIF.
        IF NOT line_exists( <ls_token>-references[ kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                                                   full_name = iv_full_name ] ).
          CONTINUE.
        ENDIF.
        lv_seq = zcl_skylint_ast_util=>find_token_sequence(
                     is_statement   = <ls_statement>
                     it_expected    = VALUE #( ( `REF` ) ( `TO` ) )
                     iv_start_index = lv_idx + 1 ).
        IF lv_seq > 0.
          rv_yes = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
