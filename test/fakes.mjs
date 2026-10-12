/**
 * test/fakes.mjs
 *
 * JS test doubles for the SAP ATC boundary. The transpiled check calls methods
 * on these plain objects through the same protocol as real ABAP objects:
 *   holder.get().methodName({ ...params })
 * Interface methods keep their transpiled `$` names
 * (e.g. `if_ci_atc_source_code_provider$get_procedures`).
 *
 * Values flowing into typed ABAP fields (location, checksum, comp unit) are
 * real abap.types values; pass-through handles (contexts, details chain)
 * are plain chainable objects.
 */

function newCompUnit(abap, kind, name) {
  return new abap.types.Structure(
    {
      kind: new abap.types.String({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_COMPILATION_UNIT_KIND',
      }).set(kind),
      name: new abap.types.Character(40, {
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_compilation_unit_name',
      }).set(name),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_compilation_unit',
    undefined,
    {},
    {},
  );
}

function newLocation(abap, objectName, line, column) {
  return new abap.types.Structure(
    {
      object: new abap.types.Structure(
        {
          type: new abap.types.Character(4, {
            qualifiedName: 'if_ci_atc_check=>ty_object-type',
          }).set('CLAS'),
          name: new abap.types.Character(40, {
            qualifiedName: 'if_ci_atc_check=>ty_object-name',
          }).set(objectName),
        },
        'if_ci_atc_check=>ty_object',
        undefined,
        {},
        {},
      ),
      position: new abap.types.Structure(
        {
          line: new abap.types.Integer({ qualifiedName: 'IF_CI_ATC_CHECK=>TY_POSITION-LINE' }).set(line),
          column: new abap.types.Integer({ qualifiedName: 'INT1' }).set(column),
        },
        'if_ci_atc_check=>ty_position',
        undefined,
        {},
        {},
      ),
    },
    'if_ci_atc_check=>ty_location',
    undefined,
    {},
    {},
  );
}

function readPosition(statement) {
  const g = statement.get();
  return { line: g.position.get().line.get(), column: g.position.get().column.get() };
}

/**
 * Create { provider, factory } doubles.
 * proceduresTable: abap.types ty_procedures table; objectName: main unit name.
 */
export function createFakes(abap, proceduresTable, objectName) {
  const fix = {
    async 'if_ci_atc_quickfix$replace'() {
      return fix;
    },
  };

  function readCode(INPUT) {
    const v = INPUT?.quickfix_code;
    if (v && typeof v.get === 'function') return String(v.get()).trim();
    return String(v ?? '');
  }

  const detailsHolder = {
    get() {
      return {
        // The collector flows in via INPUT.quickfixes, wrapped in the
        // transpiled object holder — unwrap with .get() first.
        async attach_quickfixes(INPUT) {
          const holder = INPUT?.quickfixes;
          const collector = holder && typeof holder.get === 'function' ? holder.get() : holder;
          const list = [...((collector && collector.list) || [])];
          return { codes: list };
        },
      };
    },
  };

  const factory = {
    async create_quickfixes() {
      // Fresh collector per finding (mirrors convert_reported calling this
      // once per reported row).
      const collector = {
        list: [],
        async create_quickfix(INPUT) {
          collector.list.push(readCode(INPUT));
          return fix;
        },
      };
      return collector;
    },
    async create_quickfix_context() {
      return {};
    },
    async create_finding_details() {
      return detailsHolder;
    },
  };

  const codeProvider = {
    async 'if_ci_atc_source_code_provider$object_to_comp_unit'() {
      return newCompUnit(abap, 'CLAS', objectName);
    },
    async 'if_ci_atc_source_code_provider$get_procedures'() {
      // RETURNING REF TO: the transpiled caller does ref.set(result), which
      // only adopts DataReference/FieldSymbol values — wrap the table.
      const ref = new abap.types.DataReference(proceduresTable);
      ref.assign(proceduresTable);
      return ref;
    },
    async 'if_ci_atc_source_code_provider$get_statement_location'(INPUT) {
      const pos = readPosition(INPUT.statement);
      return newLocation(abap, objectName, pos.line, pos.column);
    },
    async 'if_ci_atc_source_code_provider$get_statement_checksum'() {
      return new abap.types.Integer({ qualifiedName: 'INT4' }).set(1);
    },
  };

  const provider = {
    async get_code_provider() {
      return codeProvider;
    },
  };

  return { provider, factory };
}
