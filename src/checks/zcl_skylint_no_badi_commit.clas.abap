CLASS zcl_skylint_no_badi_commit DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        badi_commit TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_BADI_CM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_BADI_COMMIT'.

    METHODS is_badi_class
      IMPORTING is_procedure     TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is_badi) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_badi_commit IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid COMMIT or ROLLBACK in BAdI implementations'
                 remote_enablement = abap_false
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-badi_commit
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid COMMIT or ROLLBACK WORK inside BAdI implementations (breaks LUW integrity)'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    IF is_badi_class( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF    (     <ls_statement>-keyword = 'COMMIT'
              AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                          iv_index     = 2
                                                          iv_expected  = `WORK` ) = abap_true )
         OR (     <ls_statement>-keyword = 'ROLLBACK'
              AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                          iv_index     = 2
                                                          iv_expected  = `WORK` ) = abap_true ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-badi_commit ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_badi_class.
    DATA lo_classdescr TYPE REF TO cl_abap_classdescr.
    DATA lv_cls_name   TYPE string.
    FIELD-SYMBOLS <ls_intf> TYPE abap_intfdescr.

    rv_is_badi = abap_false.

    lv_cls_name = zcl_skylint_rtti_util=>resolve_class_rtti_name( is_procedure ).
    IF lv_cls_name IS INITIAL.
      RETURN.
    ENDIF.

    lo_classdescr = zcl_skylint_rtti_util=>describe_class( lv_cls_name ).
    IF lo_classdescr IS NOT BOUND.
      RETURN.
    ENDIF.

    LOOP AT lo_classdescr->interfaces ASSIGNING <ls_intf>.
      IF <ls_intf>-name = 'IF_BADI_INTERFACE'.
        rv_is_badi = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
