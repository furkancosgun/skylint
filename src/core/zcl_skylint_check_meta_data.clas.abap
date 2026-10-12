CLASS zcl_skylint_check_meta_data DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check_meta_data.

    METHODS constructor
      IMPORTING iv_description       TYPE string
                it_finding_codes     TYPE if_ci_atc_check_meta_data=>ty_finding_code_infos
                it_quickfix_codes    TYPE if_ci_atc_check_meta_data=>ty_quickfix_code_infos OPTIONAL
                it_attributes        TYPE if_ci_atc_check_meta_data=>ty_attributes          OPTIONAL
                iv_remote_enablement TYPE abap_bool                                         DEFAULT abap_true.

  PRIVATE SECTION.
    DATA mv_description       TYPE string.
    DATA mt_finding_codes     TYPE if_ci_atc_check_meta_data=>ty_finding_code_infos.
    DATA mt_quickfix_codes    TYPE if_ci_atc_check_meta_data=>ty_quickfix_code_infos.
    DATA mt_attributes        TYPE if_ci_atc_check_meta_data=>ty_attributes.
    DATA mv_remote_enablement TYPE abap_bool VALUE abap_true.
ENDCLASS.


CLASS zcl_skylint_check_meta_data IMPLEMENTATION.
  METHOD constructor.
    mv_description       = iv_description.
    mt_finding_codes     = it_finding_codes.
    mt_quickfix_codes    = it_quickfix_codes.
    mt_attributes        = it_attributes.
    mv_remote_enablement = iv_remote_enablement.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_attributes.
    attributes = mt_attributes.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_finding_code_infos.
    finding_code_infos = mt_finding_codes.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_quickfix_code_infos.
    quickfix_code_infos = mt_quickfix_codes.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_checked_object_types.
    types = VALUE #( ( 'CLAS' ) ( 'PROG' ) ( 'FUGR' ) ( 'INTF' ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_description.
    description = mv_description.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~uses_checksums.
    uses_checksums = abap_true.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~is_remote_enabled.
    is_remote_enabled = mv_remote_enablement.
  ENDMETHOD.
ENDCLASS.
