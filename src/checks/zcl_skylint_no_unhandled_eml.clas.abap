CLASS zcl_skylint_no_unhandled_eml DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unhandled_eml TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNHAND_EML',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EML_RESPONSE'.

    DATA mv_check_modify TYPE abap_bool VALUE abap_true.
    DATA mv_check_read   TYPE abap_bool VALUE abap_true.

    METHODS is_eml_statement
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_unhandled_eml IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Provide FAILED and REPORTED in RAP EML statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-unhandled_eml
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Always provide FAILED and REPORTED in EML statements'
                                                pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_MODIFY'
                                                value = REF #( mv_check_modify ) )
                                              ( name  = 'CHECK_READ'
                                                value = REF #( mv_check_read ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_failed   TYPE abap_bool.
    DATA lv_has_reported TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_eml_statement( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_has_failed   = abap_false.
      lv_has_reported = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                   iv_lexeme = 'FAILED' ) = abap_true.
          lv_has_failed = abap_true.
        ELSEIF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                       iv_lexeme = 'REPORTED' ) = abap_true.
          lv_has_reported = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_has_failed = abap_false OR lv_has_reported = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-unhandled_eml ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_eml_statement.
    rv_yes = abap_false.

    IF     mv_check_modify = abap_true
       AND (    zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                            it_expected  = VALUE #( ( `MODIFY` ) ( `ENTITIES` ) ) ) = abap_true
             OR zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                            it_expected  = VALUE #( ( `MODIFY` ) ( `ENTITY` ) ) )   = abap_true ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     mv_check_read = abap_true
       AND (    zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                            it_expected  = VALUE #( ( `READ` ) ( `ENTITIES` ) ) ) = abap_true
             OR zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                            it_expected  = VALUE #( ( `READ` ) ( `ENTITY` ) ) )   = abap_true ).
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
