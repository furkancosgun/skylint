CLASS zcl_skylint_check_meta_data DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check_meta_data.

    TYPES:
      BEGIN OF ty_finding_code_config,
        code           TYPE if_ci_atc_check=>ty_finding_code,
        severity       TYPE if_ci_atc_check=>ty_finding_severity,
        text           TYPE string,
        pseudo_comment TYPE string,
      END OF ty_finding_code_config,
      ty_finding_codes_config TYPE HASHED TABLE OF ty_finding_code_config WITH UNIQUE KEY code.

    TYPES:
      BEGIN OF ty_config,
        description       TYPE string,
        remote_enablement TYPE abap_bool,
        finding_codes     TYPE ty_finding_codes_config,
        quickfix_codes    TYPE if_ci_atc_check_meta_data=>ty_quickfix_code_infos,
        attributes        TYPE if_ci_atc_check_meta_data=>ty_attributes,
      END OF ty_config.

    METHODS constructor
      IMPORTING is_config TYPE ty_config.

    METHODS has_valid_pseudo_comment
      IMPORTING is_statement                 TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code              TYPE if_ci_atc_check=>ty_finding_code
      RETURNING VALUE(rv_has_pseudo_comment) TYPE abap_bool.

  PRIVATE SECTION.
    DATA ms_config TYPE ty_config.
ENDCLASS.


CLASS zcl_skylint_check_meta_data IMPLEMENTATION.
  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_attributes.
    attributes = ms_config-attributes.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_checked_object_types.
    types = VALUE #( ( 'CLAS' ) ( 'PROG' ) ( 'FUGR' ) ( 'INTF' ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_description.
    description = ms_config-description.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_finding_code_infos.
    DATA lv_pc TYPE string.

    LOOP AT ms_config-finding_codes ASSIGNING FIELD-SYMBOL(<ls_fc>).
      IF <ls_fc>-pseudo_comment IS NOT INITIAL AND <ls_fc>-pseudo_comment NP 'CI_*'.
        lv_pc = |CI_{ <ls_fc>-pseudo_comment }|.
      ELSE.
        lv_pc = <ls_fc>-pseudo_comment.
      ENDIF.

      INSERT VALUE #( code           = <ls_fc>-code
                      severity       = <ls_fc>-severity
                      category       = if_ci_atc_check_meta_data=>finding_categories-standard
                      text           = <ls_fc>-text
                      pseudo_comment = lv_pc )
             INTO TABLE finding_code_infos.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~get_quickfix_code_infos.
    quickfix_code_infos = ms_config-quickfix_codes.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~is_remote_enabled.
    is_remote_enabled = ms_config-remote_enablement.
  ENDMETHOD.

  METHOD if_ci_atc_check_meta_data~uses_checksums.
    uses_checksums = abap_true.
  ENDMETHOD.

  METHOD has_valid_pseudo_comment.
    DATA lv_raw_pc TYPE string.
    DATA lv_ci_pc  TYPE string.

    ASSIGN ms_config-finding_codes[ code = iv_finding_code ] TO FIELD-SYMBOL(<ls_finding_code>).
    IF sy-subrc <> 0 OR <ls_finding_code>-pseudo_comment IS INITIAL.
      rv_has_pseudo_comment = abap_false.
      RETURN.
    ENDIF.

    lv_raw_pc = <ls_finding_code>-pseudo_comment.
    IF lv_raw_pc CP 'CI_*'.
      lv_ci_pc = lv_raw_pc.
    ELSE.
      lv_ci_pc = |CI_{ lv_raw_pc }|.
    ENDIF.

    rv_has_pseudo_comment = xsdbool(
         line_exists( is_statement-pseudo_comments[ table_line = lv_raw_pc ] )
      OR line_exists( is_statement-pseudo_comments[ table_line = lv_ci_pc ] ) ).
  ENDMETHOD.
ENDCLASS.
