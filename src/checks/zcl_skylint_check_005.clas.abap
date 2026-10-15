CLASS zcl_skylint_check_005 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_me TYPE if_ci_atc_check=>ty_finding_code VALUE 'AVOIDME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_allow_in_constructors TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_check_005 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid self-reference ME->'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code     = c_finding_codes-avoid_me
                                                severity = if_ci_atc_check=>finding_severities-warning
                                                text     = 'Avoid unnecessary ME-> reference' ) )
                 attributes        = VALUE #( ( name  = 'ALLOW_IN_CONSTRUCTORS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_allow_in_constructors ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-name CP '*=>CONSTRUCTOR' AND mv_allow_in_constructors = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_lexeme = <ls_token>-lexeme.
        IF lv_lexeme CP 'ME->*'.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-avoid_me ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
