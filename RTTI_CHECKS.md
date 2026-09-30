# 🧭 Skylint RTTI Kuralları ve Geliştirme Rehberi (`RTTI_CHECKS.md`)

Bu doküman, **Skylint** bünyesinde **Run-Time Type Identification (RTTI)** ve semantik tip analizi ile yeniden yazılması / güçlendirilmesi planlanan 10 kuralı içerir. 

Her kural için mevcut kod parçası ve önerilen RTTI analiz şablonu eklenmiştir. **"✍️ Senin Yorumların & Uygulama Talimatların"** kısımlarına dilediğin gibi notlarını, özel senaryoları veya geliştirme talimatlarını yazabilirsin. Üzerinden birlikte geçip adım adım uygulayacağız.

---

## 🏛️ RTTI Kullanımında Altın Standartlar (`AGENTS.md`)

Open-ABAP transpiler ve SAP ATC Cloud ortamında RTTI çalıştırırken dikkat edilmesi gereken temel prensipler:
1. **Güvenli Çağrı (`TRY ... CATCH cx_root`):** Yerel veya test tiplerinde `cl_abap_typedescr=>describe_by_name( lv_name )` çağrıları runtime hatası fırlatabileceğinden mutlaka `TRY ... CATCH cx_root` bloğu içinde olmalıdır.
2. **Doğru Tip Dönüşümü:** Sınıflar için `cl_abap_classdescr`, arayüzler için `cl_abap_objectdescr`, tablolar için `cl_abap_tabledescr` downcast edilmelidir.
3. **Konstant ve Enum Kullanımı:** `cl_abap_typedescr=>kind_class`, `cl_abap_classdescr=>public`, `cl_abap_classdescr=>protected` gibi sabitler kullanılmalıdır.

---

## 📋 RTTI Geliştirme Listesi

### 1. [zcl_skylint_check_026](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_026.clas.abap) — Avoid calling static methods via instance arrow (`->`)
* **Açıklama:** Statik metotların `instance->static_meth( )` şeklinde çağrılmasını engelleyip `class=>static_meth( )` kullanımını zorunlu kılar.
* **Mevcut TODO:** `"TODO bu kural mutlaka compiler + rtti seviyesine method toplama olmamamli"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      collect_static_methods( is_procedure ). " Sınıf tanımından statik metotları manuel topluyor
    ELSE.
      inspect_procedure( is_procedure ).
    ENDIF.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI / Compiler Yaklaşımı:
```abap
DATA lo_descr TYPE REF TO cl_abap_typedescr.
DATA lo_class TYPE REF TO cl_abap_classdescr.
DATA ls_method TYPE abap_methdescr.

TRY.
    lo_descr = cl_abap_typedescr=>describe_by_name( lv_class_name ).
    IF lo_descr->kind = cl_abap_typedescr=>kind_class.
      lo_class ?= lo_descr.
      READ TABLE lo_class->methods INTO ls_method
           WITH KEY name = to_upper( lv_meth_name ).
      IF sy-subrc = 0 AND ls_method-is_class = abap_true.
        " Metodun static (CLASS-METHODS) olduğu RTTI ile kesinleşti!
      ENDIF.
    ENDIF.
  CATCH cx_root.
ENDTRY.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:
bu şimdilik kalsın bakacağım buna

---

### 2. [zcl_skylint_check_027](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_027.clas.abap) — Avoid mutable public attributes in classes
* **Açıklama:** Sınıflarda `PUBLIC` erişimli ve değiştirilebilir (`READ-ONLY` veya `CONSTANT` olmayan) değişken tanımlarını engeller.
* **Mevcut TODO:** `"TODO rtti seviyesinde kontrol etmek cok daha kolay gibi dusunelim"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    " Manuel olarak PUBLIC / PRIVATE bloklarını ve DATA satırlarını geziyor
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PUBLIC'.
          lv_in_public = abap_true.
        WHEN 'DATA' OR 'CLASS-DATA'.
          IF lv_in_public = abap_true AND is_read_only( <ls_statement> ) = abap_false.
            report_statement( is_statement = <ls_statement> ... ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı:
```abap
DATA lo_descr TYPE REF TO cl_abap_typedescr.
DATA lo_class TYPE REF TO cl_abap_classdescr.
DATA ls_attr  TYPE abap_attrdescr.

TRY.
    lo_descr = cl_abap_typedescr=>describe_by_name( is_procedure-id-name ).
    IF lo_descr->kind = cl_abap_typedescr=>kind_class.
      lo_class ?= lo_descr.
      LOOP AT lo_class->attributes INTO ls_attr
           WHERE visibility = cl_abap_classdescr=>public
             AND is_read_only = abap_false
             AND is_constant  = abap_false.
        " Public mutable attribute doğrudan RTTI'dan yakalandı!
      ENDLOOP.
    ENDIF.
  CATCH cx_root.
ENDTRY.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:

mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 3. [zcl_skylint_check_036](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_036.clas.abap) — Omit parameter name in single parameter method call
* **Açıklama:** Tek bir parametre alan metot çağrılarında parametre adının yazılmasını engelleyip doğrudan değer geçilmesini teşvik eder (`lo->do( iv_val = 1 )` yerine `lo->do( 1 )`).
* **Mevcut TODO:** `"TODO bu kuralda compiler seviyesine cikarilsin + rtti ile desteklensin manuel parametre toplanmasin"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD has_single_named_param.
    " Parantez içindeki parametreleri ve eşittir '=' işaretlerini manuel token indeksleriyle sayıyor
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      ...
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI / Compiler Yaklaşımı:
```abap
" Hedef metodun parametre listesini RTTI ile çekip gerçekten sadece 1 zorunlu parametresi var mı doğrulanır:
DATA lo_class TYPE REF TO cl_abap_classdescr.
DATA lt_params TYPE abap_parmbind_tab.
DATA ls_meth   TYPE abap_methdescr.

READ TABLE lo_class->methods INTO ls_meth WITH KEY name = lv_meth_name.
IF sy-subrc = 0 AND lines( ls_meth-parameters ) = 1.
  " Tek parametreli metot tespiti!
ENDIF.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:
> *(Buraya yorumlarını ve nasıl yapmak istediğini yazabilirsin)*

---

### 4. [zcl_skylint_check_042](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_042.clas.abap) — Prefer RETURNING over single EXPORTING
* **Açıklama:** Yalnızca tek bir `EXPORTING` parametresi olan metotların fonksiyonel `RETURNING` parametresine dönüştürülmesini önerir.
* **Mevcut TODO:** `"TODO compiler + rtti ile yeniden yazalim"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD is_single_exporting_only.
    " Token akışında EXPORTING, IMPORTING, CHANGING kelimelerini sayıyor
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      ...
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı:
```abap
DATA lo_class TYPE REF TO cl_abap_classdescr.
DATA ls_meth  TYPE abap_methdescr.
DATA lv_exp_cnt TYPE i.

" Metot imzasını RTTI method metadata tablosundan doğrudan okuma:
LOOP AT lo_class->methods INTO ls_meth.
  " ls_meth-parameters tablosunda parm_kind = 'E' (Exporting), 'R' (Returning) sayıları kontrol edilir
ENDLOOP.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:
mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 5. [zcl_skylint_check_055](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_055.clas.abap) — Avoid static-only classes
* **Açıklama:** Sadece static metot ve özelliklerden oluşan sınıfların nesne yönelimli (instantiable / interface-based) tasarıma dönüştürülmesini denetler.
* **Mevcut TODO:** `"TODO rtti + compiler guvenelim"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    " Sınıf içerisindeki METHODS ve CLASS-METHODS satırlarını sayıyor
    IF <ls_statement>-keyword = 'METHODS'.
      lv_has_instance_meth = abap_true.
    ELSEIF <ls_statement>-keyword = 'CLASS-METHODS'.
      lv_static_meth_cnt += 1.
    ENDIF.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı:
```abap
DATA lo_class TYPE REF TO cl_abap_classdescr.

" lo_class->methods ve lo_class->attributes tablolarındaki tüm üyelerin
" is_class = abap_true olup olmadığını kontrol etme:
IF lines( lo_class->methods ) > 0 AND
   NOT line_exists( lo_class->methods[ is_class = abap_false ] ).
  " Sınıf tamamen statik metotlardan oluşuyor!
ENDIF.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:
mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 6. [zcl_skylint_check_056](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_056.clas.abap) — Enforce predicate naming on boolean methods
* **Açıklama:** `RETURNING` parametresi boolean (`abap_bool`, `flag` vb.) olan metotların `IS_`, `HAS_`, `CAN_` önekleriyle başlamasını zorunlu kılar.
* **Mevcut TODO:** `"TODO bu kural compiler + rtti ile yeniden yazilsin"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    " Statement içindeki RETURNING kelimesini ve devamındaki TYPE ABAP_BOOL string eşleşmesini arıyor
    LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
      IF to_upper( <ls_token>-lexeme ) = 'ABAP_BOOL'.
        lv_is_bool_returning = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı:
```abap
DATA lo_class TYPE REF TO cl_abap_classdescr.
DATA ls_meth  TYPE abap_methdescr.
DATA ls_param TYPE abap_parmdescr.

" Metodun RETURNING parametresinin RTTI tip tanımını (ABAP_BOOL / CHAR1) kesin olarak doğrulama:
TRY.
    " lo_class->get_method_parameter_type() veya ls_meth-parameters kontrolü
  CATCH cx_root.
ENDTRY.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:

mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 7. [zcl_skylint_check_057](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_057.clas.abap) — Avoid deep class inheritance hierarchies (> 3 levels)
* **Açıklama:** 3 seviyeden daha derin sınıf kalıtım ağaçlarını tespit eder (kompozisyon kalıtıma tercih edilmelidir).
* **Mevcut TODO:** `"TODO bu kural compiler + rtti ile yeniden yazilsin"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    " INHERITING FROM kelimesini string olarak arıyor, üst sınıfa geçemiyor (sadece tek seviye bakabiliyor)
    IF to_upper( ls_token-lexeme ) = 'INHERITING'.
      ...
    ENDIF.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı (`AGENTS.md` Şablonu):
```abap
DATA lo_descr TYPE REF TO cl_abap_typedescr.
DATA lo_class TYPE REF TO cl_abap_classdescr.
DATA lo_super TYPE REF TO cl_abap_classdescr.
DATA lv_depth TYPE i.

TRY.
    lo_descr = cl_abap_typedescr=>describe_by_name( lv_class_name ).
    IF lo_descr->kind = cl_abap_typedescr=>kind_class.
      lo_class ?= lo_descr.
      lo_super = lo_class->get_super_class_type( ).
      lv_depth = 0.
      WHILE lo_super IS BOUND.
        lv_depth += 1.
        lo_super = lo_super->get_super_class_type( ).
      ENDWHILE.

      IF lv_depth > mv_max_depth.
        " Kalıtım derinliği aşıldı!
      ENDIF.
    ENDIF.
  CATCH cx_root.
ENDTRY.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:

mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 8. [zcl_skylint_check_058](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_058.clas.abap) — Limit number of member attributes in a class (God Class smell)
* **Açıklama:** Bir sınıftaki toplam üye değişken sayısını sınırlar (aşırı attribute içeren God Class anti-pattern'ı önler).
* **Mevcut TODO:** `"TODO bu kural compiler + rtti ile yeniden yazilsin"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    " Sınıf tanımındaki DATA ve CLASS-DATA statement'larını sayıyor
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'DATA' OR <ls_statement>-keyword = 'CLASS-DATA'.
        lv_attr_count += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı:
```abap
DATA lo_class TYPE REF TO cl_abap_classdescr.

" Doğrudan lo_class->attributes tablosunun satır sayısını alma:
IF lines( lo_class->attributes ) > mv_max_attributes.
  " Limit aşıldı!
ENDIF.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:

mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 9. [zcl_skylint_check_059](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_059.clas.abap) — Avoid mutable DATA declarations in interfaces
* **Açıklama:** Arayüzlerde (INTERFACE) değiştirilebilir `DATA` tanımlarını engeller; yalnızca `CONSTANTS` kullanımına izin verir.
* **Mevcut TODO:** `"TODO bu kural compiler + rtti ile yeniden yazilsin"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'INTERFACE'.
        lv_in_interface = abap_true.
      ELSEIF lv_in_interface = abap_true AND <ls_statement>-keyword = 'DATA'.
        report_statement( is_statement = <ls_statement> ... ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI Yaklaşımı:
```abap
DATA lo_intf TYPE REF TO cl_abap_objectdescr.
DATA ls_attr TYPE abap_attrdescr.

" Interface RTTI tanımlamasında is_constant = abap_false olan attribute tespiti
TRY.
    lo_intf ?= cl_abap_typedescr=>describe_by_name( iv_intf_name ).
    LOOP AT lo_intf->attributes INTO ls_attr WHERE is_constant = abap_false.
      " Mutable interface data tespit edildi!
    ENDLOOP.
  CATCH cx_root.
ENDTRY.
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:

mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu

---

### 10. [zcl_skylint_check_071](file:///Users/furkancosgun/Downloads/skylint/src/checks/zcl_skylint_check_071.clas.abap) — Prefer marking non-overridden methods as FINAL
* **Açıklama:** Alt sınıflarda ezilmeyen (redefine edilmeyen) metotların `FINAL` olarak işaretlenmesini önerir.
* **Mevcut TODO:** `"TODO rtti uzerinden cozebiliriz diye dusunuyorum kontorl edelim"`

#### 🔍 Mevcut Kod Parçası:
```abap
  METHOD check.
    LOOP AT is_procedure-statements ASSIGNING <ls_statement> WHERE keyword = 'METHODS'.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        CASE to_upper( <ls_token>-lexeme ).
          WHEN 'FINAL'.
            lv_has_final = abap_true.
          WHEN 'REDEFINITION' OR 'ABSTRACT' OR 'TESTING' OR 'CONSTRUCTOR'.
            lv_is_special = abap_true.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
```

#### 💡 Önerilen RTTI / Analiz Yaklaşımı:
```abap
" Sınıfın FINAL olup olmadığı veya alt sınıflarda redefinition bulunup bulunmadığı
" RTTI ve alt sınıf türetim zinciriyle incelenebilir:
DATA lo_class TYPE REF TO cl_abap_classdescr.
IF lo_class->create_protected = abap_true ...
```

> #### ✍️ Senin Yorumların & Uygulama Talimatların:

mantık doğru kanka sınıf adına bu şekilde erişebilirsin

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    id-main_unit-name = sınıf adı geliyor kanka bu şekilde halledersin bunu
---

## 🚀 Sonraki Adım
Bu dosyayı (`RTTI_CHECKS.md`) inceleyip yorumlarını ekledikten sonra bana haber ver; belirlediğin sırayla kuralları test-driven olarak birlikte uygulayalım!
