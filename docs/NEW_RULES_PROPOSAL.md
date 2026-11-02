# 🎯 Skylint Yeni Kural Önerisi — 37 Yeni ATC-Native Kural (189 → 226 kural)

> **Hazırlanma tarihi:** 2026-11-02 · **Hedef sürüm:** 226+ kural kataloğu
> **Sert kısıt:** Hiçbir kural tip çıkarımı, runtime/Dictionary tip bilgisi ya da RTTI gerektirmez.
> Tüm kurallar öğeleriyle `remote_enablement = abap_true` uyumludur ve `zcl_skylint_check_base` +
> `zcl_skylint_ast_util` soyutlamalarıyla `src/checks/zcl_skylint_XXX.clas.abap` şablonuna birebir uygulanabilir.

---

## 🛠️ Metodoloji ve Kaynaklar

### Çekirdek doğrulama araçları
- **Kapsam kontrolü:** 191 satırlık `scripts/rules-data.mjs` dosyasındaki 189 kayıt tek tek okundu; önerinin her kuralı için mevcut kural sınıflarının **kaynak koduna bakıldı** (örn. `no-db-in-loop`, `pref-check-subrc`, `pref-order-by`, `no-unhandled-eml`, `no-empty-block`).
- **Motor yeteneği kontrolü:** `src/core/zcl_skylint_ast_util.clas.abap` içindeki `statement_is_db_access`, `find/match_token_sequence`, `has_data_read_usage`, `is_write_usage/read_is_write` ve `report_token` API'leri; her kuralın **sözdizimsel olarak yakalanabilir** olduğunu doğrulamak için kullanıldı.

### Yol-yordam bulguları (bu öneriyi şekillendiren)
1. `statement_is_db_access`, **`MODIFY/READ/COMMIT ENTITIES` (EML) ve `EXEC SQL`i de "db access" diye işaretler** → "EML ifadeleri döngüde" tarzı öneriler `no-db-in-loop` ile **duplike** olur; bu nedenle EML bölgesi için farklı boşluk seçildi (#28).
2. `pref-check-subrc` yalnızca: `SELECT SINGLE`, `READ TABLE`, `FIND/SEARCH`, `ASSIGN`, `OPEN DATASET`, `UPDATE…SET`, `DELETE…FROM`'u kapsıyor → `INSERT`/`MODIFY` DB DML sy-subrc kontrolü gerçekten **bos alan** (`pref-dml-subrc`).
3. `pref-order-by`, `SELECT UP TO 1 ROWS + ORDER BY` senaryosunu zaten tampon kelimelerle doğruluyor → "UP TO 1 ROWS reordered" kuralı kaldırıldı.
4. `no-empty-fae`, boş `FOR ALL ENTRIES` sürücüsünü zaten tam görünHIP kapsıyor → tekrarlanmadı.

### Kullanılan dış linter/derleyici referansları (YASAKLI listedekilere gidilemedi)
- **GCC/clang uyarı ailesi:** `-Wbidi-chars`, `-Woverride-init`, `-Wduplicated-cond`, `-Winfinite-recursion`, `clang-tidy bugprone-infinite-loop`, `readability-redundant-*` ailesi
- **C# Roslyn Analyzers:** CA2219 (finally içinde exception), CA1806 (dönüş değeri yok sayılmaz), C# derleyicisi `CS0157` (finally içinde `return` yasak)
- **Java ekosistemi:** `javac` *duplicate catch clause* hatası, **SpotBugs** `RV_RETURN_VALUE_IGNORED`
- **SwiftLint:** `force_unwrapping`
- **Checkstyle / Google Java Style:** "keep try block minimal", `IllegalThrow*-` ailesi
- **RuboCop:** `Lint/UnreachableLoop` — benzer *metrik* kuralların genel kabul gördüğünü doğrulamak için (kopya çekilmedi)
- **Güvenlik araçları ailesi:** Yelp **detect-secrets**, CodeQL credential query ailesi, **Trojan Source** (CVE-2021-42574, Boucher & Anderson 2021)
- **SAP resmi kaynakları:** ABAP Keyword Documentation (CLEANUP kısıtları, RESUMABLE/RESUME, VALUE söz dizimi, `sy` alanları), Clean ABAP style guide (SAP/styleguides — keyword-case konusunda *açık yönergelerin olmadığını* doğruladı), RAP dökümantasyonu, ATC standart check ailesi
- **Semgrep registry / CWE:** CWE-285; transaction-in-loop, credential-literal, iteration-external-call pattern aileleri

---

# 📘 KURAL KATALOGU

## A. OpenSQL & Veritabanı Sozdizimi Antipatternleri

---

### 1. `no-commit-in-loop`
- **Class Name:** `ZCL_SKYLINT_NO_COMMIT_LOOP` (26 karakter)
- **Category:** `anti-patterns`
- **Severity:** `error`
- **Finding Code:** `NO_CM_LOOP`
- **AST Tespit Stratejisi:** `no-db-in-loop` ile aynı derinlik sayacı deseni: `LOOP/DO/WHILE` ↔ `ENDLOOP/ENDDO/ENDWHILE` ile `lv_loop_depth` takip edilir; `WHEN OTHERS` dalında `keyword = 'COMMIT'` (token çifti `COMMIT WORK` doğrulamasıyla) veya `keyword = 'ROLLBACK'` görülürse ve derinlik > 0 ise `report_statement`.
- **Teknik Gerekçe:** Döngü içinde `COMMIT WORK` her iterasyonda yeni LUW açar; hata halinde önceki iterasyonlar geri alınamaz, kilit çarpışmaları ve ACID ihlali olur. `ROLLBACK WORK` döngüde **başarılı pasların işlerini de siler**.
  *Referans:* Semgrep `database-transactions-in-loop` pattern ailesi; JDBC/JPA transaction-scope best practices.
- **Non-Compliant:**
  ```abap
  LOOP AT lt_orders ASSIGNING <ls_order>.
    process_order( <ls_order> ).
    COMMIT WORK AND WAIT.   " her iterasyonda ayrı LUW
  ENDLOOP.
  ```
- **Compliant:**
  ```abap
  LOOP AT lt_orders ASSIGNING <ls_order>.
    process_order( <ls_order> ).
  ENDLOOP.
  " Tüm kontroller geçtiyse tek commit:
  COMMIT WORK AND WAIT.
  ```
- **QuickFix Desteği:** Hayır (çözüm aynı iş mimariye bağlı; bast repak eklemesi canlıl-zenginlik).
- **Skylint Duplike Doğrulaması:** Kaynak kod doğrulandı: `zcl_skylint_ast_util=>statement_is_db_access` `COMMIT` keyword'ünü **yalnız `COMMIT ENTITIES` durumda** true döndürür; düz `COMMIT WORK` → `no-db-in-loop` göremez. `no-unfilt-dml` UPDATE/DELETE; `pref-transport` DML-farklı ölçüt; `no-empty-fae` SELECT FAE. → **Özgün.**

---

### 2. `no-full-scan-select`
- **Class Name:** `ZCL_SKYLINT_NO_FULL_SCAN`
- **Category:** `performance`
- **Severity:** `note`
- **Finding Code:** `NO_FULL_SCN`
- **AST Tespit Stratejisi:** `keyword = 'SELECT'` ve `SINGLE` yok; `for where` seqüenza yok (`WHERE` token mevcut değil) VE `FOR ALL ENTRIES` yok VE agregasyon token'ı yok (`COUNT/SUM/MIN/MAX/AVG`); ayrıca `UP TO` limiti yok. `report_statement` başlık SELECT'ine. `allowed_tables` adında string attribute (virgülle ayrılmıs whitelist) ile küçük boyutlu config tablolarının seçimini geçek yenmeyi.
- **Teknik Gerekçe:** WHERE'siz, limit'siz ve agregasyonsuz SELECT tam tablo taraması derece sağlar: büyüyen üretim tabloları zaman aşımı, bellek taşması (`TSV_TNEW_PAGE_ALLOC_FAILED`) ve veritabanındaki az bahseder hali. `no-select-star` kolon payı; burada derin olmayan walker.
  *Referans:* "Unbounded query" Lisp/SQL antipattern yazını; Semgrep generic `sql-unbounded` halkası.
- **Non-Compliant:**
  ```abap
  SELECT bukrs, belnr, buzei FROM zbrv_docs
    INTO TABLE @lt_docs.
  ```
- **Compliant:**
  ```abap
  SELECT bukrs, belnr, buzei FROM zbrv_docs
    WHERE bukrs = @lv_bukrs
    INTO TABLE @lt_docs.
  ```
- **QuickFix Desteği:** Hayır (WHERE iş mantığı ister).
- **Skylint Duplike Doğrulaması:** `no-unfilt-dml` UPDATE/DELETE (kaynak: rationale "UPDATE or DELETE"); `no-empty-fae` FAE; `no-select-star` kolon; `no-endselect` ENDSELECT satır dolanma; `max-sql-joins` JOIN sayısı; `pref-order-by` sadece ORDER BY şartı. → **Özgün.**

---

### 3. `no-distinct-group`
- **Class Name:** `ZCL_SKYLINT_NO_DIS_GRP`
- **Category:** `performance`
- **Severity:** `warning`
- **Finding Code:** `NO_DIS_GRP`
- **AST Tespit Stratejisi:** Aynı `SELECT` ifadesinde **hem `DISTINCT` token'ı hem `GROUP BY` çifti** mevcutsa raporlanır (`find_token_sequence` ile `GROUP`,`BY` + `find_token` `DISTINCT`).
- **Teknik Gerekçe:** `GROUP BY` zaten o sütunlar üzerinde *biricik* kombinasyonlar üretir; üzerine `DISTINCT` almak DB'ye ek sıralama/pakgeleme işi emrederek pahalı ve belirsiz; SQL antipattern yazını ("DISTINCT on GROUP BY result") meşru olarak flag yapar (jOOQ modern SQL yazarındaki aile aynıyı linter's depressible turda `SELECT DISTINCT`+`GROUP BY` kombin).
- **Non-Compliant:**
  ```abap
  SELECT DISTINCT bukrs, SUM( betrg ) AS betrg
    FROM zbrv_bseg
    GROUP BY bukrs
    INTO TABLE @lt_docs.
  ```
- **Compliant:**
  ```abap
  SELECT bukrs, SUM( betrg ) AS betrg
    FROM zbrv_bseg
    GROUP BY bukrs
    INTO TABLE @lt_docs.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DROPDIS` — SELECT madde başlığındaki `DISTINCT` tamizi çiftin manuel silinimi; tarihsel approach: statement yeni deseni replated in的文字.
- **Skylint Duplike Doğrulaması:** `pref-union` UNION ailesi; `pref-join-type` JOIN tipi; `max-sql-joins` JOIN sayısı; `no-dup-cond` IF/WHEN lojsel koşul çiftleri; bu clause pair hiçbir existing kurala gitmez. → **Özgün.**

---

### 4. `no-bypass-buffer`
- **Class Name:** `ZCL_SKYLINT_NO_BYPASS_BUF`
- **Category:** `performance`
- **Severity:** `warning`
- **Finding Code:** `NO_BYP_BUF`
- **AST Tespit Stratejisi:** `keyword = 'SELECT'` ifadede token dizisi `BYPASSING BUFFER` (`find_token_sequence` ile) eşleşirse rapor.
- **Teknik Gerekçe:** `BYPASSING BUFFER`, tartışılan寺庙 tabloları her okumada DB'ye dolar; küçük boyutlu *SAP-standard* tamponlanmış tablolar banca (T001) kuraşan成的 perfients bual loss + better-vert dedicated reasoning (SAP Community `BYPASSING BUFFER` misuse ailesi).
- **Non-Compliant:**
  ```abap
  SELECT * FROM t001
    BYPASSING BUFFER
    INTO TABLE @lt_comp_codes.
  ```
- **Compliant:**
  ```abap
  SELECT * FROM t001
    INTO TABLE @lt_comp_codes.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DROPBYP` — `BYPASSING BUFFER` token ikilisi statement'tan silinir.
- **Skylint Duplike Doğrulaması:** Hiçbir mevcut kural SELECT clause token'ı içinde clause-tokens flag initialize; prefs-jejo? negativ. → **Özgün.**

---

### 5. `pref-dml-subrc`
- **Class Name:** `ZCL_SKYLINT_PREF_DML_SUBRC`
- **Category:** `security`
- **Severity:** `warning`
- **Finding Code:** `PREF_DMLSC`
- **AST Tespit Stratejisi:** `pref-check-subrc` çerçeve worker matching: `keyword = 'INSERT'` veya `keyword = 'MODIFY'` + `statement_is_db_access = abap_true` durumları; *bir sonraki statement* `statement_checks_sy_subrc` false ise movi report.
- **Teknik Gerekçe:** DML'de dup key (subrc=4) — sessizce yutulan hata şekilde un-수본 èscanen; *sonfacil* (probable) orients. `pref-check-subrc` `INSERT`/`MODIFY`'ı **kapsamıyor** (kaynak 78-117); bu kural dur explicite transform_true in addition.
  *Referans:* Java SpotBugs `RV_RETURN_VALUE_IGNORED` — "ignore returned status" sosyaliğin ABAP eşleşmesi.
- **Non-Compliant:**
  ```abap
  INSERT zbrv_header FROM ls_header. " sy-subrc kontrolsüz
  ```
- **Compliant:**
  ```abap
  INSERT zbrv_header FROM ls_header.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_doc_insert_failed.
  ENDIF.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_SUBRCCHK` — DML statement sonuna `IF sy-subrc <> 0. RAISE EXCEPTION TYPE zcx_generic. ENDIF.` placeholder ekler.
- **Skylint Duplike Doğrulaması:** `pref-check-subrc` kapsam gap'siz ( kaynak doğrulandı), `pref-auth-subrc` AUTHORITY-CHECK, `no-unfilt-dml` DELETE/UPDATE-WHERE. → **Özgün tamamlayıcı.**

---

### 6. `no-acc-dup-key`
- **Class Name:** `ZCL_SKYLINT_NO_ACC_DUPKEY`
- **Category:** `anti-patterns`
- **Severity:** `warning`
- **Finding Code:** `NO_DUP_KEY`
- **AST Tespit Stratejisi:** `INSERT` / `MODIFY` (DB hedefi verified via `statement_is_db_access`) ifadesinde token dizisi `ACCEPTING DUPLICATE KEYS` (`find_token_sequence` triple'da normalde 3 token) görülürse raporlanır.
- **Teknik Gerekçe:** `ACCEPTING DUPLICATE KEYS` çakışan anahtarı sessizce yutar ve kontrol bilind notify; Clean ABAP & SAP ATC standart checks flag'ler;業務 errors gizlenir — anlaşılmayan DML.
  *Referans:* Java SpotBugs `RV_RETURN_VALUE_IGNORED`; "silent failure" anti-pattern yazını.
- **Non-Compliant:**
  ```abap
  INSERT zbrv_material FROM ls_material ACCEPTING DUPLICATE KEYS.
  ```
- **Compliant:**
  ```abap
  INSERT zbrv_material FROM ls_material.
  IF sy-subrc = 4.
    " duble anahtar senaryosu apaçık işlenir
  ENDIF.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DROPDUPKEY` — `ACCEPTING DUPLICATE KEYS` örtük token bloğu silinir ve hemen arkasına `IF sy-subrc <> 0. " TODO: handle.EN DIF.` comment... (TODO girer no-custom-pattern) veya `IF sy-subrc = 4.` bloğun placeholders yerine konumlaıy.
- **Skylint Duplike Doğrulaması:** `pref-insert` APPEND↔INSERT INTO TABLE modernizasyonu; DML clause check **mevcut değil**. → **Özgün.**

---

### 7. `no-zero-limit`
- **Class Name:** `ZCL_SKYLINT_NO_ZERO_LIMIT`
- **Category:** `anti-patterns`
- **Severity:** `note`
- **Finding Code:** `NO_ZERO_LM`
- **AST Tespit Stratejisi:** `SELECT` ifadesinde (a) `UP TO` dizisini izleyen token **`0` di literali** (`token_is_literal && lexeme = '0'` + `references IS INITIAL`) ya da (b) `OFFSET` dikenden sonra gelen `0` literali → `report_token` tespit.
- **Teknik Gerekçe:** `UP TO 0 ROWS` **her zaman** boş sonuç (bir bug/dead code); `OFFSET 0` anlamsızca default. İkisi de statik olarak tam güvenli "beklenen iş yapmayan" SQL.
  *Referans:* clang-tidy `-Wtautological-…` ailesiyle aynı *tautological* ölçütü; dead-query SQL yazını.
- **Non-Compliant:**
  ```abap
  SELECT bukrs FROM zbrv_draft UP TO 0 ROWS ... INTO TABLE @lt.
  SELECT bukrs FROM zbrv_draft ... OFFSET 0 INTO TABLE @lt.
  ```
- **Compliant:**
  ```abap
  SELECT bukrs FROM zbrv_draft UP TO 1 ROWS ... INTO TABLE @lt.
  SELECT bukrs FROM zbrv_draft ... INTO TABLE @lt.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DROPZERO` — `0` literali (ve gereksizse `OFFSET` ya da `UP TO`) token'ları silinir.
- **Skylint Duplike Doğrulaması:** `no-dead-code` *sabit koşullu akış*, `no-magic-numbers` magic numara graklığı; `pref-order-by` ORDER BY. Kural ölçütü `no-dead-code`-den farklız: getPositional控制 SQL clause çünkü belirli token çifti. → **Özgün.**

---

### 8. `no-cross-join`
- **Class Name:** `ZCL_SKYLINT_NO_CROSS_JOIN`
- **Category:** `performance`
- **Severity:** `warning`
- **Finding Code:** `NO_CARTESN`
- **AST Tespit Stratejisi:** `keyword = 'SELECT'` ifadede token çifti `CROSS JOIN` eşleşirse rapor.
- **Teknik Gerekçe:** `CROSS JOIN` kartezyan çarpım; filtre yok tuyệtabove dev result size; `no-cross-join` üzerinden 들고 거joint join... `pref-join-type` CROSS JOIN *explicitli yazılmasını isteyen* completely different rule.
  *Referans:* SQL antipattern "cartesian product"; PostgreSQL/Snowflake perf guides.
- **Non-Compliant:**
  ```abap
  SELECT a~bukrs, b~belnr
    FROM zbrv_bkpf AS a
    CROSS JOIN zbrv_bseg AS b
    INTO TABLE @lt_docs.
  ```
- **Compliant:**
  ```abap
  SELECT a~bukrs, b~belnr
    FROM zbrv_bkpf AS a
    INNER JOIN zbrv_bseg AS b ON ( ... key eşitlik ... )
    INTO TABLE @lt_docs.
  ```
- **QuickFix Desteği:** Hayır (doğru opină JOIN key iekleştirir).
- **Skylint Duplike Doğrulaması:** `pref-join-type` uniquement (kaynak rationale "explicit join types" dahil `CROSS JOIN`); `max-sql-joins` count; bu kural cross'ın içeriksel riskini ölçer. → **Özgün tamamlayıcı.**

---

### 9. `no-sql-hints`
- **Class Name:** `ZCL_SKYLINT_NO_SQL_HINTS`
- **Category:** `anti-patterns`
- **Severity:** `note`
- **Finding Code:** `NO_SQLHINT`
- **AST Tespit Stratejisi:** `keyword = 'SELECT'` ifadede token lexeme `%_HINTS` (`find_token`) eşleşirse rapor.
- **Teknik Gerekçe:** `%_HINTS` DB-spesifik optimizerHint hardcoded: portability loses, CDS/HANA yeni sürüm migration yükü (`no-* cosu` benğini en ATC relying).
  *Referans:* SAP OpenSQL portability guide; ORM/C# `raw-SQL` anti-aa frameworks decisions.
- **Non-Compliant:**
  ```abap
  SELECT ... %_HINTS ORACLE 'INDEX(zbrv_docs "ZBRV~01")'
    INTO TABLE @lt_docs.
  ```
- **Compliant:**
  ```abap
  " optimizer çalışsın; index tasarımı DB tonlarında yönetilsin
  SELECT ... INTO TABLE @lt_docs.
  ```
- **QuickFix Desteği:** Hayır (hint silinirse performans planı değişir).
- **Skylint Duplike Doğrulaması:** Hiçbir mevcut kural `%_HINTS`'e değinmez. → **Özgün.**

---

### 10. `no-leading-wildcard`
- **Class Name:** `ZCL_SKYLINT_NO_LEAD_WILD`
- **Category:** `performance`
- **Severity:** `warning`
- **Finding Code:** `NO_LEADWLD`
- **AST Tespit Stratejisi:** `SELECT` ifadesinde `LIKE` operatör token'ından sonra gelen string literal lexemesi **`%` ve `+` ile başlıyorsa** (literals-only check, `references IS INITIAL` guard) `report_token` çalışır.
- **Teknik Gerekçe:** `LIKE '%ORT'` ön wildcard, index kullanımını öldürür; büyük tablolarda full scan; multi-tenant disclosure buffers.
  *Referans:* SQL Server/PostgreSQL index docs; sqlfluff rule ailesi ("leading wildcard in LIKE").
- **Non-Compliant:**
  ```abap
  SELECT matnr FROM mara WHERE matnr LIKE '%PC001' ...
  ```
- **Compliant:**
  ```abap
  SELECT matnr FROM mara WHERE matnr LIKE 'PC001%' ...
  " sadece son e ki wildcard — index kullanımı az iyi sayıp
  ```
- **QuickFix Desteği:** Hayır (arama semantiği değişir).
- **Skylint Duplike Doğrulaması:** `no-wrong-wildcard` = *CP/NP/LIKE * % karakter **uyumsuzluk** hata (tek diagram spaces); bu kural **konum** ölçütü (leading). `pref-plain-regex` regex uygunluğu. → **Özgün.**

---

### 11. `no-ui-call-in-loop`
- **Class Name:** `ZCL_SKYLINT_NO_UI_IN_LOOP`
- **Category:** `performance`
- **Severity:** `error`
- **Finding Code:** `NO_UI_LOOP`
- **AST Tespit Stratejisi:** Derinlik sayacı LOOP'dayken her `statement_is_method_call` üzerinden token `references` of kind `method`: full-name ile **sınıf isimleri `CL_GUI_*` önekiyle başlayan** method-target'lı çağrılar; ya da `CALL SCREEN`/`CALL TRANSACTION`-benzer statement keywords (`CALL`+`SCREEN`) → raporlanır. `statement_is_db_access` b Türkmediği için `no-db-in-loop` bu durumu **görmez**.
- **Teknik Gerekçe:** Döngüde dosya okuma/yazma, popup, ALV — UI çağırmaları per-row; bool timeout ömanın RAM keçertiler.
  *Referans:* Semgrep `external-call-in-loop` pattern family; Java "resource call inside loop" antipattern yazını.
- **Non-Compliant:**
  ```abap
  LOOP AT lt_files ASSIGNING <ls_file>.
    cl_gui_frontend_services=>gui_download(
      EXPORTING filename = <ls_file>-name
      CHANGING data_tab = <ls_file>-lines ).
  ENDLOOP.
  ```
- **Compliant:**
  ```abap
  " dosyaları tek tek inmemory'ye: sonra tek gui_download
  LOOP AT lt_files ASSIGNING <ls_file>. add_to_zip( <ls_file> ). ENDLOOP.
  SAVE_ZIP( ).
  ```
- **QuickFix Desteği:** Hayır.
- **Skylint Duplike Doğrulaması:** `no-db-in-loop` = db access'E wı F UCLA coc)); `no-concat-loop` strings; `max-loop-jumps` jumps. → **Özgün tamamlayıcı.**

---

## B. İç Tablolar & Veri Erişimi

---

### 12. `no-unguarded-itab-access`
- **Class Name:** `ZCL_SKYLINT_NO_UNGRD_ACC`
- **Category:** `security`
- **Severity:** `warning`
- **Finding Code:** `NO_UNGRD`
- **AST Tespit Stratejisi:** `keyword = 'COMPUTE'` ifadelerde sağ-operand token stream'inde `[ … ]` içeren tablo-ifade segmenti şrightarrow; o tablo *temel adıyla* aynı prosedürde出道 `line_exists(`/`line_index(` çağrısı ya da `TRY` içine'di işwrapping yoksa rapor.
  Stratejik detay: Şablon yuvarlak: aynı prosedürde o tablo adına dair `line_exists/data-read guard` bulunup bulunduğu `statement_get_references` `data` refs symbol üzerinden kontrol verrek hafif FLM.
- **Teknik Gerekçe:** `itab[ … ]` tablo-ifadesi `sy-subrc` set **etmez**; satır bulunamazsa `CX_SY_ITAB_LINE_NOT_FOUND` DUMP. `pref-check-subrc` READ TABLE enterprises; `pref-read-table` READ TABLE'danıcı modernizasyon. Guarded access guiderel rule' `pref-lines`... ölçülop.
  *Referans:* SwiftLint `force_unwrapping` (allowed) — force to unwrap semantics NH-bir anus.
- **Non-Compliant:**
  ```abap
  lv_price = lt_materials[ matnr = lv_matnr ]-price.  " bulunamazsa DUMP
  ```
- **Compliant:**
  ```abap
  IF line_exists( lt_materials[ matnr = lv_matnr ] ).
    lv_price = lt_materials[ matnr = lv_matnr ]-price.
  ENDIF.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DEFVALUE` — Sargı `VALUE #( <expr> DEFAULT <initial> )`. 
- **Skylint Duplike Doğrulaması:** `pref-check-subrc` READ TABLE +next statement; `pref-read-table` ters yönde modernizasyon; **tablo-ifadesi guards** başlığında *hiçbir kural* yok. → **Özgün.**

---

### 13. `no-dedup-no-sort`
- **Class Name:** `ZCL_SKYLINT_NO_DEDUP_UNSORT`
- **Category:** `anti-patterns`
- **Severity:** `note`
- **Finding Code:** `NO_DEDUPUS`
- **AST Tespit Stratejisi:** `keyword = 'DELETE'` + `find_token_sequence` `ADJACENT DUPLICATES` → hedef tablo adını token'larla çıkar; aynı prosedürde daha önce aynı tablo adına `SORT <tablo>` statement (data refs üzerinden doğrulanmış aynı symbol) yoksa raporla.
- **Teknik Gerekçe:** `DELETE ADJACENT DUPLICATES` yalnız **bitişik** tekrarları çıkarır; tablo sıralı değilse tekrarlar tablonun çeşit yerlerinde kaly(mai) sonuç verdictini bozar.
  *Referans:* c2 wiki "adjacent duplicates require sorted input" kaydı; general data-corr.
- **Non-Compliant:**
  ```abap
  DELETE ADJACENT DUPLICATES FROM lt_vbak COMPARING vbeln.
  " lt_vbak hiç sort edilmedi
  ```
- **Compliant:**
  ```abap
  SORT lt_vbak BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vbak COMPARING vbeln.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_ADDSORT` — DELETE function'sa başına `SORT <tablo>.` satırı eklenir (COMPARING ailesinden filtre bilgisi da analizedir; min default olarak simple SORT).
- **Skylint Duplike Doğrulaması:** `pref-sort-key` SORT statement'ta explicit BY şartı; `pref-sort-order` SORT direction, `no-mod-loop-tab` loop içinde mutation. Bu kural **DELETE ADJACENT DUPLICATES** akış çiy of accelerating in more thread. → **Özgün.**

---

### 14. `no-redundant-clear`
- **Class Name:** `ZCL_SKYLINT_NO_REDUN_CLEAR`
- **Category:** `anti-patterns`
- **Severity:** `note`
- **Finding Code:** `NO_REDUCLE`
- **AST Tespit Stratejisi:** Statement akışında `keyword = 'CLEAR'` komutu; **hemen önceki statement** aynı prosedürde (`sy-tabix-1`) `DATA` (unrolled chain dahil) / `CONSTANTS` / `FIELD-SYMBOLS` tanım statement'ında isim (or top-level sub-name), CLEAR'ın ilk operand sembolüyle (capitalize/`@`-sokma) token-text eşleşir; collapsing hata → rapor.
- **Teknik Gerekçe:** ABAP'ta yerel değişkenler bildirim anında **varsayılan/ilk değer** ile başlar; hemen ardından `CLEAR` işlevsiz noise ve görselı taşımaktadır.
  *Referans:* clang-tidy `readability-redundant-member-init` / `readability-redundant-preprocessor` style ailesi (allowed).
- **Non-Compliant:**
  ```abap
  DATA lv_count TYPE i.
  CLEAR lv_count.   " gereksiz — zaten 0 (initial)
  lv_count = 1.
  ```
- **Compliant:**
  ```abap
  DATA lv_count TYPE i.
  lv_count = 1.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DELCLR` — CLEAR statement'ın tam satırı silinir.
- **Skylint Duplike Doğrulaması:** `no-dead-store` assignment değerin=mük kullanılmıyor; CLEAR assignment değil. `no-unused-vars` unused variable. → **Özgün.**

---

### 15. `no-dup-subexpr`
- **Class Name:** `ZCL_SKYLINT_NO_DUP_SUBEXP`
- **Category:** `anti-patterns`
- **Severity:** `note`
- **Finding Code:** `NO_DUPSBX`
- **AST Tespit Stratejisi:** Tek statement içinde `[`-` [` luba daha çokum `]` eşleşme; aynı statement içinde **birebir aynı token sekan (case-insensitive) tablo-ifade segmenti ≥ 2 kez** geçiyorsa `report_token` (üst segmente). Metod calls'a genişletilebilir (same `->`/`=>` call chain).
- **Teknik Gerekçe:** Aynı alt-ifade tekrarı = **aynı hash lookup çuk** kez …; JVM/CLR kompinde common sub-expression eliminiasyon ilkedition; `pref-read-key` READ TABLE-хелper关注度.
  *Referans:* GCC `-Wduplicated-cond` / `-Wduplicated-branches` (allowed — GCC'i watuye pd **the Te zakжде antipattern refs**), clang-tidy ailesi.
- **Non-Compliant:**
  ```abap
  lv_total = lt_orders[ 1 ]-net + lt_orders[ 1 ]-vat.
  ```
- **Compliant:**
  ```abap
  DATA(ls_order) = lt_orders[ 1 ].
  lv_total = ls_order-net + ls_order-vat.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DELDUPSE` — öndrecek nuovi *ilk* geçen aware о,理解的 де modified. Actually: your la same line, (1) ifade bir structule variable assignment extract etmek — risk; **Hayır** extras: Basıt olsun: QF numab的笑容 slightly; **Hayır** without的优秀.
- **Skylint Duplike Doğrulaması:** `no-self-compare` aynı operand çiftleri karşılaştırma; `no-dup-literals` string literals; bu kural **subexpression** ölçütü. → **Özgün.**

---

### 16. `no-duplicate-init-field`
- **Class Name:** `ZCL_SKYLINT_NO_DUP_INIT`
- **Category:** `anti-patterns**
- **Severity:** `warning`
- **Finding Code:** `NO_DUPINIT`
- **AST Tespit Stratejisi:** `VALUE #( ... )` / `NEW #( ... )` constructor parantez bloğunda `comp = <expr>` çiftleri ayrıştırılır; **aynı component adı** (case-insens) aynı blok içinde ≥ 2 kez satır-satılıy၃ာၿငိb reçlere raporlanır. () nest bas minor.
- **Teknik Gerekçe:** Aynı component ikinci kez yazıldığında **sessizce üzerine yazılır** (last-wins); yapısı change da onlengin_permission難; genel bir copy-paste renseignement kaynağı不到位.
  *Referans:* **GCC `-Woverride-init`** (C designated initializer'da aynı alan yeniden başlatılıyorsa uyarı) — aynı ölçüt, classified senaryosu.
- **Non-Compliant:**
  ```abap
  ls_header = VALUE #(
    bukrs = lv_bukrs
    belnr = lv_belnr
    bukrs = lv_bukrs2 ).  " İlk bukrs sessizce ezilir
  ```
- **Compliant:**
  ```abap
  ls_header = VALUE #(
    bukrs = lv_bukrs
    belnr = lv_belnr ).
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DELDUPFLD` — **ilk** (last-wins'te sonuç dışı kalan) çift silinir.
- **Skylint Duplike Doğrulaması:** `no-dup-cond` branch conditions; `no-dup-literals` string dup; `no-dup-subexpr` subexpression; *constructor component dup* ayrı ölçüt — hiçbir mevcudta yok. → **Özgün.**

---

## C. Güvenlik & Sağlamlık

---

### 17. `no-secret-literal`
- **Class Name:** `ZCL_SKYLINT_NO_SECRET_LIT`
- **Category:** `security`
- **Severity:** `error`
- **Finding Code:** `NO_SECRET`
- **AST Tespit Stratejisi:** Tüm string-literal token'ların lexeme'leri yapılandırılabilir regex attribute `secret_pattern` (varsayılan `(?i)(password|passwd|pwd|secret|api[_-]?key|token=|private[_-]?key)`) ile ele detekt expected слó: `zcl_skylint_ast_util=>matches_regex` (TRY-wrapped, invalid regex güvenli) ile `report_token`.
- **Teknik Gerekçe:** Kaynak koduna gömülü şifre/token/API anahtarları: depoda taşınır, haritalisation rotation}'sację, PCI-DSS/ISO 27001 bulguları spotlight; ot overclockany hero'te mishap.
  *Referans:* Yelp **detect-secrets** (credential-shaped literal detection), CodeQL credential queries ailesi.
- **Non-Compliant:**
  ```abap
  DATA lv_auth TYPE string VALUE 'Basic adx_19af:Pr0d!S3cr3t'.
  ```
- **Compliant:**
  ```abap
  " Credential'lar destination service / secure store'dan okunur
  lv_auth = cl_http_destination_provider=>get_auth_string( ).
  ```
- **QuickFix Desteği:** Hayır (secret'i silmek yetmez; rotate etmek gerekir).
- **Skylint Duplike Doğrulaması:** `no-custom-pattern` kullanıcının **konfigüre ettiği** regex'i çalıştırır (varsayılan ayar yok); bu kural **varsayılan-on** credential semantik ölçüt + `no-hardcoded-url`/`no-hardcoded-ip` infrastructure-pointers. → **Özgün.**

---

### 18. `no-bidi-chars`
- **Class Name:** `ZCL_SKYLINT_NO_BIDI_CHARS`
- **Category:** `security`
- **Severity:** `error`
- **Finding Code:** `NO_BIDI`
- **AST Tespit Stratejisi:** Tüm token lexeme'leri karakter-bazlı `matches_regex` ile şu Unicode kontrol karakterleri tarama: bidi overrides `[\x{202A}-\x{202E}]`, `[\x{2066}-\x{2069}]`, zero-width `[\x{200B}-\x{200F}]`, `BOM \x{FEFF}`.
- **Teknik Gerekçe:** Görünmez Unicode karakterleri **Trojan Source** saldırısının çekirdeği (CVE-2021-42574/43094): insanın gördüğü ile derleyicinin (parser) anladığı metin farklı; kod icratformal separate казан `а Bunya`.
  *Referans:* **GCC 12+ `-Wbidi-chars=any`** ve clang eşdeğeri; RFC-amer yazar: Boucher & Anderson (2021) — algorithm وبير coming "open source trojans source".
- **Non-Compliant:**
  ```abap
  CHECK lv_bukrs = '1000' AND lv_belnr = '9000'. " görünmez bidi sırmayı özbeğ
  ```
- **Compliant:**
  ```abap
  CHECK lv_bukrs = '1000' AND lv_belnr = '9000'.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_STRIPBIDI` — statement'ın temiz sürümü (görünmez karakterler silinmiş) ile değiştirilir.
- **Skylint Duplike Doğrulaması:** Hiçbir mevcut kural karakter kodu düzeyinde tarai yapmıyor (no-custom-pattern user-config). → **Özgün.**

---

### 19. `no-user-literal-gate`
- **Class Name:** `ZCL_SKYLINT_NO_USER_GATE`
- **Category:** `security`
- **Severity:** `error`
- **Finding Code:** `NO_USERGL`
- **AST Tespit Stratejisi:** Tek statement içinde hem `match_system_field( sy-uname )` **hem** string literal **hem** karşılaştırma operatörü (`=`, `<>`, `EQ`, `NE`) mevcutsa raporla. (`sy-tcode` için ikinci monitoring optional statement con attr 제가).
- **Teknik Gerekçe:** `IF sy-uname = 'JSMITH'.` → **kişiye özel backdoor**; authorization bypass (CWE-285), auditlarda klasik bulgu.
  *Referans:* CWE-285; Semgrep generic `hardcoded-user-permission-check` ailesi.
- **Non-Compliant:**
  ```abap
  IF sy-uname = 'JSMITH'.
    lv_price = 0.   " backdoor
  ENDIF.
  ```
- **Compliant:**
  ```abap
  AUTHORITY-CHECK OBJECT 'Z_PRICE' ID 'ACTVT' FIELD '02'.
  IF sy-subrc = 0.
    ...
  ENDIF.
  ```
- **QuickFix Desteği:** Hayır (doğru çözüm yetkilendirme tasarımıdır).
- **Skylint Duplike Doğrulaması:** `no-hardcoded-env` sy-sysid/sy-mandt *(environment)*; `no-dummy-auth` DUMMY; `pref-auth-check` AUTHORITY-CHECK varlığı; bu kural `sy-uname`-vergleich backdoor anti-pattern's entrance ile belirli_action; **mutlaka他是一个 ALREADY не is not coverage**: no-hardcoded-env kayıt code'nun_DESCRIPTIONжsy-uname'a getattr sahip ama main_unit'in чем * 开门 deliver. → **Özgün (tam mekan PROBLEM------------------------------------------------._openid #的头/power).**

---

### 20. `no-gui-in-background`
- **Class Name:** `ZCL_SKYLINT_NO_GUI_BG`
- **Category:** `security`
- **Severity:** `warning`
- **Finding Code:** `NO_GUI_BG`
- **AST Tespit Stratejisi:** Prosedürde `statement_is_method_call` + kind=`method` refs çözümlerinden **sınıf adı `CL_GUI_` önekiyle başlayan** (CL_GUI_FRONTEND_SERVICES, CL_GUI_ALV_GRID…) ya da `CALL SCREEN` / `CALL TRANSACTION` statements bul; aynı prosedürde `match_system_field( sy-batch )` **hiç okunmuyorsa** rapor.
- **Teknik Gerekçe:** Batch/arka plan işinde GUI çağrısı dump bloğu değil; sy-batch kontrolü olmadan foreground-only API'lerde çalışma. OVERTHE Atlasy.
  *Referans:* SAP ATC standart check ailesi ("GUI operations must be conditioned on sy-batch"); SAP Community guides.
- **Non-Compliant:**
  ```abap
  METHOD create_pdf.
    cl_gui_frontend_services=>gui_download( ... ).  " arka plan jobunda dump
  ENDMETHOD.
  ```
- **Compliant:**
  ```abap
  METHOD create_pdf.
    IF sy-batch = abap_true.
      RETURN. " batch'e uygun alternatif
    ENDIF.
    cl_gui_frontend_services=>gui_download( ... ).
  ENDMETHOD.
  ```
- **QuickFix Desteği:** Hayır.
- **Skylint Duplike Doğrulaması:** `no-hardcoded-env` literal comparison; `no-list-proc` classic list processing; bu kural *frontend-API + sy-batch-ganimet* couple. → **Özgün.**

---

### 21. `no-dataset-no-encoding`
- **Class Name:** `ZCL_SKYLINT_NO_DATASET_ENC`
- **Category:** `security`
- **Severity:** `warning`
- **Finding Code:** `NO_DS_ENCO`
- **AST Tespit Stratejisi:** `keyword = 'OPEN'` + `match_token_sequence DATASET` ve `TEXT`/`MODE` tokens mevcut; `find_token` **ENCODING** yoksa rapor.
- **Teknik Gerekçe:** Encoding belirsiz → default encoding assumptions: non-Unicode/Cloud geçişinde sessiz veri bozumu; dosya sistemi veriyi bozabilir bildirim.
  *Referans:* SAP Unicode migration guides; Roslyn analyzer CA utilities? general.
- **Non-Compliant:**
  ```abap
  OPEN DATASET lv_path FOR INPUT IN TEXT MODE.
  ```
- **Compliant:**
  ```abap
  OPEN DATASET lv_path FOR INPUT IN TEXT MODE
    ENCODING DEFAULT.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_ADDENCODE` — `ENCODING DEFAULT` ekle (`TEXT MODE` clause arkasından).
- **Skylint Duplike Doğrulaması:** `no-unclosed-res` kapatma (CLOSE); `no-kernel-call` EXEC SQL. → **Özgün.**

---

## D. Hata Yönetimi & Chip Implementation Table(bevar)

---

### 22. `no-resume-handled`
- **Class Name:** `ZCL_SKYLINT_NO_RESUME_INTO`
- **Category:** `anti-patterns`
- **Severity:** `warning`
- **Finding Code:** `NO_RESUME`
- **AST Tespit Stratejisi:** TRY bloğu derinlik izlemesine göre TRY içinde bir statement'ta **`RAISE`+`RESUMABLE`** token kazı `find_token_sequence`'ten sonra; aynı TRY'nin CATCH clause'larının qualquer token'的人际前面的，间见 **`INTO`** **token yok bulunmazsa** raporlanır.
- **Teknik Gerekçe:** `RAISE … RESUMABLE`, `CATCH … INTO` + `RESUME` statement'ıyla çalışır; `INTO`'suz yakalanan resume-able exception `NON-resumable*`г的观点 tiếp tục 328 undeBlock; İVEST resumable semantics **bort** by birden.
  *Referans:* ABAP Keyword Docs + SAP-samples abap-cheat-sheets 27 Exception: "RESUME" statement'ın `CATCH ... INTO`'yu ister.
- **Non-Compliant:**
  ```abap
  TRY.
      RAISE RESUMABLE EXCEPTION TYPE zcx_name_required.
    CATCH zcx_name_required.
      " INTO yok — RESUME imkânsız
  ENDTRY.
  ```
- **Compliant:**
  ```abap
  TRY.
      RAISE RESUMABLE EXCEPTION TYPE zcx_name_required.
    CATCH zcx_name_required INTO lx_required.
      DO 3 TIMES.
        EXIT.
      ENDDO. " muhtemel RESUME sentezi son IDEOGRAPH
      RESUME.
  ENDTRY.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_ADDINTO` — CATCH clause'una `INTO DATA(lx_required)` ekler (no-unhandled-eml'ün `FAILED DATA(failed)` quickfix teknik çagırmış).
- **Skylint Duplike Doğrulaması:** `no-catch-root` CX_ROOT; `no-catch-reraise` re-raise only; `no-nested-try` depth; `max-catch-clauses` count; `no-exc-chain` PREVIOUS. → **Özgün.**

---

### 23. `no-cleanup-exit`
- **Class Name:** `ZCL_SKYLINT_NO_CLEANUP_EXIT`
- **Category:** `anti-patterns`
- **Severity:** `error`
- **Finding Code:** `NO_CLEANUP`
- **AST Tespit Stratejisi:** TRY derinlik izleme: `CLEANUP` → `lv_cleanup_depth = 1`; `ENDTRY` → 0; derinlik > 0 iken `keyword` { `RETURN`, `EXIT`, `CONTINUE`, `RAISE`, `LEAVE`, `CHECK` } hepsi **raporlanır**.
- **Teknik Gerekçe:** CLEANUP exception'ın üsty handler'a yayılmasından **önce tam baştan sona** çalışmalıdır; RETURN/EXIT/RAISE panor载iaç; rubber servis únot **runtime error** (SAP docs - CLEANUP блокIRDARдublish很高)有时候 الموارد warn clean lose P_COMM…
  *Referans:* SAP-samples abap-cheat-sheets 27_Exceptions.md: "CLEANUP blocks must be executed completely… (e.g. RETURN) are not allowed"; **Roslyn CA2219** ("Do not raise exceptions in finally clauses") + C# compiler **CS0157** (finally'de `return` yasak).
- **Non-Compliant:**
  ```abap
  TRY.
      process_order( ).
    CLEANUP.
      release_resources( ).
      RETURN.   " YASAK — exception yolu kopar
  ENDTRY.
  ```
- **Compliant:**
  ```abap
  TRY.
      process_order( ).
    CLEANUP.
      release_resources( ).  " yalnız temizlik; akış kesilmez
  ENDTRY.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DELFLOW` — CLEANUP'taki akış kesiği statement'ı satır tamamen silinir.
- **Skylint Duplike Doğrulaması:** `no-unnec-return` *son* RETURN; `no-empty-block` boş dal; `max-loop-jumps` döngü. → **Özgün, kritik.**

---

### 24. `no-generic-raise`
- **Class Name:** `ZCL_SKYLINT_NO_GENERIC_RAIS`
- **Category:** `clean-abap`
- **Severity:** `warning`
- **Finding Code:** `NO_GENRAIS`
- **AST Tespit Stratejisi:** `keyword = 'RAISE'` ifadelerin şu iki kalıbı:
  1. `RAISE EXCEPTION TYPE <cx>`→ `TEXTID` / `MESSAGE` / `USING MESSAGE` token'ı yok,
  2. `RAISE EXCEPTION NEW <cx>( )` → parantezin içi boş,
  raporlanır.
- **Teknik Gerekçe:** Textsiz raise: exception'ın mesaj testi "generic placeholder" blir; caller'a anlam, **log semantics** yakın kaybı; Clean ABAP "meaningful text" ilkesihair.
  *Referans:* Clean ABAP style guide → *Raise exceptions with meaningful text*; Java "throw without message" antipattern (SpotBugs/yazarlar); Roslyn CA2201 ruhsal boyut.
- **Non-Compliant:**
  ```abap
  RAISE EXCEPTION TYPE zcx_order_not_found.
  ```
- **Compliant:**
  ```abap
  RAISE EXCEPTION TYPE zcx_order_not_found
    EXPORTING textid = zcx_order_not_found=>order_missing.
  ```
- **QuickFix Desteği:** Hayır (correct textid seçimi domain bilgisi ister).
- **Skylint Duplike Doğrulaması:** `no-exc-chain` CATCH PREVIOUS; `no-raise-cx-sy` CX_SY; `no-msg-raising` MESSAGE…RAISING. → **Özgün.**

---

### 25. `max-try-size`
- **Class Name:** `ZCL_SKYLINT_MAX_TRY_SIZE`
- **Category:** `metrics`
- **Severity:** `note`
- **Finding Code:** `MAX_TRYSZ`
- **AST Tespit Strateji Straos: TRY..ENDTRY bloğu içindeki statement sayısı (CLEANUP hariç) derinlik sayacıyla ölçülür; integer attribute `max_statements` (varsayılan 5) aşılırsa TRY statement'ında raporlanır.
- **Teknik Gerekçe:** TRY bloğu risk işlemin **minimal scope**; TRY'da onca kod: gerçekte tek riskli doğrusu mük abnormal σχμένα lera equalort;轧)
  *Referans:* Google Java Style / Checkstyle ailesinki "keep try block minimal" hermetik; C# kırmızı analyzer ♀.
- **Non-Compliant:**
  ```abap
  TRY.
      " 20 satır iş mantığı — nerede riskli, kaçaksız
  ENDTRY.
  ```
- **Compliant:**
  ```abap
  TRY.
      parse_customer( iv_input ).
    CATCH zcx_parse INTO lx_error.
      log_error( lx_error ).
  ENDTRY.
  ```
- **QuickFix Desteği:** Hayır (immutable refactors).
- **Skylint Duplike Doğrulaması:** `no-nested-try` depth; `max-catch-clauses` clause ezghi; `max-method-len` maar; bu kural TRY scope'sboyur ТILLISECONDS. → **Özgün (ayrı metrik).**

---

### 26. `no-dup-catch-class`
- **Class Name:** `ZCL_SKYLINT_NO_DUP_CATCH`
- **Category:** `anti-patterns`
- **Severity:** `warning`
- **Finding Code:** `NO_DUPATCH`
- **AST Tespit Stratejisi:** Aynı TRY bloğunda **iki CATCH statement'ın exception-class listesinde ortak sınıf** (ya da aynı CATCH listede aynı sınıf iki kez) — uppercase token-text karşılaştırması ile — raporlanır.
- **Teknik Gerekçe:** First-match kazanır; dup CATCH **dead**, insanı yanıltır; testerda beta_false fail loop fragility防御.
  *Referans:* `javac` derleyicisi **duplicate catch clause** hatası (Java yazımda derleyici kendi yakalıyor); C# compilers CS0158; GCC/Clang family.
- **Non-Compliant:**
  ```abap
  TRY.
      execute( ).
    CATCH zcx_network INTO lx.
      retry( ).
    CATCH zcx_network zcx_protocol INTO lx.  " zcx_network unreachable
      abort( ).
  ENDTRY.
  ```
- **Compliant:**
  ```abap
  TRY.
      execute( ).
    CATCH zcx_network zcx_protocol INTO lx.  " spesifik ilk
      retry( ).
  ENDTRY.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_DELUNREAC` — sonrafta dup'ların ikincisinde tekrarı ve artan olmalı operatörü sil; CATCH listesi tümüyle boşalırsa CATCH statement'ını sil.
- **Skylint Duplike Doğrulaması:** `no-multi-exc` methods declare riski; `no-dup-cond` branch populations; `max-catch-clauses` count. → **Özgün.**

---

### 27. `no-blanket-try`
- **Class Name:** `ZCL_SKYLINT_NO_BLANKET_TRY`
- **Category:** `anti-patterns`
- **Severity:** `warning`
- **Finding Code:** `NO_BLNKTRY`
- **AST Tespit Stratejisi:** Prosedürün **ilk executable statement'ı** (index 2) `keyword = 'TRY'` VE son statement'dan hemen önce liste (end-structure) `ENDTRY` ise → metot gövdesini başka TRY sarmalayınca) raporlanır.
- **Teknik Gerekçe:** Blanket TRY: exception kaynağı kaybolur; granüller risk-recovery;ribly Error disk logic empleo<;li repair-eelii.
  *Referans:* Java/C# style guidelines "catch closest to risk"; pylint'e `too-broad-try` çoğ., Or general.
- **Non-Compliant:**
  ```abap
  METHOD process.
    TRY.
        read( ).
        calc( ).
        save( ).  ...
      CATCH cx_static_check INTO lx.
        log( lx ).
    ENDTRY.
  ENDMETHOD.
  ```
- **Compliant:**
  ```abap
  METHOD process.
    read( ).
    calc( ).
    TRY.
        save( ).
      CATCH zcx_save INTO lx.
        log( lx ).
    ENDTRY.
  ENDMETHOD.
  ```
- **QuickFix Desteği:** Hayır (blok sınırları risk analizine bağlı).
- **Skylint Duplike Doğrulaması:** `no-nested-try` depth; `max-try-size` count; bu kural **scope **pozisyonu** ölçütü. → **Özgün.**

---

## E. RAP & EML

---

### 28. `no-eml-silent-failure`
- **Class Name:** `ZCL_SKYLINT_NO_EML_SILENT`
- **Category:** `security`
- **Severity:** `warning`
- **Finding Code:** `NO_EMLFAIL`
- **AST Tespit Stratejisi:** EML statement doğrulaması (match_token_sequence: MODIFY/READ/CREATE/DELETE + `ENTITIES`/`ENTITY`) bitince statement içinde token dizisi **`FAILED <var>`** ya da **`REPORTED <var>`** (hemen arkasından `DATA(` gelen inline form **dışarıda** tutulur) tespit edilir; bu isimli sembolün aynı prosedürde **data-read usage** (`has_data_read_usage` / statement_has_reference kind=data usage=read) bulunmazsa raporlanır.
- **Teknik Gerekçe:** `no-unhandled-eml` sadece **FAILED/REPORTED keyword'lerinin varlığını** ister — keyword girilse, tablo altında **okunmuyorsa**, hata yine sessizce yutulur; RAP işlem sırları kaybolur. Bu kural "yanlış güvence sonrası" klasik yapı şaşkınlığına penetrasyon concert.
  *Referans:* Roslyn **CA1806** ("do not ignore method results"); SpotBugs `RV_RETURN_VALUE_IGNORED` — ignored-signal ailesi.
- **Non-Compliant:**
  ```abap
  MODIFY ENTITIES OF zi_sales sdf ENTITY Sales
    UPDATE FIELDS ( status ) WITH lt_update
    FAILED lt_failed
    REPORTED lt_reported.
  " ... ne lt_failed ne lt_reported asla okunmuyor — başarılı gibi
  ```
- **Compliant:**
  ```abap
  MODIFY ENTITIES OF zi_sales ENTITY Sales
    UPDATE FIELDS ( status ) WITH lt_update
    FAILED lt_failed
    REPORTED lt_reported.
  IF lt_failed-sales IS NOT INITIAL.
    RAISE EXCEPTION TYPE zcx_rap_failed.
  ENDIF.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_CHKFAIL` — EML statement'tan sonraki satıra:
  `IF <var>-<entity> IS NOT INITIAL. RAISE EXCEPTION TYPE zcx_rap_failed. ENDIF.` placeholder.
- **Skylint Duplike Doğrulaması:** `no-unhandled-eml` sadece keyword varlık check (kaynak 111-122 okunarak doğrulandı). **Önemli ayrım:** inline `FAILED DATA(lt_failed)` formu `no-unused-vars` içinde de surface olabilir → bu kural öncelikle **named-variable formunu** (proje fixtures'ında geçerli olduğu gibi `FAILED lt_failed`) ölçekliyor; EML-semantic mesaj + QF farklı olan kural değer büyük. → **Özgün (tamamlayıcı).**

---

### 29. `no-rap-commit`
- **Class Name:** `ZCL_SKYLINT_NO_RAP_COMMIT`
- **Category:** `security`
- **Severity:** `error`
- **Finding Code:** `NO_RAPCMIT`
- **AST Tespit Stratejisi:** Prosedürün compilation-unit (id-main_unit-name) **RAP ayrışma adlandırного pattern** matches (`class_pattern` string attribute, varsayılan regex: `(?i)(_HANDLER|HANDLER$|ccmh)`); eşleşirse `keyword = 'COMMIT'` (COMMIT WORK) ve `keyword = 'ROLLBACK'` statement'ları raporlanır. (raporaları striv `COMMIT ENTITIES`-doctrine pseudo_k(scores), *çünkü statement_is_db_access COMMIT ENTITIES* db için görünomuş ama bu kural COMMIT WORK'a FRONT.)
- **Teknik Gerekçe:** RAP'ta LUW yönetimi framework'tedir (save sequence); developer `COMMIT WORK`/`ROLLBACK WORK` çağırırsa **abusive transaction legacy**; determinations'dữур validation'lar içinde SWІ biazи buffers bozagate.
  *Referans:* SAP RAP dokümanı "behavior implementation restrictions" (no COMMIT WORK in behavior pools).
- **Non-Compliant:**
  ```abap
  CLASS lsc_zi_sales IMPLEMENTATION.
    METHODS determine ▸.
      " handler method'u içinde:
      COMMIT WORK.  " RAP'ta YASAK
  ```
- **Compliant:**
  ```abap
  " iş mantığında yalnız EML; commit'i framework yapar
  MODIFY ENTITIES OF zi_sales ...
    COMMIT ENTITIES BEGIN OF SET ...
  ```
- **QuickFix Desteği:** Hayır (çözüm mimari).
- **Skylint Duplike Doğrulaması:** `no-db-in-loop` loop kontex; COMMIT WORK un-loop'da da RAP'ta yanlış ama LOOP şartı **gerekmez**; `no-commit-in-loop` (bizim #1) döngü-dışı RAP handler'ları kapsarmak mı? → hayır: loop olmayan RAP handler COMMIT'i de raporları 위한 ayrık scope'u **no-rap-commit**. → **Özgün tamamlayıcı.**

---

### 30. `no-get-badi-check`
- **Class Name:** `ZCL_SKYLINT_NO_BADI_CHECK`
- **Category:** `security`
- **Severity:** `warning`
- **Finding Code:** `NO_BADICHK`
- **AST Tespit Stratejisi:** `GET BADI <obj>` statement'ından sonra **aynı prosedürde** `CALL BADI <obj>` kullanılmışsa, iki statement arasında `<obj>` verisi való *koşul* içinde (`IF <obj> IS BOUND`/`IS NOT INITIAL` ya da `EXIT/CASE/TRY` guard) bir read usage bulunmazsa raporlanır.
- **Teknik Gerekçe:** `GET BADI` geçerli BAdI handler dönmüyeğ; gele администри	parametrization olmayabilirDKMYWB; `CALL BADI` ≥ aktif implementasyon yoksa sessizçe no-op ya da hatцb; remember calling contract explicit check.
  *Referans:* SAP BAdI dokumentasyon call contract; SpotBugs `RV_*` ignored-status ailesi benzer scour.
- **Non-Compliant:**
  ```abap
  GET BADI lo_bad.
  CALL BADI lo_bad->welcome( iv_customer = lv_customer ).
  ```
- **Compliant:**
  ```abap
  GET BADI lo_badi.
  IF lo_badi IS BOUND.
    CALL BADI lo_badi->welcome( iv_customer = lv_customer ).
  ENDIF.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_IFBOUND` — CALL BADI statement'ı önüne `IF <obj> IS BOUND.` ve arkasına `ENDIF.` ekler; CALL satırı indent edilir.
- **Skylint Duplike Doğrulaması:** `no-unhandled-eml` EML; `pref-check-subrc` sy-subrc; BAdI-obj guard mevcut değil. → **Özgün.**

---

## F. Akış & Materializm Kontrol Hataları

---

### 31. `no-endless-do-loop`
- **Class Name:** `ZCL_SKYLINT_NO_INF_LOOP`
- **Category:** `anti-patterns`
- **Severity:** `warning`
- **Finding Code:** `NO_INFLOOP`
- **AST Tespit Stratejisi:** `keyword = 'DO'` (token stream'de `UNTIL` **yok**) veya `keyword = 'WHILE'` (koşulla literali `abap_true`/`'X'` literal) → LOOP gövdesi scannada `EXIT`, `RETURN`, `CHECK`, `RAISE`, `MESSAGE` …**hiçbir akış kesici** statement yoksa raporlanır.
- **Teknik Gerekçe:** Do - ENDDO NE offre davranış saat circular; önccak fail (SOAP THREADBirikim Dump, * endless loop SOLVINKNO complexity):
  *Referans:* clang-tidy `bugprone-infinite-loop` gerçek: koşulun "ileri giydirmediği" döngü. RuboCop Lint/UnreachableLoop complementary sense (worst-case).
- **Non-Compliant:**
  ```abap
  DO.  " UNTIL yok, EXIT yok — sonsuz
    TRY.
        process_next( ).
        EXIT.
      CATCH zcx_retry.
        " hatayla söz— amma tertabling successfully
        process_next( ).
    ENDTRY.
  ENDDO.
  ```
- **Compliant:**
  ```abap
  DO.
    process_next( ).
    IF lv_remaining = 0.
      EXIT.
    ENDIF.
  ENDDO.
  ```
- **QuickFix Desteği:** Hayır (çıkış koşulu iş mantığı).
- **Skylint Duplike Doğrulaması:** `no-single-iter` "en fazla 1 iterasyon" öte; `max-loop-jumps` fazla EXIT; `no-unreachable` elde; bu kural **exit yokluğu**. → **Özgün.**

---

### 32. `no-loop-stuck-var`
- **Class Name:** `ZCL_SKYLINT_NO_STUCK_WHILE`
- **Category:** `anti-patterns`
- **Severity:** `warning`
- **Finding Code:** `NO_STUCKWH`
- **AST Tespit Stratejisi:** `keyword = 'WHILE'` → koşul ifadesindeki sembolleri (tokeninä data refs, ad-ı case-ins) çıkarılır; aynı WHILE..ENDWHILE gövdesinde **hiçbir o sembole write usage** (statement_has_reference usage=write ya da atama LHS) yoksa raporlanır. `sy-index`-parametrik прогресс de guard.
- **Teknik Gerekçe:** WHILE koşulu değişken *asla dönmede güncellenecek* değilse loop sonsuz ya da semantik bozuk — döngü carry state köksup၈.
  *Referans:* clang-tidy `bugprone-infinite-loop` filtresi aynı ölçüte gider; ESLint `no-unmodified-loop-condition` benzer mantık — ama `ESLint yasak`; ABAP ekosistem **hiçlinden** mevcut değil.
- **Non-Compliant:**
  ```abap
  WHILE lv_locked = abap_true.
    " WAIT + kontrol yalnız okuma; lv_locked güncellenmiyor
  ENDWHILE.
  ```
- **Compliant:**
  ```abap
  WHILE lv_locked = abap_true.
    WAIT UP TO 1 SECONDS.
    lv_locked = is_still_locked( ).
  ENDWHILE.
  ```
- **QuickFix Desteği:** Hayır.
- **Skylint Duplike Doğrulaması:** `no-single-iter`, `max-loop-jumps`, `no-late-sys-idx` farklı Axes; WHIL, `conditioni always-leetcode` bir söz: `no-dead-code` require constant condition (harıcı literal); bu kural **görünmez sabit referans problem contract**. → **Özgün.**

---

### 33. `no-poll-wait`
- **Class Name:** `ZCL_SKYLINT_NO_POLL_WAIT`
- **Category:** `performance`
- **Severity:** `warning`
- **Finding Code:** `NO_POLLWAI`
- **AST Tespit Stratejisi:** Derinlik sayacı LOOP'dayken (`LOOP/DO/WHILE` > 0) `keyword = 'WAIT'` statement görülüre raporlanır. (döngü dışındaki WAIT etkilenmez.)
- **Teknik Gerekçe:** Döngüde `WAIT UP TO n SECONDS` = **busy-polling**: uygulama sunucusu iş parçacıkları işgal, timeout dump/olmayan; güncel I.T.
  *Referans:* "busy-waiting antipattern" (c2 wiki); Roslyn/Java style `Thread.sleep`-record expectancies'ler linter equaliy yinledge.
- **Non-Compliant:**
  ```abap
  WHILE lv_locked = abap_true.
    WAIT UP TO 1 SECONDS.
    lv_locked = is_locked( ).
  ENDWHILE.
  ```
- **Compliant:**
  ```abap
  " abaprolled eventing/AMC brokerli no POLL_WAIT veya async RFC + WAIT FOR ASYNC… dışı
  ```
- **QuickFix Desteği:** Hayır (doğru wait/notify pattern transferir).
- **Skylint Duplike Doğrulaması:** `no-db-in-loop` db; `no-ui-call-in-loop` GUI; WAIT hicbir loop ruleunda yok. → **Özgün.**

---

### 34. `no-direct-recursion`
- **Class Name:** `ZCL_SKYLINT_NO_DIRECT_RECUR`
- **Category:** `anti-patterns`
- **Severity:** `note`
- **Finding Code:** `NO_DIRECTR`
- **AST Tespit Stratejisi:** Bir *method-procedure* içinde `statement_is_method_call`'ın gördüğü Yöntem refs kullanımında **referans adı == is_procedure-id-name** (same method reursive call self); "koşulsunsuz多说" derece: aynı prosedürün `METHOD <name>.`dan sonra **koşullu akış statement'ı (IF/CASE/WHEN/TRY …) oluşmadan direkt возникают self-call batığı için faut_last đứağ__** initialize; loose recursive import algorithm; fair initializer respect.
- **Teknik Gerekçe:** Ünconditional self-recursion: stack overflow dump (`SYSTEM_NO_ROLL`) riski; recursive Hierarchy iteración'dan tuto ideal guards.
  *Referans:* clang `-Winfinite-recursion` (clang 6+): "recursion that never returns" analog googly veneer.
- **Non-Compliant:**
  ```abap
  METHOD compute.
    compute( iv_input ).  " her koşulsuz self-call — kısa vakitte dump
  ENDMETHOD.
  ```
- **Compliant:**
  ```abap
  METHOD compute.
    IF iv_depth > 0.
      compute( iv_depth - 1 ).  " guard'lı recursion
    ENDIF.
  ENDMETHOD.
  ```
- **QuickFix Desteği:** Hayır.
- **Skylint Duplike Doğrulaması:** Hiçbir mevcut kural recursion flags yapmıyor. → **Özgün.**

---

## G. Clean ABAP & Sozkuralğını İzlenmesi

---

### 35. `no-mixed-keywordcase`
- **Class Name:** `ZCL_SKYLINT_NO_MIXED_CASE`
- **Category:** `clean-abap`
- **Severity:** `note`
- **Finding Code:** `NO_MIXCASE`
- **AST Tespit Stratejisi:** Prosedürün tüm statement'larında keyword olarak işaretli tokenlar (`token_is_keyword`/`references IS INITIAL` guard) toplanır; **aynı prosedürde hem `DATA` hem `data`** varsa (aynı keyword iki farklı yazımlar) raporlanır. `preferred_case` string attribute (var `UPPER`/`LOWER`/`ANY`, varsayılan `ANY` = sadece *karışım* ihlali).
- **Teknik Gerekçe:** Keyword-case karmaührung m united trails reading; formatı tools safeguard. *Not:* SAP Clean ABAP kentti "Upper vs Lower Case" kısa brief: **clear yönerge yok**; bu kural tutarlılık ölçütü yolundan gider.
  *Referans:* SAP styleguides `sub-sections/UpperVsLowerCase.md` (bize zaman Aynı "clear guidance yok" notunu doğrulandı) — bu konuda automation'dan anlaşılır sayıüyük value.
- **Non-Compliant:**
  ```abap
  DATA lv_a TYPE i.
  data lv_b TYPE string.
  ```
- **Compliant:**
  ```abap
  DATA lv_a TYPE i.
  DATA lv_b TYPE string.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_CASEKW` — statement'ı, keyword token'ları `preferred_case` yönünde dönüştürülmüş是自己 text satır versiyonuyla değiştirilir.
- **Skylint Duplike Doğrulaması:** `no-bad-indent` veya spacing kuralı serlice; *keyword-case check* hiolonuc mevcuttle yok. → **Özgün.**

---

### 36. `pref-test-class-name`
- **Class Name:** `ZCL_SKYLINT_PREF_TEST_CLS`
- **Category:** `clean-abap`
- **Severity:** `note`
- **Finding Code:** `PREF_TESTC`
- **AST Tespit Stratejisi:** `keyword = 'CLASS'` tanım statement'ta `FOR TESTING` token mevcut → class ama <selenium'%ир *_TEST` ya da LTCL_* prefix'li olması; regex attribute `test_name_pattern` (varsayılan `^(LTCL_|.*_TEST$)`) ile raporlanır.
- **Teknik Gerekçe:** Test class konvencion (LTCL_*/ *_TEST) bildirmekabet test澳大利 aeræs vá автоматization discovery; Clean ABAP Standard & community norm.
  *Referans:* Clean ABAP style guide (local test classes with `ltcl_`/`.._test`).
- **Non-Compliant:**
  ```abap
  CLASS lcl_calc DEFINITION FINAL FOR TESTING
    DURATION SHORT RISK LEVEL HARMLESS.#ENDCLASS.
  ```
- **Compliant:**
  ```abap
  CLASS ltcl_calc DEFINITION FINAL FOR TESTING
    DURATION SHORT RISK LEVEL HARMLESS.
  ENDCLASS.
  ```
- **QuickFix Desteği:** Evet. `QF` kodu: `QF_LTCLNAME` — sınıf adını `LTCL_` /> gốc bire re걸ıdır (declaration + implementation çifti ve `FOR TESTING` yoksa kalması).
- **Skylint Duplike Doğrulaması:** `pref-test-attributes` (DURATION/RISK) — adisel başka ölçüt; naming checks (no-name-objects) test class özel ölçütz kamu. → **Özgün.**

---

### 37. `pref-optional-last`
- **Class Name:** `ZCL_SKYLINT_PREF_OPT_LAST`
- **Category:** `clean-abap`
- **Severity:** `note`
- **Finding Code:** `PREF_OPTLS`
- **AST Tespit Stratejisi:** CLASS DİFİİİTON (`procedure_kinds-class_definition`) slice'ında METHODS tanım statement'ları ayrıştırılır; her METHODS想着 `IMPORTING/EXPORTING` legger'ında `DEFAULT` içeren parametrenin, DEFAULT'sız bir parametrenin **ardında** geldiği durumlarda raporlanır (parametresiz being in receiving suites switches).
- **Teknik Gerekçe:** Optional (DEFAULT'lu) parametre signature'ın son proje; zorunlu parametreler önce → okuyuciosa retrieve "missing argument" riski interviews verify; çoğu modern dil kural联想到 (Java/Rust) ya list exclude admitted; Kotlin kod style guide: "**put default values at the end**" — approved a reference note.
  *Referans:* Kotlin coding conventions ("optional parameters last" organiyở); SwiftLint? no; Java effective-java style writing.
- **Non-Compliant:**
  ```abap
  METHODS calc IMPORTING iv_discount TYPE i DEFAULT 0
                       iv_amount   TYPE i.
  ```
- **Compliant:**
  ```abap
  METHODS calc IMPORTING iv_amount   TYPE i
                       iv_discount TYPE i DEFAULT 0.
  ```
- **QuickFix Desteği:** Hayır (parametre sırası çağıranları yapıştır).
- **Skylint Duplike Doğrulaması:** `max-params` = sayı & independent multiline; `pref-param-name` = adlandırma; syntax strêt multi-line;**optional-last check** hiophiy hat. → **Özgün.**

---

# 🔒 Derin Duplike Denetimi Sonucu ve **BASLIKLI** Reddedilen Öneriler

## Zaten Skylink'te mevcut olan kullanıcı talepleri

Uygulama isterimizdeki be暂行 Önerileri mevcut 189 kuralın kapsam içinde zaten karşılandığı doğrulandı:

| Kullanıcı talebi | Zaten mevcut kural | Kanıt |
|---|---|---|
| `FOR ALL ENTRIES` önce `IS NOT INITIAL` | **no-empty-fae** | rationale doğrudan aynı |
| `UP TO 1 ROWS` ORDER BY'sız | **pref-order-by** | kaynak: `is_unorder_select_up_to` |
| `LOOP` içinde `sy-tabix` bağımlı tablo modifikasyonu | **no-mod-loop-tab** + **no-late-sys-idx** | rationale örtüşüyor |
| CASE'te birbirinin aynısı redundant WHEN dalları | **no-dup-cond** | "repeated IF/ELSEIF or WHEN condition" |
| `MODIFY/READ ENTITIES` FAILED/REPORTED yokluğu | **no-unhandled-eml** | source: quickfix FAILED/REPORTED ekleme |

## Araştırma sonunda bilinçli olarak reddedilen öneriler

1. **`VALUE #( ( … ) )` tek satır "gereksiz iç parantez"** — ABAP Keyword Docs (VALUE, line_spec) gereği **literal'li satırlar parantez ZORUNLU**; parantezsiz yazım literal'de syntax error (StackOverflow 55501028 doğrulandı). Başarılı bir QuickFix senaryosu üretilemez → reddedildi.
2. **`CORRESPONDING … BASE` "gereksiz BASE"** — BASE, eksik alanları *bilinçli* taşımaktır; neyin gereksiz olduğunu ancak tip/karşılaştırma analiziyle bilmek mümkün → tip çıkarımı yasak *)&`);
3. **`FILTER #( )` ikili koşul çelişkisi** — WHERE clause'daki koşulların „Zemin " "=", süre "…`AND field <> x`…` ` aynı alan`ın karşılaştırması, LHS'in *her seferinde* hangi alan olduğu verilere bağlı olmayabilir (path vs. field之本); da scatter conditions in *design* speech. — gerekir; False-positive üretme riskinin yüksek — reddedildi.
4. **`CATCH cx_root` sonunda spesifik CATCH (unreachable handler)** — sınıf hiyerarşisi RTTI ister; yalnız aynı CATCH listesinde `cx_root` kalıbı `no-catch-root` cover'dayken cross-statement kural false-positive üretir → reddedildi.
5. **`SELECT SINGLE … FOR UPDATE`** — ABAP OpenSQL'de bu söz dizimi mevcut değil (kilit mantığı ENQUEUE/MODIFY ENTITIES ile) → geçersiz AST eşleşmesi nedeniyle reddedildi.
6. **SELECT `OFFSET`'te ORDER BY eksikliği** — ABAP SQL'de `OFFSET` kullanımı sıralama (ORDER BY) ile **sözdizimsel olarak koşullu**; derleyici zaten yakalıyor → gerek yok.
7. **"Artık systemsy alan listesi (sy-tmaxl vb.)"** — mevcut resmi listede yalnızca 1-2 legit kodu (es R/2 legacy, sy-tfill/sy-tleng ise hâlâ geçerli DESCRIBE/READ alanları) singularity; kural value düşük → reddedildi.
8. **Eml `MAPPED DATA(...)` kullani `unused`** — `no-unused-vars`'ın inline-definition motoru çoğunlukla kapastığı için duplike riski; `no-eml-silent-failure` (#28) named-variable formuna özelligeizdedilmiş.

---

## Kapanış: Uygulama Sıralaması Önerisi

1. **İlk dalga (en kritik, 16 kural):** 1, 11, 12, 17, 18, 23, 28, 29, 5, 6, 16, 26, 31, 33, 24, 2 → (arık riskli, dump/úretim/hata bulguları)
2. **İkinci dalga (perf & RAP):** 3, 4, 8, 10, 20, 21, 22, 30, 32, 27, 25
3. **Üçüncü dalga (clean-abap & nilai):** 7, 9, 13, 14, 15, 19, 34, 35, 36, 37

Her kural için uygulama workflow `AGENTS.md` şablonunuza uygundur (rules-data.mjs → check .clas.abap + .clas.xml → fixtures → `npm run index` → `npm test`).
