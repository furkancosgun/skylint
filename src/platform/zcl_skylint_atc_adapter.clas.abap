CLASS zcl_skylint_atc_adapter DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.
  
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_config TYPE zif_skylint_types=>ty_config.

    INTERFACES if_ci_atc_check.

    METHODS lint ABSTRACT
      IMPORTING is_code_block      TYPE zif_skylint_types=>ty_code_block
      RETURNING VALUE(rt_findings) TYPE zif_skylint_types=>ty_findings.

  PROTECTED SECTION.
    DATA ms_config  TYPE zif_skylint_types=>ty_config.
    DATA mo_factory TYPE REF TO cl_ci_atc_assistant_factory.
ENDCLASS.


CLASS zcl_skylint_atc_adapter IMPLEMENTATION.
  METHOD constructor.
    ms_config = is_config.
  ENDMETHOD.

  METHOD if_ci_atc_check~get_meta_data.
    meta_data = NEW lcl_metadata( ms_config ).
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    DATA ls_code_block  TYPE zif_skylint_types=>ty_code_block.
    DATA ls_unit        TYPE if_ci_atc_source_code_provider=>ty_compilation_unit.
    DATA lr_procedures  TYPE REF TO if_ci_atc_source_code_provider=>ty_procedures.
    DATA lo_provider    TYPE REF TO if_ci_atc_source_code_provider.
    DATA lt_findings    TYPE zif_skylint_types=>ty_findings.
    DATA lo_quickfix    TYPE REF TO cl_ci_atc_quickfixes.
    DATA lo_fix         TYPE REF TO if_ci_atc_quickfix.
    DATA lv_checksum    TYPE if_ci_atc_source_code_provider=>ty_statement_checksum.

    FIELD-SYMBOLS <fs_procedure> TYPE if_ci_atc_source_code_provider=>ty_procedure.
    FIELD-SYMBOLS <fs_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <fs_finding>   TYPE zif_skylint_types=>ty_finding.
    FIELD-SYMBOLS <fs_fix>       TYPE zif_skylint_types=>ty_quickfix.

    lo_provider = data_provider->get_code_provider( ).

    ls_unit = lo_provider->object_to_comp_unit( object ).
    lr_procedures = lo_provider->get_procedures( ls_unit ).
    LOOP AT lr_procedures->* ASSIGNING <fs_procedure>.
      ls_code_block = VALUE #(
          object_type = ls_unit-kind
          object_name = ls_unit-name
          block_kind  = <fs_procedure>-id-kind
          block_name  = <fs_procedure>-id-name
          statements  = VALUE #( FOR statement IN <fs_procedure>-statements INDEX INTO idx

                                 ( index           = idx
                                   keyword         = statement-keyword
                                   position        = VALUE #( line   = statement-position-line
                                                              column = statement-position-column )
                                   pseudo_comments = statement-pseudo_comments
                                   tokens          = VALUE #(
                                       FOR token IN statement-tokens
                                       ( lexeme     = token-lexeme
                                         position   = VALUE #( line   = token-position-line
                                                               column = token-position-column )
                                         references = VALUE #( FOR ref IN token-references

                                                               ( full_name   = ref-full_name
                                                                 kind        = ref-kind
                                                                 usage_grade = ref-usage_grade
                                                                 usage_mode  = ref-usage_mode ) ) ) ) ) ) ).

      lt_findings = lint( ls_code_block ).
      LOOP AT lt_findings ASSIGNING <fs_finding>.
        CLEAR lv_checksum.
        IF <fs_finding>-statement_index > 0.
          READ TABLE <fs_procedure>-statements ASSIGNING <fs_statement>
            INDEX <fs_finding>-statement_index.
          IF sy-subrc = 0.
            lv_checksum = lo_provider->get_statement_checksum( <fs_statement> ).
          ENDIF.
        ENDIF.

        lo_quickfix = mo_factory->create_quickfixes( ).
        LOOP AT <fs_finding>-quickfixes ASSIGNING <fs_fix>.
          lo_fix = lo_quickfix->create_quickfix( quickfix_code = <fs_fix>-code ).
          lo_fix->replace(
              context = mo_factory->create_quickfix_context( VALUE #( procedure_id = <fs_procedure>-id
                                                                      statements   = VALUE #(
                                                                          from = <fs_fix>-statement_from
                                                                          to   = <fs_fix>-statement_to )
                                                                      tokens       = VALUE #(
                                                                          from = <fs_fix>-token_from
                                                                          to   = <fs_fix>-token_to ) ) )
              code    = <fs_fix>-new_code ).
        ENDLOOP.

        INSERT VALUE #( code     = <fs_finding>-code
                        location = VALUE #( position = VALUE #( line   = <fs_finding>-position-line
                                                                column = <fs_finding>-position-column ) )
                        checksum = lv_checksum
                        details  = mo_factory->create_finding_details( )->attach_quickfixes( lo_quickfix ) )

               INTO TABLE findings.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ci_atc_check~set_assistant_factory.
    mo_factory = factory.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
  ENDMETHOD.
ENDCLASS.