"! <p class="shorttext synchronized" lang="en">ATC finding quick fix context</p>
"! The context holds information about the location where an ATC quick fix should be executed.
CLASS cl_ci_atc_quickfix_context DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS
    cl_ci_atc_assistant_factory
    cl_ci_atc_quickfixes.

PUBLIC SECTION.
  TYPES:
    "! Interval of positive integers. Valid intervals have either TO >= FROM > 0 or TO = FROM = 0.
    BEGIN OF ty_interval,
      from TYPE i,
      to TYPE i,
    END OF ty_interval.
  TYPES:
    "! Uniquely describes a code location spanning at most a full procedure.
    BEGIN OF ty_context_descriptor,
      procedure_id TYPE if_ci_atc_source_code_provider=>ty_procedure_id,
      statements TYPE ty_interval,
      "! A token interval is only meaningful when the statement interval is a single statement, then specifying a span of tokens within the statement.
      "! Otherwise it should be the initial interval.
      tokens TYPE ty_interval,
    END OF ty_context_descriptor.
PROTECTED SECTION.
PRIVATE SECTION.
  METHODS constructor
    IMPORTING descriptor TYPE ty_context_descriptor ##RELAX.

  DATA descriptor TYPE ty_context_descriptor ##NEEDED.
ENDCLASS.



CLASS CL_CI_ATC_QUICKFIX_CONTEXT IMPLEMENTATION.


  METHOD constructor.
    me->descriptor = descriptor.
  ENDMETHOD.
ENDCLASS.