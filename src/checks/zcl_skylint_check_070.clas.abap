CLASS zcl_skylint_check_070 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_method_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'BOOL_NAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'BOOL_METHOD_NAME'.

ENDCLASS.


CLASS zcl_skylint_check_070 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_method_name
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Boolean-returning method should use predicate name (IS_, HAS_, CAN_)'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_is_bool_returning TYPE abap_bool.
    DATA lv_meth_name TYPE string.
    DATA lv_len TYPE i.
    DATA lv_idx TYPE i.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found TYPE abap_bool.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      lv_is_bool_returning = abap_false.
      lv_len = lines( <ls_statement>-tokens ).
      IF lv_len < 2.
        CONTINUE.
      ENDIF.

      get_token_safe( EXPORTING is_statement = <ls_statement>
                                iv_index     = 2
                      IMPORTING es_token     = ls_token
                                ev_found     = lv_found ).
      IF lv_found = abap_false.
        CONTINUE.
      ENDIF.
      lv_meth_name = to_upper( ls_token-lexeme ).

      " Check if method returns boolean
      lv_idx = 1.
      WHILE lv_idx <= lv_len.
        get_token_safe( EXPORTING is_statement = <ls_statement>
                                  iv_index     = lv_idx
                        IMPORTING es_token     = ls_token
                                  ev_found     = lv_found ).
        IF lv_found = abap_false.
          lv_idx += 1.
          CONTINUE.
        ENDIF.
        lv_lexeme = to_upper( ls_token-lexeme ).
        IF lv_lexeme = 'RETURNING'.
          " Look for boolean type keyword in remaining tokens
          LOOP AT <ls_statement>-tokens ASSIGNING <ls_token> FROM lv_idx.
            IF    to_upper( <ls_token>-lexeme ) = 'ABAP_BOOL'
               OR to_upper( <ls_token>-lexeme ) = 'BOOLE_D'
               OR to_upper( <ls_token>-lexeme ) = 'XSDBOOLEAN'
               OR to_upper( <ls_token>-lexeme ) = 'BOOLEAN'.
              lv_is_bool_returning = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          EXIT.
        ENDIF.
        lv_idx += 1.
      ENDWHILE.

      IF     lv_is_bool_returning  = abap_true
         AND lv_meth_name         NP 'IS_*'     AND lv_meth_name NP 'HAS_*'
         AND lv_meth_name         NP 'CAN_*'    AND lv_meth_name NP 'CHECK_*'
         AND lv_meth_name         NP 'ARE_*'    AND lv_meth_name NP 'WAS_*'
         AND lv_meth_name         NP 'SHOULD_*'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-bool_method_name ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
