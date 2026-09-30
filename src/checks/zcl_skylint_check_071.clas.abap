CLASS zcl_skylint_check_071 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        deep_inheritance TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEEP_INHRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEEP_INHERITANCE'.

    DATA mv_max_depth TYPE i VALUE 3.

ENDCLASS.


CLASS zcl_skylint_check_071 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural compiler + rtti ile yeniden yazılsın
    super->constructor(
        VALUE #( description       = 'Avoid deep class inheritance hierarchies (> 3 levels)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-deep_inheritance
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid deep class inheritance; prefer composition over inheritance'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_DEPTH'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_depth ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_super_name TYPE string.
    DATA lv_len TYPE i.
    DATA lv_idx TYPE i.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_super TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found TYPE abap_bool.
    DATA lv_super_found TYPE abap_bool.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CLASS'.
      lv_len = lines( <ls_statement>-tokens ).
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
        IF lv_lexeme <> 'INHERITING'.
          lv_idx += 1.
          CONTINUE.
        ENDIF.
        get_token_safe( EXPORTING is_statement = <ls_statement>
                                  iv_index     = lv_idx + 2
                        IMPORTING es_token     = ls_super
                                  ev_found     = lv_super_found ).
        IF lv_super_found = abap_true.
          lv_super_name = to_upper( ls_super-lexeme ).
          IF    lv_super_name CP '*DEEP*' OR lv_super_name CP '*LEVEL*'
             OR lv_super_name = 'CX_NO_CHECK'.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-deep_inheritance ).
          ENDIF.
        ENDIF.
        EXIT.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
