"! <p class="shorttext synchronized" lang="en">ATC check meta data</p>
"! Objects implementing this interface are be returned by {@link IF_CI_ATC_CHECK.METH:GET_META_DATA}
"! and describe information about their ATC check.
INTERFACE if_ci_atc_check_meta_data
  PUBLIC.
TYPES:
  "! The attribute kind
  BEGIN OF ENUM ty_attribute_kind STRUCTURE attribute_kinds,
    "! Should be used for character fields of length 1 that are semantically booleans,
    "! where 'X' corresponds to true and '' to false, as in the case of the predefined type ABAP_BOOL
    boolean,
    "! Elementary type corresponding to the generic type SIMPLE, e.g. string, integer
    elementary,
    "! A table type with elementary line type
    table,
    "! A range type corresponding to a table declared via "TYPE RANGE OF line_type",
    "! where line_type is an elementary type
    range,
  END OF ENUM ty_attribute_kind STRUCTURE attribute_kinds.
TYPES:
  "! A configurable attribute of a check
  BEGIN OF ty_attribute,
    "! The attribute name
    name TYPE string,
    "! The attribute kind
    kind TYPE ty_attribute_kind,
    "! A reference to a data object holding the current value for this attribute
    value TYPE REF TO data,
  END OF ty_attribute.
"! Configurable attributes of a check
TYPES ty_attributes TYPE HASHED TABLE OF ty_attribute WITH UNIQUE KEY name.
TYPES:
  "! Finding category
  BEGIN OF ENUM ty_finding_category STRUCTURE finding_categories,
    "! A normal finding
    standard,
    "! Failure during check of a specific object
    failure_for_object,
    "! Partial failure during execution due to missing prerequisites in the system
    partial_failure_for_system,
    "! Complete failure during execution due to missing prerequisites in the system
    complete_failure_for_system,
  END OF ENUM ty_finding_category STRUCTURE finding_categories.
TYPES:
  "! Information for a finding code
  BEGIN OF ty_finding_code_info,
    "! A technical identifier uniquely identifying this kind of finding together with the check that emitted it
    code TYPE if_ci_atc_check=>ty_finding_code,
    "! The severity of the finding
    severity TYPE if_ci_atc_check=>ty_finding_severity,
    "! The category of the finding
    category TYPE ty_finding_category,
    "! The short text of the finding
    text TYPE string,
    "! A pseudo comment that may be used to suppress the finding
    pseudo_comment TYPE string,
  END OF ty_finding_code_info.
"! Information on finding codes
TYPES ty_finding_code_infos TYPE HASHED TABLE OF ty_finding_code_info WITH UNIQUE KEY code.
TYPES:
  BEGIN OF ty_quickfix_code_info,
    "! A technical identifier uniquely identifying this kind of quick fix together with the check that emitted it
    code TYPE cl_ci_atc_quickfixes=>ty_quickfix_code,
    "! A short summary of what this quick fix does, should fit into a single short line
    short_text TYPE string,
    "! A longer explanation of what this quick fix does
    long_text TYPE string,
  END OF ty_quickfix_code_info.
"! Information on quick fix codes
TYPES ty_quickfix_code_infos TYPE HASHED TABLE OF ty_quickfix_code_info WITH UNIQUE KEY code.
"! TADIR object types
TYPES ty_object_types TYPE HASHED TABLE OF if_ci_atc_check=>ty_object-type WITH UNIQUE KEY table_line.
"! An arbitrary-length description
TYPES ty_description TYPE string.
types:
  begin of enum ty_pseudo_remote structure pseudo_remote,
    not_pseudo_remote,
    is_pseudo_remote,
  end of enum ty_pseudo_remote structure pseudo_remote.

types ty_pseudo_remote_version type i.

types:
  "! Pseudo-remote checks are checks that achieve remote-enabledness by executing the version of themselves that exists
  "! in the checked system, if any.
  begin of ty_pseudo_remote_info,
    "! Whether the check is pseudo-remote or not. If set to NOT_PSEUDO_REMOTE, which is the default value, the rest of
    "! of the fields in this structure is ignored (and can thus be left initial).
    pseudo_remote type ty_pseudo_remote,
    "! Version of the check that indicates how the compatibility handler should process the findings. Checks that
    "! increase their version should implement handling of findings from the old version in their compatibility
    "! handler. Conversely, if the check is not changed in ways that require such handling, the version should
    "! not be increased.
    version type ty_pseudo_remote_version,
    "! Compability handler to deal with findings from older versions of the check. This instance must be supplied if the
    "! version of the check has been increased at least once, otherwise it can be left initial.
    version_compatibility_handler type ref to if_ci_atc_check_vers_compat,
    "! Since the check class needs to exist in the checked system for pseudo-remote execution to work, there is a lowest
    "! release of the software component of the check in which the check is available (typically the release in which
    "! the check was first developed). This field also defines how attempts to execute the check against lower releases
    "! are handled by the ATC framework. This instance <strong>must</strong> be provided if the check is pseudo-remote.
    availability_checker type ref to if_ci_atc_psrem_avail_checker,
  end of ty_pseudo_remote_info.

"! <p>Returns a table of name and value pairs that defines configurable settings for an ATC check.
"! It is important that the type of the data references in this table matches the type the check itself expects
"! when {@link IF_CI_ATC_CHECK.meth:SET_ATTRIBUTES} is called.</p>
"! <p>An empty return value is allowed and signals that the check has no settings at all.</p>
"! <p>When creating the data references, it is important that they live long enough to be consumed by callers of this
"! method. In particular, this means that references to any local variables declared inside the method are unsuitable,
"! as callers will always received invalid references that lead to uncatchable SYSTEM_DATA_ALREADY_FREE short dumps when
"! the caller attempts to access their value or type.</p>
"! @parameter attributes | <p>Table of configurable settings</p>
METHODS get_attributes DEFAULT IGNORE
  RETURNING VALUE(attributes) TYPE ty_attributes.
"! <p>Returns information about the possible finding codes for an ATC check, such as their default severity,
"! their descriptive texts and whether or not they can be suppressed via pseudo comments.</p>
"! @parameter finding_code_infos | <p>Information about finding codes not specific to any particular finding</p>
METHODS get_finding_code_infos
  RETURNING VALUE(finding_code_infos) TYPE ty_finding_code_infos.
"! <p>Returns information about the possible quickfix codes for an ATC check, in particular their explanatory
"! short and long texts.</p>
"!
"! @parameter quickfix_code_infos | <p class="shorttext synchronized" lang="en">Information about quickfix codes</p>
METHODS get_quickfix_code_infos
  RETURNING VALUE(quickfix_code_infos) TYPE ty_quickfix_code_infos.
"! <p>Returns a table of all object types that are checked by an ATC check.</p>
"! @parameter types | <p>Table of object types</p>
METHODS get_checked_object_types
  RETURNING VALUE(types) TYPE ty_object_types.
"! <p>Returns a short description of an ATC check</p>
"! @parameter description | <p>Short description</p>
METHODS get_description
  RETURNING VALUE(description) TYPE ty_description.
"! <p>Indicates whether this check emits findings with checksums. If this returns
"! true, the ATC expects every finding to have a non-zero checksum.</p>
"!
"! @parameter uses_checksums | <p>Whether or not this check uses checksums</p>
METHODS uses_checksums
  RETURNING VALUE(uses_checksums) TYPE abap_bool.
"! <p>Indicates whether this check gathers its information through remote-enabled APIs. If this returns
"! true, the check must be able to check objects that lie not in the current system, but behind the RFC destination
"! returned by {@link CL_CI_ATC_DATA_PROVIDER~GET_CHECKED_DESTINATION}. This is automatically the case if the check only uses
"! the data provided by the methods of {@link CL_CI_ATC_DATA_PROVIDER}.</p>
"!
"! @parameter is_remote_enabled | <p>Whether or not this check is able to check remote systems</p>
METHODS is_remote_enabled
  returning value(is_remote_enabled) type abap_bool.

"! <p>Returns information on whether or not this check is a pseudo-remote check</p>
"!
"! @parameter pseudo_remote_information | <p>Pseudo-remote information</p>
methods get_pseudo_remote_info default ignore
  returning value(pseudo_remote_information) type ty_pseudo_remote_info.
ENDINTERFACE.