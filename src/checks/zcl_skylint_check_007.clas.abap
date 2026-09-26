CLASS zcl_skylint_check_007 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_exporting TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITEXPORT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OMIT_EXPORTING'.

    METHODS is_exempt_statement
      IMPORTING iv_keyword       TYPE string
      RETURNING VALUE(rv_exempt) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_007 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit explicit EXPORTING in method calls'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_exporting
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Omit explicit EXPORTING keyword in method invocation'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_exempt_statement( <ls_statement>-keyword ) = abap_true.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) = 'EXPORTING'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-omit_exporting ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exempt_statement.
    CASE iv_keyword.
      WHEN 'CALL' OR 'EXPORT' OR 'METHODS' OR 'CLASS-METHODS'
        OR 'EVENTS' OR 'CLASS-EVENTS' OR 'INTERFACES' OR 'SUBMIT'
        OR 'FORM' OR 'FUNCTION' OR 'MODULE'.
        rv_exempt = abap_true.
      WHEN OTHERS.
        rv_exempt = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
