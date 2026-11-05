CLASS /skyl/cl_no_intf_class_ref DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_ref_in_interface TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CLS_REF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INTF_CLASS_REF'.

    METHODS check_statement
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS /skyl/cl_no_intf_class_ref IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Interfaces should not reference concrete classes'
                 remote_enablement = abap_false
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-class_ref_in_interface
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Interface references concrete class; use an interface reference instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    IF /skyl/cl_ast_util=>procedure_is_interface( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      check_statement( is_procedure = is_procedure
                       is_statement = <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD check_statement.
    DATA lt_expected   TYPE /skyl/cl_ast_util=>ty_token_lexemes.
    DATA ls_type_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lo_classdescr TYPE REF TO cl_abap_classdescr.
    DATA ls_reference  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    lt_expected = VALUE #( ( `TYPE` )
                           ( `REF` )
                           ( `TO` ) ).

    ls_type_token = /skyl/cl_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                                 it_expected  = lt_expected ).
    IF    ls_type_token-lexeme IS INITIAL
       OR ls_type_token-lexeme  = is_procedure-id-name
       OR ls_type_token-lexeme  = 'DATA'
       OR ls_type_token-lexeme  = 'OBJECT'.
      RETURN.
    ENDIF.

    ls_reference = /skyl/cl_ast_util=>get_reference(
                       is_token = ls_type_token
                       iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type ).
    IF ls_reference IS INITIAL.
      RETURN.
    ENDIF.

    lo_classdescr = /skyl/cl_rtti_util=>describe_class( ls_reference-full_name ).

    IF lo_classdescr IS BOUND.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-class_ref_in_interface ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
