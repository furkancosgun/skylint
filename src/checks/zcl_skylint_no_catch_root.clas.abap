CLASS zcl_skylint_no_catch_root DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        catch_root TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CAT_ROT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CATCH_ROOT'.
ENDCLASS.


CLASS zcl_skylint_no_catch_root IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Catch specific exceptions instead of generic cx_root'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-catch_root
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid generic CATCH cx_root; catch specific exception classes instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_refs TYPE if_ci_atc_source_code_provider=>ty_compiler_references.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CATCH'.
        CONTINUE.
      ENDIF.
      lt_refs = zcl_skylint_ast_util=>statement_get_references(
                    is_statement = <ls_statement>
                    iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-type ).
      LOOP AT lt_refs ASSIGNING <ls_ref>.
        IF <ls_ref>-full_name = '\TY:CX_ROOT'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-catch_root ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
