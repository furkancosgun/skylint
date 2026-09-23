CLASS zcl_skylint_factory DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_skylint_factory.

    CLASS-METHODS inject
      IMPORTING io_factory TYPE REF TO zcl_skylint_factory.

    CLASS-METHODS reset.

    METHODS create_reporter
      IMPORTING io_code_provider   TYPE REF TO if_ci_atc_source_code_provider
                io_meta_data       TYPE REF TO zcl_skylint_check_meta_data
      RETURNING VALUE(ro_reporter) TYPE REF TO zif_skylint_reporter.

    METHODS create_quickfix
      IMPORTING io_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory
      RETURNING VALUE(ro_quickfix)   TYPE REF TO zif_skylint_quickfix.

    METHODS create_token_navigator
      RETURNING VALUE(ro_navigator) TYPE REF TO zif_skylint_token_navigator.

    METHODS create_operator_util
      RETURNING VALUE(ro_operator) TYPE REF TO zif_skylint_operator_util.

    METHODS create_code_formatter
      RETURNING VALUE(ro_formatter) TYPE REF TO zif_skylint_code_formatter.

    METHODS create_token_stream
      IMPORTING is_procedure     TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(ro_stream) TYPE REF TO zcl_skylint_token_stream.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_skylint_factory.

ENDCLASS.


CLASS zcl_skylint_factory IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS INITIAL.
      go_instance = NEW zcl_skylint_factory( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD inject.
    go_instance = io_factory.
  ENDMETHOD.

  METHOD reset.
    CLEAR go_instance.
  ENDMETHOD.

  METHOD create_reporter.
    ro_reporter = NEW zcl_skylint_reporter( io_code_provider = io_code_provider
                                            io_meta_data     = io_meta_data ).
  ENDMETHOD.

  METHOD create_quickfix.
    ro_quickfix = NEW zcl_skylint_quickfix( io_assistant_factory ).
  ENDMETHOD.

  METHOD create_token_navigator.
    ro_navigator = NEW zcl_skylint_token_navigator( ).
  ENDMETHOD.

  METHOD create_operator_util.
    ro_operator = NEW zcl_skylint_operator_util( ).
  ENDMETHOD.

  METHOD create_code_formatter.
    ro_formatter = NEW zcl_skylint_code_formatter( ).
  ENDMETHOD.

  METHOD create_token_stream.
    ro_stream = NEW zcl_skylint_token_stream( is_procedure ).
  ENDMETHOD.
ENDCLASS.
