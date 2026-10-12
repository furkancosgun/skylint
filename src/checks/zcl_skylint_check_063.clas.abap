CLASS zcl_skylint_check_063 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_sys TYPE if_ci_atc_check=>ty_finding_code VALUE 'RAISE_SYS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_system_exception
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_check_063 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid raising SAP internal system exceptions (cx_sy_*)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-raise_sys
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid raising SAP internal system exceptions; use application exceptions' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_is_raise TYPE abap_bool.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      " Exception raising context: RAISE statement or THROW expression
      IF <ls_statement>-keyword = 'RAISE'.
        lv_is_raise = abap_true.
      ELSE.
        lv_is_raise = zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                              iv_lexeme    = 'THROW' ).
      ENDIF.
      IF lv_is_raise = abap_false.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF is_system_exception( is_token      = <ls_token>
                                it_statements = is_procedure-statements ) = abap_true.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-raise_sys ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_system_exception.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.
    IF zcl_skylint_ast_util=>is_declared_data( it_statements = it_statements
                                               iv_name       = is_token-lexeme ) = abap_true.
      RETURN.
    ENDIF.

    IF is_token-lexeme CP 'CX_SY_*' AND is_token-references IS INITIAL.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
      IF <ls_ref>-full_name CS 'CX_SY_'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
