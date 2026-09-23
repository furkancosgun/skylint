# Core - Skylint Infrastructure

- `base/`: ATC check base class (`zcl_skylint_check_base`), metadata handler (`zcl_skylint_check_meta_data`) & dependency injection factory (`zcl_skylint_factory`)
- `ast/`: Token navigation (`zif_skylint_token_navigator`), operator utilities (`zif_skylint_operator_util`) & fluent token stream query engine (`zcl_skylint_token_stream`)
- `formatter/`: Code formatting, flattening & line breaking (`zif_skylint_code_formatter`, `zcl_skylint_code_formatter`)
- `reporter/`: Finding reporter interface (`zif_skylint_reporter`) & location/checksum/pseudo-comment processor (`zcl_skylint_reporter`)
- `quickfix/`: QuickFix builder interface (`zif_skylint_quickfix`) & code replacement engine (`zcl_skylint_quickfix`)
- `common/`: Shared types & enumerations (`zif_skylint_types`) and core exception class (`zcx_skylint_error`)
