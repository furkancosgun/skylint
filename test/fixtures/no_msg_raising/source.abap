FORM test_001.
    MESSAGE e001(00) WITH 'test' RAISING error.
ENDFORM.

FORM test_002.
    MESSAGE 'clean' TYPE 'I'.
ENDFORM.

FORM test_003.
    MESSAGE w001(00) WITH 'warn' RAISING error.
ENDFORM.

FORM test_004.
    MESSAGE s001(00) WITH 'ok'.
ENDFORM.

FORM test_005.
    DATA !raising TYPE string.
    !raising = 'x'.
    MESSAGE s001(00) WITH !raising.
ENDFORM.
