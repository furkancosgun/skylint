/**
 * scripts/skylint-test/codeblock.mjs
 *
 * 1:1 JS port of lcl_code_block_builder=>slice_code_block + lcl_runner=>join_source
 * (src/platform/zcl_skylint_test_runner.clas.locals_imp.abap:1046-1111).
 *
 * Code block shape mirrors zif_skylint_types=>ty_code_block:
 *   { object_name, object_type: 'CLAS', block_kind: 'METH'|'DECL',
 *     block_name, statements: [...] }  (statement.index is 1-based)
 */

export const OBJECT_TYPES = { class: 'CLAS' };
export const BLOCK_KINDS = { method: 'METH', classDefinition: 'DECL' };

export function joinSource(lines) {
  return lines.join('\n');
}

/** lcl_code_block_builder=>slice_code_block */
export function sliceCodeBlock(statements, isClassDefinition = false, objectName = '') {
  const block = {
    object_name: objectName || 'ZSKYLINT_TEST',
    object_type: OBJECT_TYPES.class,
    block_kind: '',
    block_name: '',
    statements: [],
  };
  if (isClassDefinition) {
    block.block_kind = BLOCK_KINDS.classDefinition;
    block.block_name = '0';
    statements.forEach((s, i) => {
      block.statements.push({ ...s, index: i + 1 });
    });
    return block;
  }
  block.block_kind = BLOCK_KINDS.method;
  block.block_name = `${block.object_name}=>TEST`;
  let started = false;
  let methodName = '';
  for (const s of statements) {
    if (!started && s.keyword === 'METHOD') {
      started = true;
      if (s.tokens.length >= 2) methodName = s.tokens[1].lexeme.toUpperCase();
    }
    if (started) {
      block.statements.push({ ...s, index: block.statements.length + 1 });
    }
    if (started && s.keyword === 'ENDMETHOD') {
      if (methodName) block.block_name = `${block.object_name}=>${methodName}`;
      return block;
    }
  }
  return block;
}
