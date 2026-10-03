CLASS zcl_skylint_check_005 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_me TYPE zif_skylint_types=>ty_finding_code VALUE 'AVOIDME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_ME'.

    DATA mv_allow_in_constructors TYPE abap_bool VALUE abap_false.

ENDCLASS.


CLASS zcl_skylint_check_005 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid self-reference ME->'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #( ( code           = c_finding_codes-avoid_me
                                                                severity       = zif_skylint_types=>severities-warning
                                                                text           = 'Avoid unnecessary ME-> reference'
                                                                pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( ( name  = 'ALLOW_IN_CONSTRUCTORS'
                                                                kind  = zif_skylint_types=>attribute_kinds-boolean
                                                                value = REF #( mv_allow_in_constructors ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_allow_ctor TYPE abap_bool.
    DATA lv_lexeme     TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.

    get_attribute( EXPORTING iv_name  = 'ALLOW_IN_CONSTRUCTORS'
                   IMPORTING ev_value = lv_allow_ctor ).

    IF is_code_block-block_name = 'CONSTRUCTOR' AND lv_allow_ctor = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_lexeme = to_upper( <ls_token>-lexeme ).
        IF lv_lexeme CP 'ME->*'.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-avoid_me ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
