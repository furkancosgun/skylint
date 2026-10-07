/**
 * scripts/skylint-test/abap-values.mjs
 *
 * Builds transpiled-runtime (abap.types) values from JS pipeline results so
 * transpiled checks can be called directly: ioCheck.lint({ is_code_block }).
 *
 * Field order + qualified names mirror the transpiled
 * zif_skylint_types=>ty_code_block layout exactly (the generated lint()
 * rejects inputs whose top qualifiedName !== ZIF_SKYLINT_TYPES=>TY_CODE_BLOCK).
 */

const STD_OPTS = {
  withHeader: false,
  keyType: 'EMPTY',
  primaryKey: { name: 'primary_key', type: 'STANDARD', isUnique: false, keyFields: [] },
  secondary: [],
};
const HASHED_OPTS = {
  withHeader: false,
  keyType: 'USER',
  primaryKey: { name: 'primary_key', type: 'HASHED', isUnique: true, keyFields: ['TABLE_LINE'] },
  secondary: [],
};

function newPosition(abap, line, column) {
  return new abap.types.Structure(
    {
      line: new abap.types.Integer({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_POSITION-LINE' }).set(line),
      column: new abap.types.Integer({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_POSITION-COLUMN' }).set(column),
    },
    'zif_skylint_types=>ty_position',
    undefined,
    {},
    {},
  );
}

function refRowTemplate(abap) {
  return new abap.types.Structure(
    {
      full_name: new abap.types.String({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_FULL_NAME' }),
      kind: new abap.types.Character(2, { qualifiedName: 'zif_skylint_types=>ty_reference_kind' }),
      usage_grade: new abap.types.Character(1, { qualifiedName: 'zif_skylint_types=>ty_usage_grade' }),
      usage_mode: new abap.types.Character(1, { qualifiedName: 'zif_skylint_types=>ty_usage_mode' }),
    },
    'zif_skylint_types=>ty_compiler_reference',
    undefined,
    {},
    {},
  );
}

function tokenRowTemplate(abap) {
  return new abap.types.Structure(
    {
      lexeme: new abap.types.String({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_LEXEME' }),
      position: newPosition(abap, 0, 0),
      references: abap.types.TableFactory.construct(
        refRowTemplate(abap),
        STD_OPTS,
        'zif_skylint_types=>ty_compiler_references',
      ),
    },
    'zif_skylint_types=>ty_token',
    undefined,
    {},
    {},
  );
}

function statementRowTemplate(abap) {
  return new abap.types.Structure(
    {
      index: new abap.types.Integer({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_STATEMENT-INDEX' }),
      keyword: new abap.types.String({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_KEYWORD' }),
      tokens: abap.types.TableFactory.construct(tokenRowTemplate(abap), STD_OPTS, 'zif_skylint_types=>ty_tokens'),
      position: newPosition(abap, 0, 0),
      pseudo_comments: abap.types.TableFactory.construct(
        new abap.types.String({ qualifiedName: 'STRING' }),
        HASHED_OPTS,
        'zif_skylint_types=>ty_pseudo_comments',
      ),
    },
    'zif_skylint_types=>ty_statement',
    undefined,
    {},
    {},
  );
}

function appendRef(abap, table, ref) {
  const row = refRowTemplate(abap);
  row.get().full_name.set(ref.full_name);
  row.get().kind.set(ref.kind);
  row.get().usage_grade.set(ref.usage_grade);
  if (ref.usage_mode !== undefined) row.get().usage_mode.set(ref.usage_mode);
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
  g.index.set(stmt.index);
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

/** Build an abap.types ty_code_block value from a JS pipeline block. */
export function buildCodeBlockValue(abap, block) {
  const statements = abap.types.TableFactory.construct(
    statementRowTemplate(abap),
    STD_OPTS,
    'zif_skylint_types=>ty_statements',
  );
  for (const s of block.statements) appendStatement(abap, statements, s);
  return new abap.types.Structure(
    {
      object_name: new abap.types.Character(40, { qualifiedName: 'zif_skylint_types=>ty_object_name' }).set(
        block.object_name,
      ),
      object_type: new abap.types.Character(4, { qualifiedName: 'zif_skylint_types=>ty_object_type' }).set(
        block.object_type,
      ),
      block_kind: new abap.types.Character(4, { qualifiedName: 'zif_skylint_types=>ty_block_kind' }).set(
        block.block_kind,
      ),
      block_name: new abap.types.String({ qualifiedName: 'ZIF_SKYLINT_TYPES=>TY_CODE_BLOCK-BLOCK_NAME' }).set(
        block.block_name,
      ),
      statements,
    },
    'zif_skylint_types=>ty_code_block',
    undefined,
    {},
    {},
  );
}
