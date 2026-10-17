CLASS zcl_skylint_no_catch_root DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        catch_root TYPE if_ci_atc_check=>ty_finding_code VALUE 'CATCH_ROOT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CATCH_ROOT'.
ENDCLASS.


CLASS zcl_skylint_no_catch_root IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid generic CATCH cx_root; catch specific exception classes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-catch_root
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid generic CATCH cx_root; catch specific exception classes instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CATCH'.
        CONTINUE.
      ENDIF.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references ASSIGNING <ls_ref>
             WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
          IF <ls_ref>-full_name = '\TY:CX_ROOT'.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-catch_root ).
            EXIT.
          ENDIF.
        ENDLOOP.
        IF sy-subrc = 0.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
