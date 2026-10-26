CLASS zcl_skylint_test_max_cognitive DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_skylint_test_max_cognitive IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      lv_x = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      IF lv_x = 2.
        IF lv_x = 3.
          IF lv_x = 4.
            IF lv_x = 5.
              IF lv_x = 6.
                lv_x = 7.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      IF lv_x = 2.
        IF lv_x = 3.
          IF lv_x = 4.
            IF lv_x = 5.
              IF lv_x = 6.
                lv_x = 7.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_val  TYPE i.
    DATA lv_idx  TYPE i.
    DATA lx_root TYPE REF TO cx_root.

    DO 5 TIMES.
      WHILE lv_idx < 10.
        LOOP AT lt_data INTO lv_val.
          IF ( lv_val > 0 ) AND ( lv_val < 100 ).
            TRY.
                IF ( lv_val = 50 ) OR ( lv_val = 60 ).
                  lv_val = lv_val * 2.
                ELSE.
                  lv_val = lv_val + 1.
                ENDIF.
              CATCH cx_root INTO lx_root.
                lv_val = 0.
            ENDTRY.
          ENDIF.
        ENDLOOP.
      ENDWHILE.
    ENDDO.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_val  TYPE i.
    DATA lv_flag TYPE abap_bool.

    LOOP AT lt_data INTO lv_val.
      IF ( lv_val > 10 ) AND ( lv_val < 50 ).
        IF ( lv_flag = abap_true ).
          lv_val = lv_val + 1.
        ELSE.
          lv_val = lv_val - 1.
        ENDIF.
      ELSEIF ( lv_val = 0 ) OR ( lv_val = 99 ).
        lv_val = 0.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.

    CASE lv_a.
      WHEN 1.
        CASE lv_b.
          WHEN 10.
            IF ( lv_c = 1 ) AND ( lv_a = 2 ).
              IF ( lv_b > 5 ) OR ( lv_c < 0 ).
                lv_c = 100.
              ENDIF.
            ENDIF.
          WHEN 20.
            lv_c = 200.
        ENDCASE.
      WHEN 2.
        lv_c = 300.
    ENDCASE.
  ENDMETHOD.

  METHOD test_007. "#EC MAX_COGNITIVE
    DATA lv_x TYPE i.
    IF lv_x = 1.
      IF lv_x = 2.
        IF lv_x = 3.
          IF lv_x = 4.
            IF lv_x = 5.
              IF lv_x = 6.
                IF lv_x = 7.
                  lv_x = 8.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.

    CASE lv_a.
      WHEN 1.
        CASE lv_b.
          WHEN 10.
            IF ( lv_c = 1 ) AND ( lv_a = 2 ).
              IF ( lv_b > 5 ) OR ( lv_c < 0 ).
                lv_c = 100.
              ENDIF.
            ENDIF.
          WHEN 20.
            lv_c = 200.
        ENDCASE.
      WHEN 2.
        lv_c = 300.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
