CLASS /skyl/cl_no_badi_commit DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        badi_commit TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_BADI_CM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_BADI_COMMIT'.

    METHODS is_badi_class
      IMPORTING is_procedure      TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is_badi) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_badi_commit IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Avoid COMMIT or ROLLBACK in BAdI implementations'
            remote_enablement = abap_false
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-badi_commit
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Avoid COMMIT or ROLLBACK WORK inside BAdI implementations (breaks LUW integrity)'
                  pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    IF is_badi_class( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF    /skyl/cl_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `COMMIT` ) ( `WORK` ) ) )   = abap_true
         OR /skyl/cl_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `ROLLBACK` ) ( `WORK` ) ) ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-badi_commit ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_badi_class.
    DATA lo_classdescr TYPE REF TO cl_abap_classdescr.
    DATA lv_cls_name   TYPE string.

    rv_is_badi = abap_false.

    lv_cls_name = /skyl/cl_rtti_util=>resolve_class_rtti_name( is_procedure ).
    IF lv_cls_name IS INITIAL.
      RETURN.
    ENDIF.

    lo_classdescr = /skyl/cl_rtti_util=>describe_class( lv_cls_name ).
    IF lo_classdescr IS NOT BOUND.
      RETURN.
    ENDIF.

    rv_is_badi = xsdbool( line_exists( lo_classdescr->interfaces[ name = 'IF_BADI_INTERFACE' ] ) ).
  ENDMETHOD.
ENDCLASS.
