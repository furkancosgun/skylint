CLASS zcl_skylint_pref_pub_ctor DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        constructor_not_public TYPE if_ci_atc_check=>ty_finding_code VALUE 'CTOR_PUB',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PUB_CTOR'.
ENDCLASS.


CLASS zcl_skylint_pref_pub_ctor IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Declare Constructor in PUBLIC SECTION'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-constructor_not_public
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Declare constructor in PUBLIC SECTION, even if class is CREATE PRIVATE'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_section TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PUBLIC'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'SECTION' ) = abap_true.
            lv_section = 'PUBLIC'.
          ENDIF.

        WHEN 'PROTECTED'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'SECTION' ) = abap_true.
            lv_section = 'PROTECTED'.
          ENDIF.

        WHEN 'PRIVATE'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'SECTION' ) = abap_true.
            lv_section = 'PRIVATE'.
          ENDIF.

        WHEN 'METHODS'.
          IF     zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `CONSTRUCTOR` ) = abap_true
             AND ( lv_section = 'PROTECTED' OR lv_section = 'PRIVATE' ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-constructor_not_public ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
