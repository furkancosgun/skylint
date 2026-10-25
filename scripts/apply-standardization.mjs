import fs from 'fs';
import path from 'path';
import { RULES } from '/Users/furkancosgun/Downloads/skylint/scripts/rules-data.mjs';

const checksDir = '/Users/furkancosgun/Downloads/skylint/src/checks';
const fixturesDir = '/Users/furkancosgun/Downloads/skylint/test/fixtures';

const multiConfigs = {
  'ZCL_SKYLINT_MAX_METHOD_LEN': {
    codes: { method_length: 'MAX_METH_L', constructor_logic: 'MAX_CTOR' },
    pcs: { c_pseudo_comment: 'MAX_METHOD_LEN', c_pseudo_comment_ctor: 'MAX_CTOR_LOGIC' }
  },
  'ZCL_SKYLINT_MAX_PARAMS': {
    codes: { too_many_parameters: 'MAX_PARAMS', multiple_params: 'MAX_PARM_L' },
    pcs: { c_pseudo_comment: 'MAX_PARAMS_COUNT', c_pseudo_comment_line: 'MAX_PARAMS_LINE' }
  },
  'ZCL_SKYLINT_NO_CHECK_STMT': {
    codes: { check_in_loop: 'NO_CHK_LP', check_outside_loop: 'NO_CHK_OUT' },
    pcs: { check_in_loop: 'NO_CHECK_IN_LOOP', check_outside_loop: 'NO_CHECK_OUTSIDE_LOOP' }
  },
  'ZCL_SKYLINT_NO_DUP_COND': {
    codes: { identical_condition: 'NO_DUP_CND', duplicate_operand: 'NO_DUP_OPR' },
    pcs: { c_pseudo_comment: 'NO_DUP_COND' }
  },
  'ZCL_SKYLINT_NO_EMPTY_BLOCK': {
    codes: { empty_control_block: 'NO_EMPTY_B', try_without_catch: 'NO_TRY_WO' },
    pcs: { c_pseudo_comment: 'NO_EMPTY_BLOCK' }
  },
  'ZCL_SKYLINT_NO_EXPOSED_DATA': {
    codes: { public_attribute: 'NO_PUB_ATR', interface_data: 'NO_INTF_DA' },
    pcs: { c_pseudo_comment_attr: 'NO_PUBLIC_ATTR', c_pseudo_comment_intf: 'NO_INTERFACE_DATA' }
  },
  'ZCL_SKYLINT_NO_MOD_LOOP_TAB': {
    codes: { modify_loop_table: 'NO_MOD_LTB', sort_in_loop: 'NO_SORT_LP' },
    pcs: { c_pseudo_comment: 'NO_MOD_LOOP_TAB' }
  },
  'ZCL_SKYLINT_NO_REDUN_ASSIGN': {
    codes: { identical_move: 'NO_IDN_MOV', redundant_clear: 'NO_RED_CLR', clear_at_end: 'NO_CLR_END' },
    pcs: { c_pseudo_comment_self: 'NO_IDENTICAL_MOVE', c_pseudo_comment_clear: 'NO_REDUNDANT_CLEAR' }
  },
  'ZCL_SKYLINT_PREF_DECLARATIONS': {
    codes: { definitions_top: 'PREF_TOP', decl_order: 'PREF_ORDER' },
    pcs: { c_pseudo_comment_top: 'PREF_DEFINITIONS_TOP', c_pseudo_comment_order: 'PREF_DECLARATION_ORDER' }
  },
  'ZCL_SKYLINT_PREF_DOWNCAST': {
    codes: { prefer_cast: 'PREF_CAST', inline_cast: 'PREF_INLCS' },
    pcs: { c_pseudo_comment_cast: 'PREF_DOWNCAST', c_pseudo_comment_inl: 'PREF_INLINE_CAST' }
  },
  'ZCL_SKYLINT_PREF_EARLY_RET': {
    codes: { guard_method: 'PREF_GRDMT', guard_loop: 'PREF_GRDLP' },
    pcs: { early_return: 'PREF_GUARD_METHOD', early_continue: 'PREF_GUARD_LOOP' }
  },
  'ZCL_SKYLINT_PREF_FINAL_CLS': {
    codes: { class_not_final: 'PREF_FCLS', method_not_final: 'PREF_FMETH' },
    pcs: { final_cls: 'PREF_FINAL_CLASS', final_meth: 'PREF_FINAL_METHOD' }
  },
  'ZCL_SKYLINT_PREF_MERGE_IFS': {
    codes: { nested_if: 'PREF_MRGIF', else_if: 'PREF_ELSIF' },
    pcs: { c_pseudo_comment: 'PREF_MERGE_IFS' }
  },
  'ZCL_SKYLINT_PREF_NAME_MEMBERS': {
    codes: { class_attribute: 'PREF_NMATR', method_parameter: 'PREF_NMPAR', selection_screen: 'PREF_NAMSS' },
    pcs: { c_pseudo_comment: 'PREF_NAME_MEMBERS' }
  },
  'ZCL_SKYLINT_PREF_NAME_OBJECTS': {
    codes: {
      local_class: 'PREF_LCLS', global_class: 'PREF_GCLS', local_interface: 'PREF_LINTF', global_interface: 'PREF_GINTF',
      types: 'PREF_TYP', event: 'PREF_EVT', test_method: 'PREF_TMETH', macro: 'PREF_MACRO', form: 'PREF_FORM',
      function_module: 'PREF_FUNC', function_group: 'PREF_FUGR', program: 'PREF_PROG'
    },
    pcs: { c_pseudo_comment: 'PREF_NAME_OBJECTS' }
  },
  'ZCL_SKYLINT_PREF_NEW_OP': {
    codes: { prefer_new: 'PREF_NEW', raise_exception_new: 'PREF_RSNEW' },
    pcs: { new_op: 'PREF_NEW_OPERATOR', raise_new: 'PREF_RAISE_EXC_NEW' }
  },
  'ZCL_SKYLINT_PREF_PARAM_NAME': {
    codes: { omit_param: 'PREF_OMIT', require_param: 'PREF_REQ_P' },
    pcs: { c_pseudo_comment: 'PREF_PARAM_NAME' }
  },
  'ZCL_SKYLINT_PREF_READ_TABLE': {
    codes: { prefer_tab_expr: 'PREF_TABEX', prefer_line_exists: 'PREF_LNEXS' },
    pcs: { c_pseudo_comment_expr: 'PREF_TABLE_EXPR', c_pseudo_comment_line: 'PREF_LINE_EXISTS' }
  },
  'ZCL_SKYLINT_PREF_STR_FUNC': {
    codes: {
      condense_stmt: 'PREF_CNDNS', translate_stmt: 'PREF_TRNSL', shift_stmt: 'PREF_SHIFT',
      search_stmt: 'PREF_SRCH', overlay_stmt: 'PREF_OVRLY', replace_stmt: 'PREF_RPLC', describe_field: 'PREF_DSCFD'
    },
    pcs: { c_pseudo_comment: 'PREF_STR_FUNC' }
  }
};

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

const isExecute = process.argv.includes('--execute');

console.log('Mode: ' + (isExecute ? 'EXECUTE (Modifying files)' : 'DRY-RUN (Simulating)'));

let abapModified = 0;
let xmlModified = 0;
let expModified = 0;
let srcModified = 0;

for (const rule of RULES) {
  const clsName = rule.className;
  const fixtureName = rule.ruleId.replace(/-/g, '_');
  const abapFile = path.join(checksDir, clsName.toLowerCase() + '.clas.abap');
  const xmlFile = path.join(checksDir, clsName.toLowerCase() + '.clas.xml');
  const expFile = path.join(fixturesDir, fixtureName, 'expected.json');
  const srcFile = path.join(fixturesDir, fixtureName, 'source.abap');
  
  if (!fs.existsSync(abapFile)) continue;
  
  let abapContent = fs.readFileSync(abapFile, 'utf8');
  let originalAbap = abapContent;
  
  const codeMap = {}; // old_code -> new_code
  const pcMap = {};   // old_pc -> new_pc
  
  if (multiConfigs[clsName]) {
    const cfg = multiConfigs[clsName];
    // Update finding codes in BEGIN OF c_finding_codes ... END OF c_finding_codes.
    const fcMatch = abapContent.match(/BEGIN OF c_finding_codes[\s\S]*?END OF c_finding_codes\./i);
    if (fcMatch) {
      let block = fcMatch[0];
      let newBlock = block;
      for (const [field, newCode] of Object.entries(cfg.codes)) {
        const reField = new RegExp(`(${field}\\s+TYPE\\s+if_ci_atc_check=>ty_finding_code\\s+VALUE\\s+)'([^']+)'`, 'i');
        const m = block.match(reField);
        if (m) {
          const oldCode = m[2];
          codeMap[oldCode] = newCode;
          newBlock = newBlock.replace(m[0], `${m[1]}'${newCode}'`);
        }
      }
      abapContent = abapContent.replace(block, newBlock);
    }
    
    // Update pseudo comments
    for (const [varName, newPc] of Object.entries(cfg.pcs)) {
      // Check individual CONSTANTS varName TYPE string VALUE 'OLD'
      const reSingle = new RegExp(`(CONSTANTS\\s+${varName}\\s+TYPE\\s+string\\s+VALUE\\s+)'([^']+)'`, 'i');
      const mSingle = abapContent.match(reSingle);
      if (mSingle) {
        const oldPc = mSingle[2];
        pcMap[oldPc] = newPc;
        abapContent = abapContent.replace(mSingle[0], `${mSingle[1]}'${newPc}'`);
      } else {
        // Check in struct BEGIN OF c_pseudo_comments
        const reStruct = new RegExp(`(${varName}\\s+TYPE\\s+string\\s+VALUE\\s+)'([^']+)'`, 'i');
        const mStruct = abapContent.match(reStruct);
        if (mStruct) {
          const oldPc = mStruct[2];
          pcMap[oldPc] = newPc;
          abapContent = abapContent.replace(mStruct[0], `${mStruct[1]}'${newPc}'`);
        }
      }
    }
  } else {
    // Single finding class
    const root = clsName.replace('ZCL_SKYLINT_', '');
    let pfx = '';
    if (root.startsWith('PREF_')) pfx = 'PREF_';
    else if (root.startsWith('NO_')) pfx = 'NO_';
    else if (root.startsWith('MAX_')) pfx = 'MAX_';
    
    const newPc = root;
    let newCode = singleCodeOverrides[clsName];
    if (!newCode) {
      if (root.length <= 10) newCode = root;
      else {
        const suffix = root.substring(pfx.length).replace(/_/g, '');
        newCode = (pfx + suffix).substring(0, 10);
      }
    }
    
    // Update finding code
    const fcMatch = abapContent.match(/BEGIN OF c_finding_codes[\s\S]*?END OF c_finding_codes\./i);
    if (fcMatch) {
      let block = fcMatch[0];
      const m = block.match(/(\w+\s+TYPE\s+if_ci_atc_check=>ty_finding_code\s+VALUE\s+)'([^']+)'/i);
      if (m) {
        const oldCode = m[2];
        codeMap[oldCode] = newCode;
        const newBlock = block.replace(m[0], `${m[1]}'${newCode}'`);
        abapContent = abapContent.replace(block, newBlock);
      }
    }
    
    // Update pseudo comment
    const pcSingle = abapContent.match(/(CONSTANTS\s+c_pseudo_comment\s+TYPE\s+string\s+VALUE\s+)'([^']+)'/i);
    if (pcSingle) {
      const oldPc = pcSingle[2];
      pcMap[oldPc] = newPc;
      abapContent = abapContent.replace(pcSingle[0], `${pcSingle[1]}'${newPc}'`);
    }
  }
  
  // Clean constructor description: remove any skylint:\s*
  const descMatch = abapContent.match(/description\s*=\s*'skylint:\s*([^']+)'/i);
  if (descMatch) {
    abapContent = abapContent.replace(descMatch[0], `description       = '${descMatch[1]}'`);
  }
  
  if (abapContent !== originalAbap) {
    abapModified++;
    if (isExecute) {
      fs.writeFileSync(abapFile, abapContent, 'utf8');
    }
  }
  
  // Clean XML: ensure skylint: prefix
  if (fs.existsSync(xmlFile)) {
    let xmlContent = fs.readFileSync(xmlFile, 'utf8');
    let originalXml = xmlContent;
    const xmlDescMatch = xmlContent.match(/<DESCRIPT>([^<]+)<\/DESCRIPT>/);
    if (xmlDescMatch) {
      let descText = xmlDescMatch[1].trim();
      if (!descText.toLowerCase().startsWith('skylint:')) {
        descText = 'skylint: ' + descText;
        xmlContent = xmlContent.replace(xmlDescMatch[0], `<DESCRIPT>${descText}</DESCRIPT>`);
      }
      if (xmlContent !== originalXml) {
        xmlModified++;
        if (isExecute) {
          fs.writeFileSync(xmlFile, xmlContent, 'utf8');
        }
      }
    }
  }
  
  // Update expected.json
  if (fs.existsSync(expFile)) {
    let expContent = fs.readFileSync(expFile, 'utf8');
    let originalExp = expContent;
    for (const [oldCode, newCode] of Object.entries(codeMap)) {
      if (oldCode !== newCode) {
        const reCode = new RegExp(`"code":\\s*"${oldCode}"`, 'g');
        expContent = expContent.replace(reCode, `"code": "${newCode}"`);
      }
    }
    if (expContent !== originalExp) {
      expModified++;
      if (isExecute) {
        fs.writeFileSync(expFile, expContent, 'utf8');
      }
    }
  }
  
  // Update source.abap
  if (fs.existsSync(srcFile)) {
    let srcContent = fs.readFileSync(srcFile, 'utf8');
    let originalSrc = srcContent;
    for (const [oldPc, newPc] of Object.entries(pcMap)) {
      if (oldPc !== newPc) {
        const rePc = new RegExp(`"#EC\\s+${oldPc}\\b`, 'g');
        srcContent = srcContent.replace(rePc, `"#EC ${newPc}`);
      }
    }
    if (srcContent !== originalSrc) {
      srcModified++;
      if (isExecute) {
        fs.writeFileSync(srcFile, srcContent, 'utf8');
      }
    }
  }
}

console.log('Classes to update:', abapModified);
console.log('XML files to update:', xmlModified);
console.log('expected.json files to update:', expModified);
console.log('source.abap files to update:', srcModified);
