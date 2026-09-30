CLASS zcl_skylint_check_027 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        public_attribute TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOPUBATTR',
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
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid public attributes; use private/protected with getters or READ-ONLY'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA lo_class TYPE REF TO cl_abap_classdescr.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_attr  TYPE abap_attrdescr.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = is_procedure-id-main_unit-name
                                         RECEIVING  p_descr_ref    = lo_descr
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF sy-subrc <> 0 OR lo_descr IS NOT BOUND OR lo_descr->kind <> cl_abap_typedescr=>kind_class.
      RETURN.
    ENDIF.

    lo_class ?= lo_descr.

    ASSIGN is_procedure-statements[ 1 ] TO <ls_statement>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lo_class->attributes INTO ls_attr
         WHERE     visibility   = cl_abap_classdescr=>public
               AND is_read_only = abap_false
               AND is_constant  = abap_false.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-public_attribute ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
