CLASS zcl_skylint_no_instance_of DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        instance_of TYPE if_ci_atc_check=>ty_finding_code VALUE 'INSTANCEOF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INSTANCE_OF'.

    DATA mv_check_case_type_of TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_instance_of IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid IS INSTANCE OF / CASE TYPE OF checks'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-instance_of
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid runtime type checks via IS INSTANCE OF; use polymorphism'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                     ( name  = 'CHECK_CASE_TYPE'
                       value = REF #( mv_check_case_type_of ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF zcl_skylint_ast_util=>match_token_sequence(
             is_statement = <ls_stmt>
             it_expected  = VALUE #( ( `IS` ) ( `INSTANCE` ) ( `OF` ) ) ) = abap_true.
        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-instance_of ).
        CONTINUE.
      ENDIF.

      IF     mv_check_case_type_of = abap_true
         AND zcl_skylint_ast_util=>match_token_sequence(
                 is_statement = <ls_stmt>
                 it_expected  = VALUE #( ( `CASE` ) ( `TYPE` ) ( `OF` ) ) ) = abap_true.
        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-instance_of ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
