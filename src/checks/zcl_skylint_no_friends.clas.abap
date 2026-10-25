CLASS zcl_skylint_no_friends DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        friends TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_FRIENDS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_FRIENDS'.

ENDCLASS.


CLASS zcl_skylint_no_friends IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid FRIENDS in class definitions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-friends
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid FRIENDS; expose behavior via public methods'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                   iv_lexeme = 'FRIENDS' ) = abap_true.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-friends ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
