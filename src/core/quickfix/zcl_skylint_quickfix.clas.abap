CLASS zcl_skylint_quickfix DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_quickfix.

    METHODS constructor
      IMPORTING io_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory.

  PRIVATE SECTION.
    DATA mo_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory.
ENDCLASS.


CLASS zcl_skylint_quickfix IMPLEMENTATION.
  METHOD constructor.
    mo_assistant_factory = io_assistant_factory.
  ENDMETHOD.

  METHOD zif_skylint_quickfix~replace.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lv_st_to) = COND i( WHEN iv_statement_to IS NOT INITIAL THEN iv_statement_to ELSE iv_statement_from ).

    DATA(ls_context_params) = VALUE cl_ci_atc_quickfix_context=>ty_context_descriptor(
                                        procedure_id = is_procedure_id
                                        statements   = VALUE #( from = iv_statement_from
                                                                to   = lv_st_to ) ).

    IF iv_token_from IS NOT INITIAL.
      DATA(lv_tk_to) = COND i( WHEN iv_token_to IS NOT INITIAL THEN iv_token_to ELSE iv_token_from ).
      ls_context_params-tokens = VALUE #( from = iv_token_from
                                          to   = lv_tk_to ).
    ENDIF.

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context( ls_context_params ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->replace( context = lo_context
                                                                 code    = it_new_code ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD zif_skylint_quickfix~insert_before.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context(
                           VALUE #( procedure_id = is_procedure_id
                                    statements   = VALUE #( from = iv_statement_index
                                                            to   = iv_statement_index ) ) ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->insert_before( context = lo_context
                                                                       code    = it_new_code ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD zif_skylint_quickfix~insert_after.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context(
                           VALUE #( procedure_id = is_procedure_id
                                    statements   = VALUE #( from = iv_statement_index
                                                            to   = iv_statement_index ) ) ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->insert_after( context = lo_context
                                                                      code    = it_new_code ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD zif_skylint_quickfix~delete_statement.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context(
                           VALUE #( procedure_id = is_procedure_id
                                    statements   = VALUE #( from = iv_statement_index
                                                            to   = iv_statement_index ) ) ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->replace( context = lo_context
                                                                 code    = VALUE #( ) ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.
ENDCLASS.
