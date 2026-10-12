"! Provides (local or remote) data for ATC checks implementing {@link IF_CI_ATC_CHECK}.
"! When executed by the ATC framework, the framework will create an instance of this and pass it to the check in the
"! {@link IF_CI_ATC_CHECK.METH:RUN} method, so that most users will never need to create an instance of this themselves.
class cl_ci_atc_data_provider definition
  public
  final
  create private
  global friends
    cl_ci_atc_unit_driver
    cl_ci_test_atc_check_wrapper
    tc_ci_atc_ddic_provider.

  public section.
    "! Opaque identifier for the source of the data
    types ty_source_id type x length 16.
    types:
      "! For performance reasons, many intermediate analysis structures are cached during one ATC execution for later executions.
      "! This policy determines how these caches are used.
      begin of enum ty_cache_policy structure cache_policies,
        "! All caches are used if filled, and filled if this is the first execution
        use_all,
        "! No caches are used or filled
        use_none,
      end of enum ty_cache_policy structure cache_policies.
    types ty_object_provider_name type c length 20.

    "! Determines the name of the main program corresponding to a given compilation unit,
    "! e.g. CLASS=========================CP for a class named CLASS.
    "! @parameter compilation_unit | The compilation unit
    "! @parameter main_program | Main program of the compilation unit
    class-methods main_program_from_comp_unit
      importing compilation_unit    type if_ci_atc_source_code_provider=>ty_compilation_unit
      returning value(main_program) type if_ci_atc_source_code_provider=>ty_include.

    "! Returns a code provider through which detailed information about ABAP sources can be obtained.
    "! @parameter code_provider | The code provider
    methods get_code_provider
      returning value(code_provider) type ref to if_ci_atc_source_code_provider.
    "! Returns the destination for the checked system. If the checked system is the current system, the returned value is initial.<p>
    "!
    "! Note that this destination is <strong>unusable</strong> in ABAP Cloud due to language scope restrictions. See
    "! {@link CL_CI_ATC_DATA_PROVIDER.METH:GET_OBJECT_PROVIDER_NAME} instead.</p>
    "! @parameter checked_destination | Destination for the checked system
    methods get_checked_destination
      returning value(checked_destination) type ref to if_rfc_dest.
    "! <p>Returns the ATC object provider name for the current checked system, or the initial value for local check runs.</p>
    "! <p>The ATC object provider represents the connection to the checked system on an abstract level and uniquely identifies
    "! the source of the objects to be checked. In an ABAP Cloud context, this name should identify the communication arrangement
    "! to be used to create destinations for RFC calls to the checked system via CL_RFC_DESTINATION_PROVIDER's
    "! {@link cl_rfc_destination_provider.METH:create_by_comm_arrangement} (internally this also identifies the instance of
    "! SAP_COM_0464 to be used).</p>
    "! <p>See also https://help.sap.com/docs/btp/sap-business-technology-platform/rfc-communication-via-communication-arrangements
    "! for context and sample code for finding an arrangement via a custom property (in this case the custom property should
    "! be the object provider's name). </p>
    "! Use the data element {@link SCA_DS_OBJECT_PROVIDER_ID} with value help for the object provider in your communication
    "! scenario so that you can only choose object providers that have been created by an instance of the SAP_COM_0464 scenario.
    "!
    "! @parameter object_provider_name | Name of the object provider
    methods get_object_provider_name
      returning value(object_provider_name) type ty_object_provider_name.
    "! Returns a DDIC provider through which detailed information about ABAP DDIC objects can be obtained.
    "! @parameter ddic_provider | The DDIC provider
    methods get_ddic_provider
      returning value(ddic_provider) type ref to if_ci_atc_ddic_provider.
    "! Returns a metadata provider through which detailed information about ABAP objects can be obtained.
    "! @parameter metadata_provider | The metadata provider
    methods get_metadata_provider
      returning value(metadata_provider) type ref to if_ci_atc_metadata_provider.

  protected section.
  private section.
    types:
      begin of ty_factory_instance,
        source   type ty_source_id,
        instance type ref to cl_ci_atc_data_provider,
      end of ty_factory_instance.
    types ty_factory_instances type hashed table of ty_factory_instance with unique key source.
    "! Service to distinguish different "kinds of code", e.g. customer/partner/SAP or manually written vs. generated
    types ty_scope_service type ref to if_sca_code_assignment_service.

    class-data factory_instances type ty_factory_instances.

    "! Creates a data provider. Since an instance is create by the ATC framework and passed to the checks in their
    "! {@link IF_CI_ATC_CHECK.METH:RUN} method, there is rarely a need to call this outside of the ATC framework.
    "! @parameter source | Source of the data (initial means local)
    "! @parameter scope_service | Scope service used to enrich the information returned by {@link CL_CI_ATC_DATA_PROVIDER.METH:GET_CODE_PROVIDER}
    "! @parameter cache_policy | Policy for internal cache use
    "! @parameter self | The data provider
    class-methods create
      importing source               type ty_source_id
                object_provider_name type ty_object_provider_name
                scope_service        type ty_scope_service
                cache_policy         type ty_cache_policy default cache_policies-use_all
      returning value(self)          type ref to cl_ci_atc_data_provider.
    "! Fills internal caches with the data for this object. Should not be called inside individual ATC checks.
    "! @parameter object | Object for which data shall be fetched
    methods preload ##RELAX
      importing object type if_ci_atc_check=>ty_object.
    "! Empties all runtime caches in this instance. Should not be called inside individual ATC checks.
    class-methods clear_cache ##RELAX.
    class-methods main_program_for_func_group
      importing group          type if_ci_atc_source_code_provider=>ty_compilation_unit_name
      returning value(program) type if_ci_atc_source_code_provider=>ty_include.

    methods constructor
      importing source               type ty_source_id
                object_provider_name type ty_object_provider_name
                scope_service        type ty_scope_service
                cache_policy         type ty_cache_policy.
    data source type ty_source_id.
    data code_provider type ref to code_provider.
    data ddic_provider type ref to ddic_provider.
    data metadata_provider type ref to metadata_provider.
    data scope_service type ty_scope_service.
    data cache_policy type ty_cache_policy.
    data object_provider_name type ty_object_provider_name.
ENDCLASS.



CLASS CL_CI_ATC_DATA_PROVIDER IMPLEMENTATION.


  method clear_cache.
    clear factory_instances.
    cl_abap_comp_procs=>clear( ).
  endmethod.


  method constructor.
    me->source = source.
    me->scope_service = scope_service.
    me->cache_policy = cache_policy.
    me->object_provider_name = object_provider_name.
  endmethod.


  method create.
    if cache_policy = cache_policies-use_none.
      self = new #(
        source               = source
        object_provider_name = object_provider_name
        scope_service        = scope_service
        cache_policy         = cache_policy ).
      return.
    endif.
    if not line_exists( factory_instances[ source = source ] ).
      self = new #(
        source               = source
        object_provider_name = object_provider_name
        scope_service        = scope_service
        cache_policy         = cache_policy ).
      insert value #( source = source instance = self ) into table factory_instances.
    else.
      self = factory_instances[ source = source ]-instance.
    endif.
  endmethod.


  method get_checked_destination.
    if source is not initial.
      try.
          checked_destination = new cl_rfc_destination_basic( cl_abap_source_id=>get_destination( source ) ).
        catch cx_rfc_dest_provider_error ##NO_HANDLER. "If we look into the implementation, this exception doesn't actually occur.
      endtry.
    endif.
  endmethod.


  method get_code_provider.
    if me->code_provider is not bound.
      me->code_provider = new #( source = source scope_service = scope_service cache_policy = cache_policy ).
    endif.
    code_provider = me->code_provider.
  endmethod.


  method get_ddic_provider.
    if me->ddic_provider is not bound.
      data(rfc_dest) = cl_abap_source_id=>get_destination( source ).
      me->ddic_provider = new #( rfc_dest ).
    endif.
    ddic_provider = me->ddic_provider.
  endmethod.


  method get_metadata_provider.
    if me->metadata_provider is not bound.
      data(rfc_dest) = cl_abap_source_id=>get_destination( source ).
      me->metadata_provider = new #( rfc_dest ).
    endif.
    metadata_provider = me->metadata_provider.
  endmethod.


  method get_object_provider_name.
    object_provider_name = me->object_provider_name.
  endmethod.


  method main_program_for_func_group.
    if group(1) <> '/'.
      program = |SAPL{ group }|.
    else.
      split group+1 at '/' into data(namespace) data(unqualified_name).
      program = |/{ namespace }/SAPL{ unqualified_name }|.
    endif.
  endmethod.


  method main_program_from_comp_unit.
    main_program = switch #( compilation_unit-kind
      when if_ci_atc_source_code_provider=>compilation_unit_kinds-class then |{ compilation_unit-name width = 30 align = left pad = '=' }CP| ##NUMBER_OK
      when if_ci_atc_source_code_provider=>compilation_unit_kinds-report then compilation_unit-name
      when if_ci_atc_source_code_provider=>compilation_unit_kinds-function_group then main_program_for_func_group( compilation_unit-name )
      when if_ci_atc_source_code_provider=>compilation_unit_kinds-type_pool then compilation_unit-name
      when if_ci_atc_source_code_provider=>compilation_unit_kinds-interface then |{ compilation_unit-name width = 30 align = left pad = '=' }IP|
    ).
  endmethod.


  method preload.
    try.
        get_code_provider( )->get_procedures( value #( kind = conv #( object-type ) name = object-name ) ).
      catch cx_sy_conversion_no_enum_value ##NO_HANDLER. "Just do nothing if this isn't a program-like object
    endtry.
  endmethod.
ENDCLASS.