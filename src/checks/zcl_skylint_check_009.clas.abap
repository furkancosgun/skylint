CLASS zcl_skylint_check_009 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_template TYPE zif_skylint_types=>ty_finding_code VALUE 'CONCATSTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_STR_TMPL'.

    DATA mv_allow_in_byte_mode TYPE abap_bool VALUE abap_false.

    METHODS is_byte_mode
      IMPORTING is_statement        TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_byte_mode) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_009 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer string templates over CONCATENATE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_template
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Use string template |...| instead of CONCATENATE'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( ( name  = 'ALLOW_IN_BYTE_MODE'
                                                                kind  = zif_skylint_types=>attribute_kinds-boolean
                                                                value = REF #( mv_allow_in_byte_mode ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CONCATENATE'.
      IF mv_allow_in_byte_mode = abap_true AND is_byte_mode( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_template ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_byte_mode.
    rv_byte_mode = zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `BYTE` ) ( `MODE` ) ) ).
  ENDMETHOD.
ENDCLASS.
