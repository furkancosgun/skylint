CLASS zcl_skylint_max_locals DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        local_count TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_LOCALS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_LOCALS'.

    DATA mv_max_locals TYPE i VALUE 15.

    METHODS add_local
      IMPORTING iv_name       TYPE string
      CHANGING  ct_names      TYPE ty_names.

ENDCLASS.


CLASS zcl_skylint_max_locals IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit local variable count per procedure'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-local_count
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Procedure declares too many local symbols'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_LOCALS'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_locals ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_names      TYPE ty_names.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_token      TYPE if_ci_atc_source_code_provider=>ty_token.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_reference> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'FIELD-SYMBOLS'.
        ls_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                    iv_index     = 2 ).
        add_local( EXPORTING iv_name  = ls_token-lexeme
                   CHANGING  ct_names = lt_names ).
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references ASSIGNING <ls_reference>.
          IF zcl_skylint_ast_util=>is_data_definition( <ls_reference> ) = abap_false.
            CONTINUE.
          ENDIF.
          add_local( EXPORTING iv_name  = <ls_reference>-full_name
                     CHANGING  ct_names = lt_names ).
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    IF lines( lt_names ) <= mv_max_locals.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-local_count ).
    ENDIF.
  ENDMETHOD.

  METHOD add_local.
    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.
    IF line_exists( ct_names[ table_line = iv_name ] ).
      RETURN.
    ENDIF.
    INSERT iv_name INTO TABLE ct_names.
  ENDMETHOD.
ENDCLASS.
