CLASS /skyl/cl_no_aliases DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_aliases TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_ALIASES',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_ALIASES'.

    DATA mv_ignore_private TYPE abap_bool VALUE abap_false.

ENDCLASS.


CLASS /skyl/cl_no_aliases IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid using ALIASES in classes and interfaces'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-no_aliases
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Do not use ALIASES; reference interface components explicitly'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'IGNORE_PRIVATE'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_ignore_private ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_in_private TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_in_private = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PRIVATE'.
          IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                  iv_lexeme    = 'SECTION' ) = abap_true.
            lv_in_private = abap_true.
          ENDIF.

        WHEN 'PUBLIC' OR 'PROTECTED'.
          IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                  iv_lexeme    = 'SECTION' ) = abap_true.
            lv_in_private = abap_false.
          ENDIF.

        WHEN 'ALIASES'.
          IF mv_ignore_private = abap_true AND lv_in_private = abap_true.
            CONTINUE.
          ENDIF.

          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-no_aliases ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
