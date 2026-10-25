import fs from 'fs';
import path from 'path';

const { RULES } = await import('/Users/furkancosgun/Downloads/skylint/scripts/rules-data.mjs');
const checksDir = '/Users/furkancosgun/Downloads/skylint/src/checks';

// Multi-finding rules mapping
// Each finding code MUST be <= 10 chars, starting with PREF_, NO_, or MAX_
const multiFindings = {
  'ZCL_SKYLINT_MAX_METHOD_LEN': [
    { findingName: 'method_length', code: 'MAX_METH_L', pc: 'MAX_METHOD_LEN', desc: 'Method statement limit exceeded' },
    { findingName: 'constructor_logic', code: 'MAX_CTOR', pc: 'MAX_CTOR_LOGIC', desc: 'Heavy logic / loop limit in constructor' }
  ],
  'ZCL_SKYLINT_MAX_PARAMS': [
    { findingName: 'too_many_parameters', code: 'MAX_PARAMS', pc: 'MAX_PARAMS_COUNT', desc: 'Too many method parameters' },
    { findingName: 'multiple_params', code: 'MAX_PARM_L', pc: 'MAX_PARAMS_LINE', desc: 'Multiple parameters on single line' }
  ],
  'ZCL_SKYLINT_NO_CHECK_STMT': [
    { findingName: 'check_in_loop', code: 'NO_CHK_LP', pc: 'NO_CHECK_IN_LOOP', desc: 'CHECK statement inside loop (use CONTINUE)' },
    { findingName: 'check_outside_loop', code: 'NO_CHK_OUT', pc: 'NO_CHECK_OUTSIDE_LOOP', desc: 'CHECK statement outside loop (use RETURN)' }
  ],
  'ZCL_SKYLINT_NO_DUP_COND': [
    { findingName: 'identical_condition', code: 'NO_DUP_CND', pc: 'NO_DUP_COND', desc: 'Identical branch condition' },
    { findingName: 'duplicate_operand', code: 'NO_DUP_OPR', pc: 'NO_DUP_OPERAND', desc: 'Duplicate operand in boolean expression' }
  ],
  'ZCL_SKYLINT_NO_EMPTY_BLOCK': [
    { findingName: 'empty_control_block', code: 'NO_EMPTY_B', pc: 'NO_EMPTY_BLOCK', desc: 'Empty control block (IF/LOOP/CASE)' },
    { findingName: 'try_without_catch', code: 'NO_TRY_WO', pc: 'NO_TRY_WITHOUT_CATCH', desc: 'TRY block without CATCH or CLEANUP' }
  ],
  'ZCL_SKYLINT_NO_EXPOSED_DATA': [
    { findingName: 'public_attribute', code: 'NO_PUB_ATR', pc: 'NO_PUBLIC_ATTR', desc: 'Public attribute in class' },
    { findingName: 'interface_data', code: 'NO_INTF_DA', pc: 'NO_INTERFACE_DATA', desc: 'Data variable exposed in interface' }
  ],
  'ZCL_SKYLINT_NO_MOD_LOOP_TAB': [
    { findingName: 'modify_loop_table', code: 'NO_MOD_LTB', pc: 'NO_MOD_LOOP_TAB', desc: 'MODIFY on table currently being looped over' },
    { findingName: 'sort_in_loop', code: 'NO_SORT_LP', pc: 'NO_SORT_IN_LOOP', desc: 'SORT inside loop' }
  ],
  'ZCL_SKYLINT_NO_REDUN_ASSIGN': [
    { findingName: 'identical_move', code: 'NO_IDN_MOV', pc: 'NO_IDENTICAL_MOVE', desc: 'Identical variable assignment (a = a)' },
    { findingName: 'redundant_clear', code: 'NO_RED_CLR', pc: 'NO_REDUNDANT_CLEAR', desc: 'Redundant CLEAR before immediate reassignment' },
    { findingName: 'clear_at_end', code: 'NO_CLR_END', pc: 'NO_CLEAR_AT_END', desc: 'Redundant CLEAR at end of procedure' }
  ],
  'ZCL_SKYLINT_PREF_DECLARATIONS': [
    { findingName: 'definitions_top', code: 'PREF_TOP', pc: 'PREF_DEFINITIONS_TOP', desc: 'Local definitions must be at top of method' },
    { findingName: 'decl_order', code: 'PREF_ORDER', pc: 'PREF_DECLARATION_ORDER', desc: 'Declaration order: TYPES, CONSTANTS, DATA' }
  ],
  'ZCL_SKYLINT_PREF_DOWNCAST': [
    { findingName: 'prefer_cast', code: 'PREF_CAST', pc: 'PREF_DOWNCAST', desc: 'Prefer ?= over obsolete downcast syntax' },
    { findingName: 'inline_cast', code: 'PREF_INLCS', pc: 'PREF_INLINE_CAST', desc: 'Prefer CAST #( ) constructor expression' }
  ],
  'ZCL_SKYLINT_PREF_EARLY_RET': [
    { findingName: 'guard_method', code: 'PREF_GRDMT', pc: 'PREF_GUARD_METHOD', desc: 'Convert deep nested IF to guard RETURN' },
    { findingName: 'guard_loop', code: 'PREF_GRDLP', pc: 'PREF_GUARD_LOOP', desc: 'Convert nested IF in loop to guard CONTINUE' }
  ],
  'ZCL_SKYLINT_PREF_FINAL_CLS': [
    { findingName: 'class_not_final', code: 'PREF_FCLS', pc: 'PREF_FINAL_CLASS', desc: 'Class should be declared FINAL' },
    { findingName: 'method_not_final', code: 'PREF_FMETH', pc: 'PREF_FINAL_METHOD', desc: 'Method should be declared FINAL' }
  ],
  'ZCL_SKYLINT_PREF_MERGE_IFS': [
    { findingName: 'nested_if', code: 'PREF_MRGIF', pc: 'PREF_MERGE_IFS', desc: 'Merge consecutive nested IF statements with AND' },
    { findingName: 'else_if', code: 'PREF_ELSIF', pc: 'PREF_ELSE_IF', desc: 'Merge ELSE followed immediately by IF into ELSEIF' }
  ],
  'ZCL_SKYLINT_PREF_NAME_MEMBERS': [
    { findingName: 'class_attribute', code: 'PREF_NMATR', pc: 'PREF_NAME_ATTRIBUTE', desc: 'Class attribute naming convention' },
    { findingName: 'method_parameter', code: 'PREF_NMPAR', pc: 'PREF_NAME_PARAMETER', desc: 'Method parameter naming convention' },
    { findingName: 'selection_screen', code: 'PREF_NAMSS', pc: 'PREF_NAME_SELSCREEN', desc: 'Selection screen parameter naming' }
  ],
  'ZCL_SKYLINT_PREF_NAME_OBJECTS': [
    { findingName: 'local_class', code: 'PREF_LCLS', pc: 'PREF_NAME_LOCAL_CLASS', desc: 'Local class naming' },
    { findingName: 'global_class', code: 'PREF_GCLS', pc: 'PREF_NAME_GLOBAL_CLASS', desc: 'Global class naming' },
    { findingName: 'local_interface', code: 'PREF_LINTF', pc: 'PREF_NAME_LOCAL_INTF', desc: 'Local interface naming' },
    { findingName: 'global_interface', code: 'PREF_GINTF', pc: 'PREF_NAME_GLOBAL_INTF', desc: 'Global interface naming' },
    { findingName: 'types', code: 'PREF_TYP', pc: 'PREF_NAME_TYPE', desc: 'Type naming' },
    { findingName: 'event', code: 'PREF_EVT', pc: 'PREF_NAME_EVENT', desc: 'Event naming' },
    { findingName: 'test_method', code: 'PREF_TMETH', pc: 'PREF_NAME_TEST_METHOD', desc: 'Test method naming' },
    { findingName: 'macro', code: 'PREF_MACRO', pc: 'PREF_NAME_MACRO', desc: 'Macro naming' },
    { findingName: 'form', code: 'PREF_FORM', pc: 'PREF_NAME_FORM', desc: 'Form routine naming' },
    { findingName: 'function_module', code: 'PREF_FUNC', pc: 'PREF_NAME_FUNCTION', desc: 'Function module naming' },
    { findingName: 'function_group', code: 'PREF_FUGR', pc: 'PREF_NAME_FUGR', desc: 'Function group naming' },
    { findingName: 'program', code: 'PREF_PROG', pc: 'PREF_NAME_PROGRAM', desc: 'Program naming' }
  ],
  'ZCL_SKYLINT_PREF_NEW_OP': [
    { findingName: 'prefer_new', code: 'PREF_NEW', pc: 'PREF_NEW_OPERATOR', desc: 'Prefer NEW #( ) over CREATE OBJECT' },
    { findingName: 'raise_exception_new', code: 'PREF_RSNEW', pc: 'PREF_RAISE_EXC_NEW', desc: 'Prefer RAISE EXCEPTION NEW over CREATE OBJECT' }
  ],
  'ZCL_SKYLINT_PREF_PARAM_NAME': [
    { findingName: 'omit_param', code: 'PREF_OMIT', pc: 'PREF_OMIT_PARAM_NAME', desc: 'Omit single parameter name when possible' },
    { findingName: 'require_param', code: 'PREF_REQ_P', pc: 'PREF_REQUIRE_PARAM_NAME', desc: 'Explicit parameter name required' }
  ],
  'ZCL_SKYLINT_PREF_READ_TABLE': [
    { findingName: 'prefer_tab_expr', code: 'PREF_TABEX', pc: 'PREF_TABLE_EXPR', desc: 'Prefer table expression [ ] over READ TABLE' },
    { findingName: 'prefer_line_exists', code: 'PREF_LNEXS', pc: 'PREF_LINE_EXISTS', desc: 'Prefer line_exists( ) over READ TABLE TRANSPORTING NO FIELDS' }
  ],
  'ZCL_SKYLINT_PREF_STR_FUNC': [
    { findingName: 'condense_stmt', code: 'PREF_CNDNS', pc: 'PREF_CONDENSE_FUNC', desc: 'Prefer condense( ) function' },
    { findingName: 'translate_stmt', code: 'PREF_TRNSL', pc: 'PREF_TRANSLATE_FUNC', desc: 'Prefer to_upper( )/to_lower( ) over TRANSLATE' },
    { findingName: 'shift_stmt', code: 'PREF_SHIFT', pc: 'PREF_SHIFT_FUNC', desc: 'Prefer shift/substring functions over SHIFT' },
    { findingName: 'search_stmt', code: 'PREF_SRCH', pc: 'PREF_SEARCH_FUNC', desc: 'Prefer find( ) function over SEARCH' },
    { findingName: 'overlay_stmt', code: 'PREF_OVRLY', pc: 'PREF_OVERLAY_FUNC', desc: 'Prefer string templates over OVERLAY' },
    { findingName: 'replace_stmt', code: 'PREF_RPLC', pc: 'PREF_REPLACE_FUNC', desc: 'Prefer replace( ) function over REPLACE' },
    { findingName: 'describe_field', code: 'PREF_DSCFD', pc: 'PREF_DESCRIBE_FIELD', desc: 'Prefer describe_by_data( ) over DESCRIBE FIELD' }
  ]
};

// Single-finding abbreviation dictionary (ensures strictly <= 10 characters and starts with prefix)
const singleCodeOverrides = {
  'ZCL_SKYLINT_NO_BAD_INDENT': 'NO_BAD_IND',
  'ZCL_SKYLINT_NO_DUP_LITERALS': 'NO_DUP_LIT',
  'ZCL_SKYLINT_MAX_NESTING': 'MAX_NEST',
  'ZCL_SKYLINT_MAX_INHERIT': 'MAX_INHRT',
  'ZCL_SKYLINT_MAX_LINE_LEN': 'MAX_LINLEN',
  'ZCL_SKYLINT_MAX_RETURNS': 'MAX_RET',
  'ZCL_SKYLINT_NO_NESTED_TRY': 'NO_NESTTRY',
  'ZCL_SKYLINT_NO_NEG_COND': 'NO_NEG_CND',
  'ZCL_SKYLINT_NO_HUNGARIAN': 'NO_HUNGAR',
  'ZCL_SKYLINT_PREF_INSERT': 'PREF_INSRT',
  'ZCL_SKYLINT_PREF_CALC_OP': 'PREF_CALOP',
  'ZCL_SKYLINT_PREF_FILTER': 'PREF_FILTR',
  'ZCL_SKYLINT_NO_EMPTY_FAE': 'NO_EMPTFAE',
  'ZCL_SKYLINT_NO_CALL_METHOD': 'NO_CALL_MT',
  'ZCL_SKYLINT_NO_DEFAULT_KEY': 'NO_DEF_KEY',
  'ZCL_SKYLINT_NO_BOOL_COMPARE': 'NO_BOOL_CM',
  'ZCL_SKYLINT_NO_YODA_COND': 'NO_YODA_CN',
  'ZCL_SKYLINT_NO_DEAD_CODE': 'NO_DEAD_CD',
  'ZCL_SKYLINT_NO_ENDSELECT': 'NO_ENDSEL',
  'ZCL_SKYLINT_NO_DB_IN_LOOP': 'NO_DB_LOOP',
  'ZCL_SKYLINT_NO_CATCH_ROOT': 'NO_CAT_ROT',
  'ZCL_SKYLINT_NO_SY_MODIFY': 'NO_SY_MOD',
  'ZCL_SKYLINT_PREF_SWITCH': 'PREF_SWTCH',
  'ZCL_SKYLINT_PREF_RETURN': 'PREF_RET',
  'ZCL_SKYLINT_NO_CALL_EXPORTING': 'NO_CALL_EX',
  'ZCL_SKYLINT_NO_CALL_RECEIVING': 'NO_CALL_RC',
  'ZCL_SKYLINT_NO_CHAINED_ASSIGN': 'NO_CHN_ASG',
  'ZCL_SKYLINT_NO_CHAINED_DECL': 'NO_CHN_DCL',
  'ZCL_SKYLINT_NO_CLIENT_SPEC': 'NO_CLNT_SP',
  'ZCL_SKYLINT_NO_CONCAT_LOOP': 'NO_CC_LOOP',
  'ZCL_SKYLINT_NO_DASH_IN_FORM': 'NO_DASH_FM',
  'ZCL_SKYLINT_NO_DYNAMIC_STMT': 'NO_DYN_STM',
  'ZCL_SKYLINT_NO_EMPTY_OVERRIDE': 'NO_EMP_OVR',
  'ZCL_SKYLINT_NO_EXC_OVERLAP': 'NO_EXC_OVL',
  'ZCL_SKYLINT_NO_HARDCODED_ENV': 'NO_HARDENV',
  'ZCL_SKYLINT_NO_IDENT_CONT': 'NO_IDN_CNT',
  'ZCL_SKYLINT_NO_IGNORED_RETURN': 'NO_IGN_RET',
  'ZCL_SKYLINT_NO_INLINE_LEN': 'NO_INL_LEN',
  'ZCL_SKYLINT_NO_INSTANCE_OF': 'NO_INST_OF',
  'ZCL_SKYLINT_NO_KERNEL_CALL': 'NO_KERNEL',
  'ZCL_SKYLINT_NO_KEYWORD_NAME': 'NO_KWD_NAM',
  'ZCL_SKYLINT_NO_LATE_SYS_IDX': 'NO_LATE_SY',
  'ZCL_SKYLINT_NO_LIKE_OBJECTS': 'NO_LIKE_OB',
  'ZCL_SKYLINT_NO_LIST_PROC': 'NO_LIST_PR',
  'ZCL_SKYLINT_NO_MAGIC_NUMBERS': 'NO_MAGIC_N',
  'ZCL_SKYLINT_NO_MANY_PARENS': 'NO_MNY_PAR',
  'ZCL_SKYLINT_NO_ME_REFERENCE': 'NO_ME_REF',
  'ZCL_SKYLINT_NO_METAPROGRAMMING': 'NO_METAPRG',
  'ZCL_SKYLINT_NO_MIX_RETURNING': 'NO_MIX_RET',
  'ZCL_SKYLINT_NO_MOD_STD_TABLE': 'NO_MOD_STD',
  'ZCL_SKYLINT_NO_MSG_RAISING': 'NO_MSG_RSG',
  'ZCL_SKYLINT_NO_OBS_ARITH': 'NO_OBS_ART',
  'ZCL_SKYLINT_NO_OBS_CONTROL': 'NO_OBS_CTR',
  'ZCL_SKYLINT_NO_OBS_DECL': 'NO_OBS_DCL',
  'ZCL_SKYLINT_NO_OBS_MEMORY': 'NO_OBS_MEM',
  'ZCL_SKYLINT_NO_OBS_STRINGS': 'NO_OBS_STR',
  'ZCL_SKYLINT_NO_OVERW_BUILTIN': 'NO_OVR_BLT',
  'ZCL_SKYLINT_NO_PARAM_ESCAPE': 'NO_PARM_ES',
  'ZCL_SKYLINT_NO_PROD_ASSERT': 'NO_PRD_AST',
  'ZCL_SKYLINT_NO_RAISE_CX_SY': 'NO_RAIS_SY',
  'ZCL_SKYLINT_NO_RAISE_SHORTDUMP': 'NO_DUMP',
  'ZCL_SKYLINT_NO_SCOPE_LEAK': 'NO_SCP_LEK',
  'ZCL_SKYLINT_NO_SELECT_STAR': 'NO_SEL_STR',
  'ZCL_SKYLINT_NO_SINGLE_LETTER': 'NO_SGL_LTR',
  'ZCL_SKYLINT_NO_SINGLE_WHEN': 'NO_SGL_WHN',
  'ZCL_SKYLINT_NO_STATIC_ARROW': 'NO_STAT_AR',
  'ZCL_SKYLINT_NO_STATIC_CLS': 'NO_STAT_CL',
  'ZCL_SKYLINT_NO_UNFILT_DML': 'NO_UNF_DML',
  'ZCL_SKYLINT_NO_UNHANDLED_EML': 'NO_UNH_EML',
  'ZCL_SKYLINT_NO_UNNEC_RETURN': 'NO_UNN_RET',
  'ZCL_SKYLINT_NO_UNUSED_VARS': 'NO_UNUS_VR',
  'ZCL_SKYLINT_NO_USELESS_CONCAT': 'NO_USL_CAT',
  'ZCL_SKYLINT_PREF_AUTH_CHECK': 'PREF_AUTH',
  'ZCL_SKYLINT_PREF_AUTH_SUBRC': 'PREF_AUTHS',
  'ZCL_SKYLINT_PREF_CHECK_SUBRC': 'PREF_CHKSC',
  'ZCL_SKYLINT_PREF_CLASS_EXC': 'PREF_CLEXC',
  'ZCL_SKYLINT_PREF_COMPOSITION': 'PREF_COMPO',
  'ZCL_SKYLINT_PREF_CORRESP': 'PREF_CORR',
  'ZCL_SKYLINT_PREF_DOWNPORT': 'PREF_DWNPT',
  'ZCL_SKYLINT_PREF_EXPAND_MACRO': 'PREF_EXMAC',
  'ZCL_SKYLINT_PREF_FACTORY_NAME': 'PREF_FCTNM',
  'ZCL_SKYLINT_PREF_FINAL_DATA': 'PREF_FNDAT',
  'ZCL_SKYLINT_PREF_FULL_TYPED': 'PREF_TYPED',
  'ZCL_SKYLINT_PREF_INTF_SEGREG': 'PREF_INTFS',
  'ZCL_SKYLINT_PREF_IS_INITIAL': 'PREF_INIT',
  'ZCL_SKYLINT_PREF_IS_NOT': 'PREF_ISNOT',
  'ZCL_SKYLINT_PREF_IS_SUPPLIED': 'PREF_ISSUP',
  'ZCL_SKYLINT_PREF_JOIN_TYPE': 'PREF_JOINT',
  'ZCL_SKYLINT_PREF_MSG_CLS': 'PREF_MSGCL',
  'ZCL_SKYLINT_PREF_NAMING_VARS': 'PREF_NAMVR',
  'ZCL_SKYLINT_PREF_ORDER_BY': 'PREF_ORDBY',
  'ZCL_SKYLINT_PREF_PASS_BY_REF': 'PREF_PASRF',
  'ZCL_SKYLINT_PREF_PRED_NAME': 'PREF_PREDN',
  'ZCL_SKYLINT_PREF_PUB_CTOR': 'PREF_PBCTR',
  'ZCL_SKYLINT_PREF_RETURNING': 'PREF_RETNG',
  'ZCL_SKYLINT_PREF_STD_TABLE': 'PREF_STDTB',
  'ZCL_SKYLINT_PREF_STR_TMPL': 'PREF_STMPL',
  'ZCL_SKYLINT_PREF_SYMBOL_OP': 'PREF_SYMOP',
  'ZCL_SKYLINT_PREF_TRANSPORT': 'PREF_TRNSP',
  'ZCL_SKYLINT_PREF_XSDBOOL': 'PREF_XSDBL',
  'ZCL_SKYLINT_MAX_ATTRIBUTES': 'MAX_ATTR',
  'ZCL_SKYLINT_MAX_BOOL_EXPR': 'MAX_BOOL',
  'ZCL_SKYLINT_MAX_CYCLO_COMP': 'MAX_CYCLO',
  'ZCL_SKYLINT_MAX_ONE_STMT': 'MAX_1STMT'
};

function getSingleRuleProposal(clsName, ruleTitle) {
  const root = clsName.replace('ZCL_SKYLINT_', '');
  let pfx = '';
  if (root.startsWith('PREF_')) pfx = 'PREF_';
  else if (root.startsWith('NO_')) pfx = 'NO_';
  else if (root.startsWith('MAX_')) pfx = 'MAX_';
  
  // pseudo_comment: clean root, unlimited length
  const pc = root;
  
  // finding_code: check override first, else if <= 10 use directly, else truncate
  let code = singleCodeOverrides[clsName];
  if (!code) {
    if (root.length <= 10) {
      code = root;
    } else {
      const suffix = root.substring(pfx.length).replace(/_/g, '');
      code = (pfx + suffix).substring(0, 10);
    }
  }
  return [{ code, pc, desc: ruleTitle }];
}

// Build list for all 133 rules strictly from RULES
const processed = [];

for (const r of RULES) {
  const clsName = r.className;
  const filePath = path.join(checksDir, clsName.toLowerCase() + '.clas.abap');
  if (!fs.existsSync(filePath)) {
    throw new Error('Class file not found: ' + filePath);
  }
  
  let findings = [];
  if (multiFindings[clsName]) {
    findings = multiFindings[clsName];
  } else {
    findings = getSingleRuleProposal(clsName, r.title);
  }
  
  processed.push({
    ruleId: r.ruleId,
    title: r.title,
    category: r.category,
    clsName,
    findings
  });
}

// Verification checks
console.log('Total rules loaded:', processed.length);

const codeErrors = [];
for (const p of processed) {
  for (const f of p.findings) {
    if (f.code.length > 10) {
      codeErrors.push(p.clsName + ': code ' + f.code + ' exceeds 10 chars (' + f.code.length + ')');
    }
    if (!f.code.startsWith('PREF_') && !f.code.startsWith('NO_') && !f.code.startsWith('MAX_')) {
      codeErrors.push(p.clsName + ': code ' + f.code + ' does not start with PREF_/NO_/MAX_');
    }
  }
}

if (codeErrors.length > 0) {
  console.error('Code validation errors:', codeErrors);
  process.exit(1);
}

// Generate Markdown Artifact
const categoryTitles = {
  'clean-abap': '1. Clean ABAP (49 Kural)',
  'anti-patterns': '2. Anti-Patterns (49 Kural)',
  'metrics': '3. Metrics (10 Kural)',
  'performance': '4. Performance (9 Kural)',
  'security': '5. Security (16 Kural)'
};

const cats = ['clean-abap', 'anti-patterns', 'metrics', 'performance', 'security'];

let md = '# 📋 Skylint 133 Kural Standardizasyon Tablosu (finding_code & pseudo_comment)\n\n';
md += '> Bu tablo, kod tabanındaki 133 kuralın tamamında (`src/checks/*.clas.abap` ve `scripts/rules-data.mjs` kaynaklarından doğrulanarak) oluşturulmuştur.\n';
md += '> Her kural için SAP ATC uyumlu `finding_code` (maksimum 10 karakter, `PREF_*`, `NO_*`, `MAX_*` önekli) ve sınırsız karakterli, açıklayıcı `pseudo_comment` listelenmiştir.\n\n';

for (const cat of cats) {
  const catRules = processed.filter(r => r.category === cat);
  md += '## ' + categoryTitles[cat] + '\n\n';
  md += '| # | Sınıf Adı (`class_name`) | Kural Başlığı | `finding_code` (<=10) | `pseudo_comment` (Sınırsız) | Bastırma Sözdizimi (`#EC`) |\n';
  md += '|---|---------------------------|---------------|-----------------------|------------------------------|-----------------------------|\n';
  
  let idx = 1;
  for (const r of catRules) {
    for (let i = 0; i < r.findings.length; i++) {
      const f = r.findings[i];
      const clsCol = i === 0 ? '`' + r.clsName + '`' : '↳ *(aynı kural)*';
      const numCol = i === 0 ? String(idx) : '';
      // Escape pipes in descriptions if any
      const safeDesc = f.desc.replace(/\|/g, '\\|');
      md += '| ' + numCol + ' | ' + clsCol + ' | ' + safeDesc + ' | `' + f.code + '` | `' + f.pc + '` | `"#EC ' + f.pc + '` |\n';
    }
    idx++;
  }
  md += '\n';
}

const outPath = '/Users/furkancosgun/.gemini/antigravity/brain/f83b9974-a04c-4be8-b229-7814f1a4972e/rules_standardization_table.md';
fs.writeFileSync(outPath, md, 'utf8');
console.log('Successfully written clean table to:', outPath);
