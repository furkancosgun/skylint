CLASS zcl_skylint_no_method_chain DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        excessive_chaining TYPE if_ci_atc_check=>ty_finding_code VALUE 'METH_CHAIN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_METHOD_CHAIN'.

    DATA mv_max_chain TYPE i VALUE 1.

    METHODS count_method_chains
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_skylint_no_method_chain IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid excessive method chaining; extract into variables'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-excessive_chaining
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Excessive method chaining; extract intermediate results into variables'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_CHAIN'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_chain ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_chain_count TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_chain_count = count_method_chains( <ls_statement> ).
      IF lv_chain_count > mv_max_chain.
        report_statement(
            is_statement    = <ls_statement>
            iv_finding_code = c_finding_codes-excessive_chaining ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_method_chains.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_count = 0.

    LOOP AT is_statement-tokens INTO ls_token.
      IF ls_token-lexeme CP '*->*' OR ls_token-lexeme CP '*=>*'.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
