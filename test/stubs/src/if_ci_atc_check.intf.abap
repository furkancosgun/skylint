"! <p class="shorttext synchronized" lang="en">ATC check</p>
"! <p>Global classes implementing this interface are recognized by the ATC as potential check classes. For an example of how to use
"! this interface, see {@link CL_CI_ATC_CHECK_EXAMPLE}.</p>
INTERFACE if_ci_atc_check
  PUBLIC.
TYPES:
  "! An object's unique identifier
  BEGIN OF ty_object,
    "! The object's type, e.g. CLAS (for an ABAP Objects class), see also the documentation of the {@link TROBJTYPE} domain.
    type TYPE c LENGTH 4,
    "! The object's name
    name TYPE c LENGTH 40,
  END OF ty_object.
TYPES:
  "! A position within an ABAP include
  BEGIN OF ty_position,
    "! Line within the include
    line TYPE i,
    "! Column within the include
    column TYPE int1,
  END OF ty_position.
TYPES:
  "! A location within an ABAP program
  BEGIN OF ty_location,
    "! The program or include
    object TYPE ty_object,
    "! The position within the program or include
    position TYPE ty_position,
  END OF ty_location.
TYPES ty_finding_code TYPE c LENGTH 10.
TYPES:
  "! Parameters in the style of T100 messages
  BEGIN OF ty_message_parameters,
    param_1 TYPE string,
    param_2 TYPE string,
    param_3 TYPE string,
    param_4 TYPE string,
  END OF ty_message_parameters.
TYPES:
  "! Severity of an ATC finding,  i.e. how urgent it is to fix, how bad the effects are when it is not, or how certain it is that any given finding
  "! of this type presents an actual problem in an application. <p>
  "! Note that the ATC (and other tools that execute ATC checks) often allow additional customization for the interpretation
  "! of these severities. In a three-priority system, errors are usually mapped to the highest priority (priority 1), warnings to
  "! the second highest (priority 2) and notes to the lowest priority (priority 3). In any given system, there might exist customization for
  "! an ATC check that reclassifies certain finding codes to a different priority than what is defined in the check metadata.
  BEGIN OF ENUM ty_finding_severity STRUCTURE finding_severities,
    error,
    warning,
    note,
  END OF ENUM ty_finding_severity STRUCTURE finding_severities.
"! Checksum used to identify a finding even when its location has changed
TYPES ty_checksum TYPE int4.
"! Container for various additional information of an ATC finding
TYPES ty_details TYPE REF TO cl_ci_atc_finding_details.
TYPES:
  "! An ATC finding
  BEGIN OF ty_finding,
    "! Identifier that, together with the check that emitted it, uniquely specifies the "kind" of finding this is.
    "! Findings with the same code should refer to similar or identical situations.
    code TYPE ty_finding_code,
    "! Location of the finding
    location TYPE ty_location,
    "! Parameters that will be used to construct the text displayed for this finding, together with the generic text
    "! returned by the {@link IF_CI_ATC_CHECK_META_DATA} instance for the check that emitted this finding
    parameters TYPE ty_message_parameters,
    "! Checksum used to identify a finding even when its location has changed
    checksum TYPE ty_checksum,
    "! <p>This finding has been disabled by a pseudo comment or pragma.<p>
    "!
    "! <p>This flag has to be set by the check when reporting its findings. The {@link IF_CI_ATC_SOURCE_CODE_PROVIDER.TY_STATEMENT}
    "! type contains the pseudo comments that refer to a given statement. When checks determine
    "! that a finding should be suppressed by such a pseudo comment, they set this flag to ABAP_TRUE.<p>
    has_pseudo_comment TYPE abap_bool,
    "! Various additional information for this finding.
    details TYPE ty_details,
  END OF ty_finding.
TYPES ty_findings TYPE SORTED TABLE OF ty_finding WITH NON-UNIQUE KEY code location.
TYPES ty_data_provider TYPE REF TO cl_ci_atc_data_provider.

"! <p>Main method of an ATC check. Called once per object during a check run.</p>
"! @parameter object | <p>TADIR key of the main object to be checked. PGMID = 'R3TR' is implied.</p>
"! @parameter data_provider | <p>Factory to access the data of the objects to be checked. As long as you only access data returned from the providers obtained from
"! this factory, your check is automatically able to check remote systems.</p>
"! @parameter findings | <p>All findings the check wishes to report after checking the object.
"! <strong>Note:</strong> The finding's referenced object need not necessarily match the OBJECT parameter of this method.</p>
METHODS run
  IMPORTING object TYPE ty_object
            data_provider TYPE ty_data_provider
  RETURNING VALUE(findings) TYPE ty_findings.
"! <p>Returns an object holding meta data for this ATC check, such as its possible finding codes or its settings.</p>
"! @parameter meta_data | <p>The meta data object/p>
METHODS get_meta_data
  RETURNING VALUE(meta_data) TYPE REF TO if_ci_atc_check_meta_data.
"! <p>Configures this check's settings. The type of the data references in the input must match the type of those in the output of {@link IF_CI_ATC_CHECK_META_DATA.meth:GET_ATTRIBUTES} exactly.</p>
"! @parameter attributes | <p>Table of configurable settings</p>
METHODS set_attributes DEFAULT IGNORE
  IMPORTING attributes TYPE if_ci_atc_check_meta_data=>ty_attributes
  RAISING cx_ci_atc_check_invalid_attr.
"! <p>Verifies whether this ATC check is able to run in this system at all. Returns nothing if the check is able to run without any restrictions,
"! otherwise returns findings detailing the restrictions and ways to resolve them.</p>
"! @parameter verification_findings | <p>Restrictions for this check's execution</p>
METHODS verify_prerequisites
  RETURNING VALUE(verification_findings) TYPE ty_findings.
"! <p>Called by the ATC prior to calling {@link IF_CI_ATC_CHECK.METH:RUN}</p>
"!
"! @parameter factory | <p>A factory that produces helper objects for ATC checks.</p>
METHODS set_assistant_factory
  IMPORTING factory TYPE REF TO cl_ci_atc_assistant_factory.
ENDINTERFACE.