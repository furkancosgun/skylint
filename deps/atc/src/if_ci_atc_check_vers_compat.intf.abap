interface if_ci_atc_check_vers_compat
  public.

  types:
    "! An ATC finding (this structure is identical to {@link IF_CI_ATC_CHECK.TY_FINDING} but does not contain details)
    begin of ty_finding,
      "! Identifier that, together with the check that emitted it, uniquely specifies the "kind" of finding this is.
      "! Findings with the same code should refer to similar or identical situations.
      code type if_ci_atc_check=>ty_finding_code,
      "! Location of the finding
      location type if_ci_atc_check=>ty_location,
      "! Parameters that will be used to construct the text displayed for this finding, together with the generic text
      "! returned by the {@link IF_CI_ATC_CHECK_META_DATA} instance for the check that emitted this finding
      parameters type if_ci_atc_check=>ty_message_parameters,
      "! Checksum used to identify a finding even when its location has changed
      checksum type if_ci_atc_check=>ty_checksum,
      "! This finding has been disable by a pseudo comment or pragma
      has_pseudo_comment type abap_bool,
    end of ty_finding.
  types ty_findings type sorted table of ty_finding with non-unique key code location.

  methods process_older_version_findings
    importing
      !version type if_ci_atc_check_meta_data=>ty_pseudo_remote_version
      old_findings type ty_findings
    returning value(findings) type ty_findings.


endinterface.