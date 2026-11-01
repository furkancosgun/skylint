CLASS zcl_skylint_no_intf_class_ref DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_ref_in_interface TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTF_CLS_R',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INTF_CLASS_REF'.

    METHODS check_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_intf_class_ref IMPLEMENTATION.
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

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>procedure_is_interface( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      check_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD check_statement.
    DATA lt_expected   TYPE zcl_skylint_ast_util=>ty_token_lexemes.
    DATA lv_idx        TYPE i.
    DATA ls_type_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lo_classdescr TYPE REF TO cl_abap_classdescr.

    lt_expected = VALUE #(
        ( `TYPE` )
        ( `REF` )
        ( `TO` ) ).

    lv_idx = zcl_skylint_ast_util=>find_token_sequence(
                 is_statement = is_statement
                 it_expected  = lt_expected ).
    IF lv_idx <= 0.
      RETURN.
    ENDIF.

    ls_type_token = zcl_skylint_ast_util=>get_token(
                        is_statement = is_statement
                        iv_index     = lv_idx + 3 ).
    IF ls_type_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_type_token-lexeme = 'DATA' OR ls_type_token-lexeme = 'OBJECT'.
      RETURN.
    ENDIF.

    lo_classdescr = zcl_skylint_rtti_util=>describe_class( ls_type_token-lexeme ).
    IF lo_classdescr IS BOUND.
      report_statement(
          is_statement    = is_statement
          iv_finding_code = c_finding_codes-class_ref_in_interface ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
