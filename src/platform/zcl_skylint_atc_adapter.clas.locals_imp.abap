CLASS lcl_metadata DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config.

    INTERFACES if_ci_atc_check_meta_data.

  PRIVATE SECTION.
    DATA ms_config TYPE zif_skylint_types=>ty_config.
ENDCLASS.


CLASS lcl_metadata IMPLEMENTATION.
  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_checked_object_types.
    types = VALUE #( ( 'CLAS' ) ( 'PROG' ) ( 'FUGR' ) ( 'INTF' ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_description.
    description = 'Test'.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_finding_code_infos.
    finding_code_infos = VALUE #( FOR finding IN ms_config-finding_codes
                                  ( code           = finding-code
                                    severity       = SWITCH #( finding-severity
                                                               WHEN zif_skylint_types=>severities-error THEN
                                                                 if_ci_atc_check=>finding_severities-error
                                                               WHEN zif_skylint_types=>severities-warning THEN
                                                                 if_ci_atc_check=>finding_severities-warning
                                                               ELSE
                                                                 if_ci_atc_check=>finding_severities-note )
                                    text           = finding-text
                                    pseudo_comment = finding-pseudo_comment ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_quickfix_code_infos.
    quickfix_code_infos = VALUE #( FOR fix IN ms_config-quickfix_codes
                                   ( code       = fix-code
                                     short_text = fix-short_text ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~is_remote_enabled.
    is_remote_enabled = ms_config-remote_enablement.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~uses_checksums.
    uses_checksums = abap_false.
  ENDMETHOD.
ENDCLASS.