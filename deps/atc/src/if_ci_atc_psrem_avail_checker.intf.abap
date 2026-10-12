INTERFACE if_ci_atc_psrem_avail_checker
  PUBLIC .

types:
  begin of enum ty_availability_handling structure availability_handling,
    "! No message is displayed to the user, the check is silently skipped during the ATC run. This is recommended e.g.
    "! if the check checks for situations which cannot occur in the lower releases to begin with.
    skip,
    "! The message is displayed to the user, but the ATC run is still executed and the check skipped during execution
    inform,
    "! The message is displayed to the user and the ATC run is cancelled.
    cancel,
  end of enum ty_availability_handling structure availability_handling.
types:
  begin of ty_sw_comp_release,
    component type c length 30,
    release type c length 10,
    support_package type c length 10,
  end of ty_sw_comp_release.
types:
  begin of enum ty_available structure available,
    "! The check is not available for this software component release
    no,
    "! The check is available for this software component release
    yes,
    "! The check is not available by default for this software component release, but an action (e.g. applying a note) can
    "! be taken to make it available.
    action_required,
  end of enum ty_available structure available.
types:
  begin of ty_availability,
    "! The availability status of the check
    available type ty_available,
    "! How the check being unavailable should be handled by the ATC
    handling type ty_availability_handling,
    "! The message that is displayed to the user if the check is unavailable
    message type string,
  end of ty_availability.


"! <p>Checks whether the pseudo-remote check is available for a specific release of its software component</p>
"!
"! <p>Note that independent of the check, there is a general restriction that the checked system needs to contain a version
"! of the check that sets the pseudo-remote info, and hence the checked system always needs to at least be on SAP_BASIS 824
"! or SAP_BASIS 918 or higher for any pseudo-remote check to be able to function, regardless of the version of the software
"! component the check is located in.</p>
"!
"! @parameter sw_comp_release | <p>The software component release (of the checked system)</p>
"! @parameter availability | <p>Whether the check is available or not</p>
methods check_availability
  importing
    sw_comp_release type ty_sw_comp_release
  returning value(availability) type ty_availability.

ENDINTERFACE.