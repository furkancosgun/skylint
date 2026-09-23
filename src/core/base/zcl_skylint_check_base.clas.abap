CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

  PROTECTED SECTION.
    METHODS describe ABSTRACT
      RETURNING VALUE(rs_result) TYPE zcl_skylint_check_meta_data=>ty_config.

    METHODS check ABSTRACT
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS get_reporter
      RETURNING VALUE(ro_reporter) TYPE REF TO zif_skylint_reporter.

    METHODS get_quickfix
      RETURNING VALUE(ro_quickfix) TYPE REF TO zif_skylint_quickfix.

    METHODS get_token_navigator
      RETURNING VALUE(ro_navigator) TYPE REF TO zif_skylint_token_navigator.

    METHODS get_operator_util
      RETURNING VALUE(ro_operator) TYPE REF TO zif_skylint_operator_util.

    METHODS get_code_formatter
      RETURNING VALUE(ro_formatter) TYPE REF TO zif_skylint_code_formatter.

    METHODS get_token_stream
      IMPORTING is_procedure     TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(ro_stream) TYPE REF TO zcl_skylint_token_stream.

    METHODS get_attribute
      IMPORTING iv_name        TYPE string
      RETURNING VALUE(ro_data) TYPE REF TO data.

  PRIVATE SECTION.
    DATA mo_code_provider     TYPE REF TO if_ci_atc_source_code_provider.
    DATA mo_meta_data_handler TYPE REF TO zcl_skylint_check_meta_data.
    DATA mo_reporter          TYPE REF TO zif_skylint_reporter.
    DATA mo_quickfix          TYPE REF TO zif_skylint_quickfix.
    DATA mo_token_navigator   TYPE REF TO zif_skylint_token_navigator.
    DATA mo_operator_util     TYPE REF TO zif_skylint_operator_util.
    DATA mo_code_formatter    TYPE REF TO zif_skylint_code_formatter.
    DATA mt_attributes        TYPE if_ci_atc_check_meta_data=>ty_attributes.

ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.
  METHOD if_ci_atc_check~get_meta_data.
    mo_meta_data_handler = NEW zcl_skylint_check_meta_data( describe( ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check~set_assistant_factory.
    DATA(lo_factory) = zcl_skylint_factory=>get_instance( ).
    mo_quickfix = lo_factory->create_quickfix( factory ).
  ENDMETHOD.

  METHOD if_ci_atc_check~set_attributes.
    mt_attributes = attributes.
  ENDMETHOD.

  METHOD get_attribute.
    ASSIGN mt_attributes[ name = iv_name ] TO FIELD-SYMBOL(<ls_attr>).
    IF sy-subrc = 0.
      ro_data = <ls_attr>-value.
    ENDIF.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    mo_code_provider = data_provider->get_code_provider( ).

    DATA(lo_factory) = zcl_skylint_factory=>get_instance( ).
    mo_token_navigator = lo_factory->create_token_navigator( ).
    mo_operator_util   = lo_factory->create_operator_util( ).
    mo_code_formatter  = lo_factory->create_code_formatter( ).
    mo_reporter        = lo_factory->create_reporter( io_code_provider = mo_code_provider
                                                      io_meta_data     = mo_meta_data_handler ).

    TRY.
        DATA(lv_unit) = mo_code_provider->object_to_comp_unit( object ).
        DATA(lr_procedures) = mo_code_provider->get_procedures( lv_unit ).
        LOOP AT lr_procedures->* ASSIGNING FIELD-SYMBOL(<ls_procedure>).
          check( <ls_procedure> ).
        ENDLOOP.
      CATCH cx_root.
        RETURN.
    ENDTRY.

    findings = mo_reporter->get_findings( ).
  ENDMETHOD.

  METHOD get_reporter.
    ro_reporter = mo_reporter.
  ENDMETHOD.

  METHOD get_quickfix.
    ro_quickfix = mo_quickfix.
  ENDMETHOD.

  METHOD get_token_navigator.
    ro_navigator = mo_token_navigator.
  ENDMETHOD.

  METHOD get_operator_util.
    ro_operator = mo_operator_util.
  ENDMETHOD.

  METHOD get_code_formatter.
    ro_formatter = mo_code_formatter.
  ENDMETHOD.

  METHOD get_token_stream.
    ro_stream = zcl_skylint_factory=>get_instance( )->create_token_stream( is_procedure ).
  ENDMETHOD.
ENDCLASS.
