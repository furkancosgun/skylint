CLASS zcl_skylint_check_027 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        public_attribute TYPE zif_skylint_types=>ty_finding_code VALUE 'NOPUBATTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NUM_PUBLIC_ATTR'.
ENDCLASS.


CLASS zcl_skylint_check_027 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable public attributes in classes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-public_attribute
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid public attributes; use private/protected with getters or READ-ONLY'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lo_class    TYPE REF TO cl_abap_classdescr.
    DATA ls_statement TYPE zif_skylint_types=>ty_statement.

    IF is_procedure-id-kind <> zif_skylint_types=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_procedure-id-main_unit-name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                        iv_index      = 1 ).
    IF ls_statement-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lo_class->attributes TRANSPORTING NO FIELDS
         WHERE     visibility   = cl_abap_classdescr=>public
               AND is_read_only = abap_false
               AND is_constant  = abap_false.
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-public_attribute ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
