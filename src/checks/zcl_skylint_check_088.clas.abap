CLASS zcl_skylint_check_088 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FINAL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_FINAL_METHOD'.
ENDCLASS.


CLASS zcl_skylint_check_088 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer marking non-overridden methods as FINAL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_final
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Declare method as FINAL if it is not intended to be redefined'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_final  TYPE abap_bool.
    DATA lv_is_special TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    "TODO rtti üzerinden çözebiliriz diye düşünüyorum kontorl edelim
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS'.
      lv_has_final = abap_false.
      lv_is_special = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        CASE to_upper( <ls_token>-lexeme ).
          WHEN 'FINAL'.
            lv_has_final = abap_true.
          WHEN 'REDEFINITION' OR 'ABSTRACT' OR 'TESTING' OR 'CONSTRUCTOR'.
            lv_is_special = abap_true.
        ENDCASE.
      ENDLOOP.

      IF lv_is_special = abap_false AND lv_has_final = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_final ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
