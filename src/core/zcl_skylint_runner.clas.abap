CLASS zcl_skylint_runner DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_check_list TYPE STANDARD TABLE OF REF TO zcl_skylint_check_base WITH EMPTY KEY.

    METHODS constructor
      IMPORTING it_checks TYPE ty_check_list OPTIONAL.

    METHODS register_check
      IMPORTING io_check TYPE REF TO zcl_skylint_check_base.

    METHODS get_registered_checks
      RETURNING VALUE(rt_checks) TYPE ty_check_list.

    METHODS run_procedure
      IMPORTING is_procedure       TYPE zif_skylint_types=>ty_procedure
      RETURNING VALUE(rt_findings) TYPE zif_skylint_types=>ty_findings.

    CLASS-METHODS create_default
      RETURNING VALUE(ro_runner) TYPE REF TO zcl_skylint_runner.

  PRIVATE SECTION.
    DATA mt_checks TYPE ty_check_list.

ENDCLASS.


CLASS zcl_skylint_runner IMPLEMENTATION.

  METHOD constructor.
    mt_checks = it_checks.
  ENDMETHOD.

  METHOD register_check.
    IF io_check IS BOUND.
      APPEND io_check TO mt_checks.
    ENDIF.
  ENDMETHOD.

  METHOD get_registered_checks.
    rt_checks = mt_checks.
  ENDMETHOD.

  METHOD run_procedure.
    DATA lo_check    TYPE REF TO zcl_skylint_check_base.
    DATA lt_findings TYPE zif_skylint_types=>ty_findings.

    LOOP AT mt_checks INTO lo_check.
      lt_findings = lo_check->run( is_procedure ).
      APPEND LINES OF lt_findings TO rt_findings.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_default.
    ro_runner = NEW zcl_skylint_runner( ).
    " Active checks registered by indexer
    ro_runner->register_check( NEW zcl_skylint_check_001( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_002( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_003( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_004( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_005( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_006( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_007( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_008( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_009( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_010( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_011( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_012( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_013( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_014( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_015( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_016( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_017( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_018( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_019( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_020( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_021( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_022( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_023( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_024( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_025( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_026( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_027( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_028( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_029( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_030( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_031( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_032( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_033( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_034( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_035( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_036( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_037( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_038( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_039( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_040( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_041( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_042( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_043( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_044( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_045( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_046( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_047( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_048( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_049( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_050( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_051( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_052( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_053( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_054( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_055( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_056( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_057( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_058( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_059( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_060( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_061( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_062( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_063( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_064( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_065( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_066( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_067( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_068( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_069( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_070( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_071( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_072( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_073( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_074( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_075( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_076( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_077( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_078( ) ).
    ro_runner->register_check( NEW zcl_skylint_check_079( ) ).
  ENDMETHOD.

ENDCLASS.
