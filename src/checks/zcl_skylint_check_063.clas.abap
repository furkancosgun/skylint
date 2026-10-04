CLASS zcl_skylint_check_063 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_sys TYPE zif_skylint_types=>ty_finding_code VALUE 'RAISE_SYS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_063 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid raising SAP internal system exceptions (cx_sy_*)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-raise_sys
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid raising SAP internal system exceptions; use application exceptions'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE zif_skylint_types=>ty_compiler_reference.
    DATA lv_is_raise   TYPE abap_bool.
    DATA lv_is_sys_exc TYPE abap_bool.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
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
        lv_is_sys_exc = abap_false.

        " 1. Lexeme check (e.g. CX_SY_ZERODIVIDE)
        IF to_upper( <ls_token>-lexeme ) CP 'CX_SY_*'.
          lv_is_sys_exc = abap_true.
        ENDIF.

        " 2. Compiler semantic references (type reference to CX_SY_*)
        IF lv_is_sys_exc = abap_false.
          LOOP AT <ls_token>-references ASSIGNING <ls_ref>
               WHERE kind = zif_skylint_types=>compiler_reference_kinds-type.
            IF to_upper( <ls_ref>-full_name ) CS 'CX_SY_'.
              lv_is_sys_exc = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF lv_is_sys_exc = abap_true.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-raise_sys ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
