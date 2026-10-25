CLASS zcl_skylint_no_overw_builtin DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        overwrites_builtin TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_OVR_BLT',
      END OF c_finding_codes.

    CLASS-METHODS class_constructor.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_builtin_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_OVERW_BUILTIN'.

    CLASS-DATA gt_builtin TYPE ty_builtin_names.

    METHODS is_builtin_name
      IMPORTING iv_name       TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS get_method_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_overw_builtin IMPLEMENTATION.
  METHOD class_constructor.
    gt_builtin = VALUE #( ( `ABS` )
                          ( `ACOS` )
                          ( `ASIN` )
                          ( `ATAN` )
                          ( `BOOLC` )
                          ( `BOOLX` )
                          ( `CEIL` )
                          ( `CHAR_OFF` )
                          ( `CHARLEN` )
                          ( `CMAX` )
                          ( `CMIN` )
                          ( `CONCAT_LINES_OF` )
                          ( `CONDENSE` )
                          ( `CONTAINS` )
                          ( `CONTAINS_ANY_NOT_OF` )
                          ( `CONTAINS_ANY_OF` )
                          ( `COS` )
                          ( `COSH` )
                          ( `COUNT` )
                          ( `COUNT_ANY_NOT_OF` )
                          ( `COUNT_ANY_OF` )
                          ( `DBMAXLEN` )
                          ( `DISTANCE` )
                          ( `ESCAPE` )
                          ( `EXP` )
                          ( `FIND` )
                          ( `FIND_ANY_NOT_OF` )
                          ( `FIND_ANY_OF` )
                          ( `FIND_END` )
                          ( `FLOOR` )
                          ( `FRAC` )
                          ( `FROM_MIXED` )
                          ( `INSERT` )
                          ( `IPOW` )
                          ( `LINE_EXISTS` )
                          ( `LINE_INDEX` )
                          ( `LINES` )
                          ( `LOG` )
                          ( `LOG10` )
                          ( `MATCH` )
                          ( `MATCHES` )
                          ( `NMAX` )
                          ( `NMIN` )
                          ( `NUMOFCHAR` )
                          ( `REPEAT` )
                          ( `REPLACE` )
                          ( `RESCALE` )
                          ( `REVERSE` )
                          ( `ROUND` )
                          ( `SEGMENT` )
                          ( `SHIFT_LEFT` )
                          ( `SHIFT_RIGHT` )
                          ( `SIGN` )
                          ( `SIN` )
                          ( `SINH` )
                          ( `SQRT` )
                          ( `STRLEN` )
                          ( `SUBSTRING` )
                          ( `SUBSTRING_AFTER` )
                          ( `SUBSTRING_BEFORE` )
                          ( `SUBSTRING_FROM` )
                          ( `SUBSTRING_TO` )
                          ( `TAN` )
                          ( `TANH` )
                          ( `TO_LOWER` )
                          ( `TO_MIXED` )
                          ( `TO_UPPER` )
                          ( `TRANSLATE` )
                          ( `TRUNC` )
                          ( `UTCLONG_ADD` )
                          ( `UTCLONG_CURRENT` )
                          ( `UTCLONG_DIFF` )
                          ( `XSDBOOL` )
                          ( `XSTRLEN` ) ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor( VALUE #( description       = 'Method name overwrites built-in SAP function'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-overwrites_builtin
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Method name overwrites built-in SAP function name'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_method_name TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.

      lv_method_name = get_method_name( <ls_statement> ).
      IF is_builtin_name( lv_method_name ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-overwrites_builtin ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_method_name.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = 2 ).
    rv_name = ls_tok-lexeme.
  ENDMETHOD.

  METHOD is_builtin_name.
    rv_yes = xsdbool( line_exists( gt_builtin[ table_line = iv_name ] ) ).
  ENDMETHOD.
ENDCLASS.
