CLASS zcl_skylint_no_like_objects DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_like TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_LIKE_OB',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_LIKE_OBJECTS'.
ENDCLASS.


CLASS zcl_skylint_no_like_objects IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid LIKE referencing data objects; use explicit TYPE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-avoid_like
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid LIKE for data declarations; specify TYPE explicitly'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     (    <ls_statement>-keyword = 'DATA'    OR <ls_statement>-keyword = 'TYPES'
               OR <ls_statement>-keyword = 'STATICS' OR <ls_statement>-keyword = 'CONSTANTS' )
         AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'LIKE' ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_like ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
