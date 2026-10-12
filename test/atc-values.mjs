/**
 * test/atc-values.mjs
 *
 * Builds transpiled-runtime (abap.types) ATC values from JS pipeline results:
 * procedures shaped as if_ci_atc_source_code_provider=>ty_procedure.
 *
 * Field order + qualified names mirror the transpiled layout exactly
 * (see output/zcl_skylint_check_base.clas.mjs).
 */

const SRC = 'IF_CI_ATC_SOURCE_CODE_PROVIDER';

/**
 * The transpiled runtime represents ENUM components as ordinal integers
 * (e.g. procedure_kinds-class_definition === 2), NOT as their VALUE strings.
 * All enum-typed fields must therefore be filled from the runtime's own enum
 * singletons — never with the legacy 'METH'/'DA'/'5' strings.
 */
function enumOf(abap, prop) {
  return abap.Classes[SRC][prop].get();
}

const REF_KIND_BY_VALUE = { DA: 'data', ME: 'method', TY: 'type' };
const USAGE_MODE_BY_VALUE = {
  0: 'name', 1: 'type', 2: 'definition', 3: 'definition_with_write', 4: 'definition_with_assign',
  5: 'read', 6: 'write', 7: 'read_and_write', 8: 'read_reference', 9: 'write_reference',
  A: 'read_and_write_reference', B: 'any_access_reference', C: 'assign', D: 'write_partial',
  E: 'read_database', F: 'write_database', P: 'enhancement_point', R: 'redefinition', S: 'enhancement_section',
};
const USAGE_GRADE_BY_VALUE = { 0: 'definition', 1: 'direct', 2: 'component', 3: 'indirect' };
const PROC_KIND_BY_VALUE = {
  METH: 'method', DECL: 'class_definition', FORM: 'form_routine', FUNC: 'function',
  ATUC: 'at_user_command', LISE: 'at_line_selection', ATPF: 'at_pf_status', ATSS: 'at_selection_screen',
};
const UNIT_KIND_BY_VALUE = { CLAS: 'class', PROG: 'report', FUGR: 'function_group', INTF: 'interface', TYPE: 'type_pool' };

function enumInt(abap, prop, member) {
  return enumOf(abap, prop)[member];
}

function newEnumField(abap, prop, member) {
  // Integer template: enum-typed fields hold ordinals in the transpiled runtime
  return new abap.types.Integer({ qualifiedName: 'I' }).set(enumInt(abap, prop, member).get());
}

const STD_OPTS = {
  withHeader: false,
  keyType: 'EMPTY',
  primaryKey: { name: 'primary_key', type: 'STANDARD', isUnique: false, keyFields: [] },
  secondary: [],
};
const STATEMENTS_OPTS = {
  ...STD_OPTS,
  secondary: [{ name: 'keyword', type: 'SORTED', isUnique: false, keyFields: ['KEYWORD'] }],
};
const HASHED_OPTS = {
  withHeader: false,
  keyType: 'USER',
  primaryKey: { name: 'primary_key', type: 'HASHED', isUnique: true, keyFields: ['TABLE_LINE'] },
  secondary: [],
};
const PROCEDURES_OPTS = {
  ...STD_OPTS,
  secondary: [{ name: 'id', type: 'HASHED', isUnique: true, keyFields: ['ID'] }],
};

function newPosition(abap, line, column) {
  return new abap.types.Structure(
    {
      line: new abap.types.Integer({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_SOURCE_POSITION-LINE',
      }).set(line),
      column: new abap.types.Integer({ qualifiedName: 'INT1' }).set(column),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_source_position',
    undefined,
    {},
    {},
  );
}

function refRowTemplate(abap) {
  return new abap.types.Structure(
    {
      full_name: new abap.types.String({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_FULL_NAME',
      }),
      kind: new abap.types.Integer({ qualifiedName: 'I' }),
      usage_grade: new abap.types.Integer({ qualifiedName: 'I' }),
      usage_mode: new abap.types.Integer({ qualifiedName: 'I' }),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_compiler_reference',
    undefined,
    {},
    {},
  );
}

function tokenRowTemplate(abap) {
  return new abap.types.Structure(
    {
      lexeme: new abap.types.String({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_LEXEME',
      }),
      position: newPosition(abap, 0, 0),
      references: abap.types.TableFactory.construct(
        refRowTemplate(abap),
        STD_OPTS,
        'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_compiler_references',
      ),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_token',
    undefined,
    {},
    {},
  );
}

function statementRowTemplate(abap) {
  return new abap.types.Structure(
    {
      keyword: new abap.types.String({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_KEYWORD',
      }),
      tokens: abap.types.TableFactory.construct(
        tokenRowTemplate(abap),
        STD_OPTS,
        'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_tokens',
      ),
      pseudo_comments: abap.types.TableFactory.construct(
        new abap.types.String({ qualifiedName: 'STRING' }),
        HASHED_OPTS,
        'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_pseudo_comments',
      ),
      include: new abap.types.Character(40, {
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_include',
      }),
      position: newPosition(abap, 0, 0),
      is_in_scope: new abap.types.Character(1, { qualifiedName: 'ABAP_BOOL', ddicName: 'ABAP_BOOL' }),
      block: new abap.types.Integer({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_STATEMENT-BLOCK',
      }),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_statement',
    undefined,
    {},
    {},
  );
}

function blockRowTemplate(abap) {
  const interval = () =>
    new abap.types.Structure(
      {
        from: new abap.types.Integer({
          qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_INTERVAL-FROM',
        }),
        to: new abap.types.Integer({
          qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_INTERVAL-TO',
        }),
      },
      'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_interval',
      undefined,
      {},
      {},
    );
  return new abap.types.Structure(
    {
      type: new abap.types.String({ qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_BLOCK_TYPE' }),
      statement_type: new abap.types.String({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_STATEMENT_TYPE',
      }),
      statements: interval(),
      blocks: interval(),
      parent: new abap.types.Integer({
        qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_BLOCK-PARENT',
      }),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_block',
    undefined,
    {},
    {},
  );
}

function procedureRowTemplate(abap) {
  return new abap.types.Structure(
    {
      id: new abap.types.Structure(
        {
          kind: new abap.types.Integer({ qualifiedName: 'I' }),
          name: new abap.types.String({
            qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>TY_PROCEDURE_NAME',
          }),
          main_unit: new abap.types.Structure(
            {
              kind: new abap.types.Integer({ qualifiedName: 'I' }),
              name: new abap.types.Character(40, {
                qualifiedName: 'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_compilation_unit_name',
              }),
            },
            'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_compilation_unit',
            undefined,
            {},
            {},
          ),
        },
        'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_procedure_id',
        undefined,
        {},
        {},
      ),
      statements: abap.types.TableFactory.construct(
        statementRowTemplate(abap),
        STATEMENTS_OPTS,
        'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_statements',
      ),
      blocks: abap.types.TableFactory.construct(
        blockRowTemplate(abap),
        STD_OPTS,
        'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_blocks',
      ),
    },
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_procedure',
    undefined,
    {},
    {},
  );
}

function enumMember(abap, prop, member) {
  if (!member) return undefined;
  const e = enumOf(abap, prop)[member];
  return e === undefined ? undefined : e.get();
}

function appendRef(abap, table, ref) {
  const row = refRowTemplate(abap);
  row.get().full_name.set(ref.full_name);
  const kind = enumMember(abap, 'if_ci_atc_source_code_provider$compiler_reference_kinds', REF_KIND_BY_VALUE[ref.kind]);
  if (kind !== undefined) row.get().kind.set(kind);
  const grade = enumMember(abap, 'if_ci_atc_source_code_provider$usage_grades', USAGE_GRADE_BY_VALUE[ref.usage_grade]);
  if (grade !== undefined) row.get().usage_grade.set(grade);
  if (ref.usage_mode !== undefined) {
    const mode = enumMember(abap, 'if_ci_atc_source_code_provider$usage_modes', USAGE_MODE_BY_VALUE[ref.usage_mode]);
    if (mode !== undefined) row.get().usage_mode.set(mode);
  }
  table.append(row);
}

function appendToken(abap, table, tok) {
  const row = tokenRowTemplate(abap);
  const g = row.get();
  g.lexeme.set(tok.lexeme);
  g.position.get().line.set(tok.position.line);
  g.position.get().column.set(tok.position.column);
  for (const r of tok.references) appendRef(abap, g.references, r);
  table.append(row);
}

function appendStatement(abap, table, stmt) {
  const row = statementRowTemplate(abap);
  const g = row.get();
  g.keyword.set(stmt.keyword);
  for (const t of stmt.tokens) appendToken(abap, g.tokens, t);
  g.position.get().line.set(stmt.position.line);
  g.position.get().column.set(stmt.position.column);
  for (const p of stmt.pseudo_comments) {
    const s = new abap.types.String({ qualifiedName: 'STRING' }).set(p);
    try {
      g.pseudo_comments.insert(s);
    } catch {
      // hashed-table duplicate — ABAP INSERT would set sy-subrc, ignore
    }
  }
  table.append(row);
}

/**
 * Build an abap.types ty_procedure value.
 * proc = { kind: 'METH'|'DECL', name, mainKind: 'CLAS', mainName, statements: [...] }
 */
export function buildProcedureValue(abap, proc) {
  const row = procedureRowTemplate(abap);
  const g = row.get();
  const kind = enumMember(abap, 'if_ci_atc_source_code_provider$procedure_kinds', PROC_KIND_BY_VALUE[proc.kind]);
  if (kind !== undefined) g.id.get().kind.set(kind);
  g.id.get().name.set(proc.name);
  const mainKind = enumMember(
    abap, 'if_ci_atc_source_code_provider$compilation_unit_kinds', UNIT_KIND_BY_VALUE[proc.mainKind]);
  if (mainKind !== undefined) g.id.get().main_unit.get().kind.set(mainKind);
  g.id.get().main_unit.get().name.set(proc.mainName);
  for (const s of proc.statements) appendStatement(abap, g.statements, s);
  return row;
}

/** Build an empty ty_procedures table holding the given procedure rows. */
export function buildProceduresTable(abap, procRows) {
  const table = abap.types.TableFactory.construct(
    procedureRowTemplate(abap),
    PROCEDURES_OPTS,
    'IF_CI_ATC_SOURCE_CODE_PROVIDER=>ty_procedures',
  );
  for (const r of procRows) table.append(r);
  return table;
}

/** Build a ty_object value { type: 'CLAS', name }. */
export function buildObjectValue(abap, name) {
  return new abap.types.Structure(
    {
      type: new abap.types.Character(4, { qualifiedName: 'if_ci_atc_check=>ty_object-type' }).set('CLAS'),
      name: new abap.types.Character(40, { qualifiedName: 'if_ci_atc_check=>ty_object-name' }).set(name),
    },
    'if_ci_atc_check=>ty_object',
    undefined,
    {},
    {},
  );
}
