CLASS zcl_skylint_pref_clamp DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        pref_clamp TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CLAMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CLAMP'.

    TYPES:
      BEGIN OF ty_clamp_branch,
        var    TYPE string,
        bound  TYPE string,
        is_min TYPE abap_bool,
      END OF ty_clamp_branch.

    METHODS get_clamp_branch
      IMPORTING is_cond          TYPE if_ci_atc_source_code_provider=>ty_statement
                is_body          TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_branch) TYPE ty_clamp_branch.

ENDCLASS.


CLASS zcl_skylint_pref_clamp IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer nmin/nmax or clamp over manual IF clamp'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-pref_clamp
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Manual range clamping detected; consider using nmin( ), nmax( ), or clamp( )'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD get_clamp_branch.
    DATA ls_op TYPE if_ci_atc_source_code_provider=>ty_token.

    IF lines( is_cond-tokens ) <> 4 OR is_body-keyword <> 'COMPUTE' OR lines( is_body-tokens ) <> 3.
      RETURN.
    ENDIF.

    IF    to_upper( is_cond-tokens[ 2 ]-lexeme ) <> to_upper( is_body-tokens[ 1 ]-lexeme )
       OR to_upper( is_cond-tokens[ 4 ]-lexeme ) <> to_upper( is_body-tokens[ 3 ]-lexeme )
       OR is_body-tokens[ 2 ]-lexeme <> '='.
      RETURN.
    ENDIF.

    ls_op = is_cond-tokens[ 3 ].
    IF ls_op-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    CASE to_upper( ls_op-lexeme ).
      WHEN '<' OR 'LT' OR '<=' OR 'LE'.
        rs_branch = VALUE #( var    = to_upper( is_cond-tokens[ 2 ]-lexeme )
                             bound  = to_upper( is_cond-tokens[ 4 ]-lexeme )
                             is_min = abap_true ).
      WHEN '>' OR 'GT' OR '>=' OR 'GE'.
        rs_branch = VALUE #( var    = to_upper( is_cond-tokens[ 2 ]-lexeme )
                             bound  = to_upper( is_cond-tokens[ 4 ]-lexeme )
                             is_min = abap_false ).
    ENDCASE.
  ENDMETHOD.

  METHOD check.
    DATA ls_b1  TYPE ty_clamp_branch.
    DATA ls_b2  TYPE ty_clamp_branch.
    DATA lv_idx TYPE i.
    DATA lv_max TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_max = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_idx = sy-tabix.
      if <ls_stmt>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      " Pattern 1: IF, COMPUTE, ELSEIF, COMPUTE, ENDIF (5 statements)
      IF     lv_idx + 4 <= lv_max
         AND ( is_procedure-statements[ lv_idx + 2 ]-keyword = 'ELSEIF' OR is_procedure-statements[ lv_idx + 2 ]-keyword = 'ELSE' )
         AND is_procedure-statements[ lv_idx + 4 ]-keyword = 'ENDIF'.

        ls_b1 = get_clamp_branch( is_cond = <ls_stmt>
                                  is_body = is_procedure-statements[ lv_idx + 1 ] ).
        ls_b2 = get_clamp_branch( is_cond = is_procedure-statements[ lv_idx + 2 ]
                                  is_body = is_procedure-statements[ lv_idx + 3 ] ).

        IF     ls_b1 IS NOT INITIAL AND ls_b2 IS NOT INITIAL
           AND ls_b1-var = ls_b2-var AND ls_b1-is_min <> ls_b2-is_min.
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-pref_clamp ).
          CONTINUE.
        ENDIF.
      ENDIF.

      " Pattern 2: IF, COMPUTE, ENDIF, IF, COMPUTE, ENDIF (6 statements)
      IF     lv_idx + 5 <= lv_max
         AND is_procedure-statements[ lv_idx + 2 ]-keyword = 'ENDIF'
         AND is_procedure-statements[ lv_idx + 3 ]-keyword = 'IF'
         AND is_procedure-statements[ lv_idx + 5 ]-keyword = 'ENDIF'.

        ls_b1 = get_clamp_branch( is_cond = <ls_stmt>
                                  is_body = is_procedure-statements[ lv_idx + 1 ] ).
        ls_b2 = get_clamp_branch( is_cond = is_procedure-statements[ lv_idx + 3 ]
                                  is_body = is_procedure-statements[ lv_idx + 4 ] ).

        IF     ls_b1 IS NOT INITIAL AND ls_b2 IS NOT INITIAL
           AND ls_b1-var = ls_b2-var AND ls_b1-is_min <> ls_b2-is_min.
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-pref_clamp ).
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
