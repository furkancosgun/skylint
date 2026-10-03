CLASS zcl_skylint_check_071 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_final TYPE zif_skylint_types=>ty_finding_code VALUE 'PREF_FINAL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_FINAL_METHOD'.
ENDCLASS.


CLASS zcl_skylint_check_071 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer marking non-overridden methods as FINAL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_final
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Declare method as FINAL if it is not intended to be redefined'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_statement TYPE zif_skylint_types=>ty_statement.
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    DATA ls_meth      TYPE abap_methdescr.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_code_block-object_name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                        iv_index      = 1 ).
    IF ls_statement-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lo_class->methods INTO ls_meth
         WHERE     is_final     = abap_false
               AND is_abstract  = abap_false
               AND is_redefined = abap_false.
      IF ls_meth-name <> 'CONSTRUCTOR' AND ls_meth-name <> 'CLASS_CONSTRUCTOR'.
        report_statement( is_statement    = ls_statement
                          iv_finding_code = c_finding_codes-prefer_final ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
