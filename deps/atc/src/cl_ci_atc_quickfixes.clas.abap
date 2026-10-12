"! <p class="shorttext synchronized" lang="en">ATC finding quick fixes</p>
"! <p> A collection of ATC quick fixes.
"! Instances of this class can be obtained from {@link CL_CI_ATC_ASSISTANT_FACTORY.CREATE_QUICKFIXES}</p>
class CL_CI_ATC_QUICKFIXES definition
  public
  final
  create private

  global friends CL_CI_ATC_ASSISTANT_FACTORY
                 CL_CI_ATC_FINDING_DETAILS
                 cl_ci_quickfix_Testing.

public section.

  types:
    ty_quickfix_code TYPE c LENGTH 10 .

  "! <p>Add a quickfix to this set of quick fixes and returns a reference to it. The fix doesn't do anything unless you add actions to it via that reference!</p>
  "!
  "! @parameter quickfix_code | <p>ID that determines the text shown for this quick fix</p>
  "! @parameter fix | <p>A single quickfix</p>
  methods CREATE_QUICKFIX
    importing
      !QUICKFIX_CODE type TY_QUICKFIX_CODE
    returning
      value(FIX) type ref to IF_CI_ATC_QUICKFIX .
PROTECTED SECTION.
PRIVATE SECTION.
  TYPES ty_quickfix TYPE REF TO atc_quickfix.

  CLASS-METHODS get_descriptor_from_context
    IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
    RETURNING VALUE(descriptor) TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor.

  METHODS serialize ##RELAX
    IMPORTING error_location TYPE if_ci_atc_check=>ty_location OPTIONAL
    RETURNING VALUE(serial_data) TYPE cl_sca_ci_qfix_engine=>t_quickfixes.

  METHODS constructor ##RELAX
    IMPORTING
      source TYPE cl_ci_atc_data_provider=>ty_source_id
      wrapper_callback type ref to if_ci_atc_wrapper_callback
      syntax_check TYPE abap_bool.

  DATA fixes TYPE STANDARD TABLE OF ty_quickfix WITH EMPTY KEY.
  DATA source TYPE scr_source_id.
  DATA syntax_check TYPE abap_bool.
  DATA wrapper_callback type ref to if_ci_atc_wrapper_callback.
ENDCLASS.



CLASS CL_CI_ATC_QUICKFIXES IMPLEMENTATION.


  METHOD constructor.
    me->source = source.
    me->syntax_check = syntax_check.
    me->wrapper_callback = wrapper_callback.
  ENDMETHOD.


  METHOD create_quickfix.
    fix = NEW atc_quickfix( quickfix_code ).
    INSERT CAST atc_quickfix( fix ) INTO TABLE fixes.
  ENDMETHOD.


  METHOD get_descriptor_from_context.
    descriptor = context->descriptor.
  ENDMETHOD.


  METHOD serialize.
    DATA(generated_fixes) = cl_ci_quickfix_creation=>create_quickfix_alternatives( ).
    LOOP AT fixes ASSIGNING FIELD-SYMBOL(<fix>).
      DATA(generated_fix) = generated_fixes->create_quickfix( <fix>->quickfix_code ).
      generated_fix->add_docu_via_code( ). "This prompts the framework to load the text from the result class instead of trying to access the message
      data(affected_programs) = <fix>->generate( abap_fix = generated_fix source = source ).
      generated_fix->enable_automatic_execution( ).
      if syntax_check = abap_true.
        loop at affected_programs assigning field-symbol(<program>).
            generated_fix->abap_syntax_check(
              exporting
                p_program = <program>
                p_srcid = source
              importing
                p_err_msgs = data(error_messages)
              receiving
                p_okay = data(syntax_check_successful) ).
          if syntax_check_successful = abap_false and error_messages is not initial.
            wrapper_callback->report_quickfix_error(
              location = error_location
              message = error_messages[ 1 ]-msg ).
          endif.
        endloop.
      endif.
    ENDLOOP.
    serial_data = generated_fixes->export_to_table( ).
  ENDMETHOD.
ENDCLASS.