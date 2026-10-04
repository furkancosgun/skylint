CLASS zcl_skylint_check_072 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        condense_stmt  TYPE zif_skylint_types=>ty_finding_code VALUE 'CONDENSE_S',
        translate_stmt TYPE zif_skylint_types=>ty_finding_code VALUE 'TRANSLATE_',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_072 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect obsolete string statements; prefer built-in functions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity = zif_skylint_types=>severities-warning
                                     ( code = c_finding_codes-condense_stmt
                                       text = 'Use modern built-in string function condense( ... ) instead' )
                                     ( code = c_finding_codes-translate_stmt
                                       text = 'Use modern string functions to_upper() or to_lower() instead' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CONDENSE'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-condense_stmt ).
        WHEN 'TRANSLATE'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-translate_stmt ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
