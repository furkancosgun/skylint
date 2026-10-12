CLASS cl_ci_atc_assistant_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS
    cl_ci_tests
    cl_ci_atc_unit_driver
    cl_ci_test_atc_check_wrapper.

PUBLIC SECTION.

"! <p>Produces a {@link CL_CI_ATC_FINDING_DETAILS} object that can be attached to a finding of an ATC check</p>
"!
"! @parameter details | <p>Details</p>
METHODS create_finding_details
  RETURNING VALUE(details) TYPE REF TO cl_ci_atc_finding_details.
"! <p>Creates a call stack that can be attached to finding details produced via {@link CL_CI_ATC_ASSISTANT_FACTORY.METH:CREATE_FINDING_DETAILS}</p>
"!
"! @parameter stack | <p>Call stack</p>
METHODS create_call_stack
  RETURNING VALUE(stack) TYPE REF TO if_ci_atc_finding_stack.
"! <p>Creates an initially empty set of quickfixes that can be attached to finding details produced via {@link CL_CI_ATC_ASSISTANT_FACTORY.METH:CREATE_FINDING_DETAILS}</p>
"!
"! @parameter fixes | <p>Set of quickfixes</p>
METHODS create_quickfixes
  RETURNING VALUE(fixes) TYPE REF TO cl_ci_atc_quickfixes.
"! <p>Creates a quickfix context from a description that can be used to determine the place where the quickfixes of {@link CL_CI_ATC_QUICKFIXES} act</p>
"!
"! @parameter descriptor | <p>Uniquely describes a span of code</p>
"! @parameter context | <p>Quickfix context</p>
METHODS create_quickfix_context
  IMPORTING descriptor TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor
  RETURNING VALUE(context) TYPE REF TO cl_ci_atc_quickfix_context.
PROTECTED SECTION.
PRIVATE SECTION.
  CLASS-METHODS create ##RELAX "Is called by FRIENDs
    IMPORTING
      source TYPE cl_ci_atc_data_provider=>ty_source_id
      wrapper_callback TYPE REF TO if_ci_atc_wrapper_callback
      quickfix_syntax_check TYPE abap_bool
    RETURNING VALUE(self) TYPE REF TO cl_ci_atc_assistant_factory.
  METHODS constructor
    IMPORTING
      source TYPE cl_ci_atc_data_provider=>ty_source_id
      wrapper_callback TYPE REF TO if_ci_atc_wrapper_callback
      quickfix_syntax_check TYPE abap_bool.

  DATA source TYPE cl_ci_atc_data_provider=>ty_source_id.
  DATA quickfix_syntax_check TYPE abap_bool.
  DATA wrapper_callback TYPE REF TO if_ci_atc_wrapper_callback.
ENDCLASS.



CLASS CL_CI_ATC_ASSISTANT_FACTORY IMPLEMENTATION.


  METHOD constructor.
    me->source = source.
    me->quickfix_syntax_check = quickfix_syntax_check.
    me->wrapper_callback = wrapper_callback.
  ENDMETHOD.


  METHOD create.
    self = NEW #(
      quickfix_syntax_check = quickfix_syntax_check
      wrapper_callback = wrapper_callback
      source = source ).
  ENDMETHOD.


  METHOD create_call_stack.
    stack = NEW atc_finding_stack( ).
  ENDMETHOD.


  METHOD create_finding_details.
    details = NEW cl_ci_atc_finding_details( ).
  ENDMETHOD.


  METHOD create_quickfixes.
    fixes = NEW cl_ci_atc_quickfixes(
      syntax_check = quickfix_syntax_check
      wrapper_callback = wrapper_callback
      source = source ).
  ENDMETHOD.


  METHOD create_quickfix_context.
    context = NEW cl_ci_atc_quickfix_context( descriptor ).
  ENDMETHOD.
ENDCLASS.