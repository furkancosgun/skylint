"! <p class="shorttext synchronized" lang="en">ATC finding details</p>
"! A set of details for an ATC finding, to be passed by checks in the DETAILS component of the {@link IF_CI_ATC_CHECK.TY_FINDINGS} they emit.
"!
"! Instances of this class can be obtained from {@link CL_CI_ATC_ASSISTANT_FACTORY.METH:CREATE_FINDING_DETAILS}.
CLASS cl_ci_atc_finding_details DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS
    cl_ci_atc_assistant_factory
    cl_ci_test_atc_check_wrapper
    cl_ci_atc_unit_driver.

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Attaches a stack to this set of details</p>
    "!
    "! @parameter name | <p class="shorttext synchronized" lang="en">A name or title for the stack</p>
    "! @parameter stack | <p class="shorttext synchronized" lang="en">The stack</p>
    "! @parameter self | <p class="shorttext synchronized" lang="en">This object</p>
    METHODS attach_stack
      IMPORTING name        TYPE string
                stack       TYPE REF TO if_ci_atc_finding_stack
      RETURNING VALUE(self) TYPE REF TO cl_ci_atc_finding_details.
    "! <p class="shorttext synchronized" lang="en">Attaches a set of quick fixes to this set of details</p>
    "!
    "! @parameter fixes | <p class="shorttext synchronized" lang="en">The set of quick fixes</p>
    "! @parameter self | <p class="shorttext synchronized" lang="en">This object</p>
    METHODS attach_quickfixes
      IMPORTING fixes       TYPE REF TO cl_ci_atc_quickfixes
      RETURNING VALUE(self) TYPE REF TO cl_ci_atc_finding_details.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_stack,
        name  TYPE string,
        stack TYPE if_ci_atc_finding_stack=>ty_stack_statements,
      END OF ty_stack.
    TYPES ty_stacks TYPE STANDARD TABLE OF ty_stack WITH EMPTY KEY.

    DATA stacks TYPE ty_stacks.
    DATA quickfixes TYPE REF TO cl_ci_atc_quickfixes.

    METHODS serialize ##RELAX
      IMPORTING
                error_location     TYPE if_ci_atc_check=>ty_location
                with_quickfixes    TYPE abap_bool
      RETURNING VALUE(serial_data) TYPE xstring.
    METHODS stacks_to_wb_navigation
      IMPORTING stacks               TYPE ty_stacks
      RETURNING VALUE(wb_navigation) TYPE scit_wb_navigation.
ENDCLASS.



CLASS CL_CI_ATC_FINDING_DETAILS IMPLEMENTATION.


  METHOD attach_quickfixes.
    me->quickfixes = fixes.
    self = me.
  ENDMETHOD.


  METHOD attach_stack.
    INSERT VALUE #( name = name stack = stack->peek_full_stack(  ) ) INTO TABLE stacks.
    self = me.
  ENDMETHOD.


  METHOD serialize.
    DATA(wb_navigation) = stacks_to_wb_navigation( me->stacks ).
    IF with_quickfixes = abap_true AND me->quickfixes IS BOUND.
      DATA(quickfixes) = me->quickfixes->serialize( error_location ).
      EXPORT wb_navigation = wb_navigation quickfixes = quickfixes TO DATA BUFFER serial_data.
    ELSE.
      EXPORT wb_navigation = wb_navigation TO DATA BUFFER serial_data.
    ENDIF.
  ENDMETHOD.


  METHOD stacks_to_wb_navigation.
    LOOP AT stacks ASSIGNING FIELD-SYMBOL(<stack>).
      INSERT VALUE #( description = <stack>-name ) INTO TABLE wb_navigation.
      LOOP AT <stack>-stack ASSIGNING FIELD-SYMBOL(<statement>).
        INSERT VALUE #(
          description = <statement>-text
          object_name = <statement>-statement-include
          object_type = cond #(
            when <statement>-statement-include is not initial
              then 'PROG' )
          position    = <statement>-statement-position-line
        ) INTO TABLE wb_navigation.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.