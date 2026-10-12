"! <p>An ATC finding quickfix belonging to a set of {@link CL_CI_ATC_QUICKFIXES}</p>
INTERFACE if_ci_atc_quickfix
  PUBLIC.

TYPES ty_code TYPE STANDARD TABLE OF string WITH EMPTY KEY.

"! <p>Inserts the given code in front of the location specified by the given context</p>
"!
"! @parameter context | <p>Context for this action</p>
"! @parameter code | <p>Code to be inserted</p>
"! @parameter self | <p>This object (enables fluent API usage)</p>
METHODS insert_before
  IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
            code TYPE ty_code
  RETURNING VALUE(self) TYPE REF TO if_ci_atc_quickfix.
"! <p>Inserts the given code after the location specified by the given context</p>
"!
"! @parameter context | <p>Context for this action</p>
"! @parameter code | <p>Code to be inserted</p>
"! @parameter self | <p>This object (enables fluent API usage)</p>
METHODS insert_after
  IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
            code TYPE ty_code
  RETURNING VALUE(self) TYPE REF TO if_ci_atc_quickfix.
"! <p>Replaces the code at the location specified by the given context by the given code</p>
"!
"! @parameter context | <p>Context for this action</p>
"! @parameter code | <p>Code to be inserted</p>
"! @parameter self | <p>This object (enables fluent API usage)</p>
METHODS replace
  IMPORTING context TYPE REF TO cl_ci_atc_quickfix_context
            code TYPE ty_code
  RETURNING VALUE(self) TYPE REF TO if_ci_atc_quickfix.

ENDINTERFACE.