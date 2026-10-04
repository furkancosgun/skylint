CLASS zcl_skylint_check_060 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        catch_root TYPE zif_skylint_types=>ty_finding_code VALUE 'CATCH_ROOT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_060 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid generic CATCH cx_root; catch specific exception classes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-catch_root
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid generic CATCH cx_root; catch specific exception classes instead'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CATCH'.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) = 'CX_ROOT'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-catch_root ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
