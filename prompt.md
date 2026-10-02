# 🤖 Skylint Rules Batch Refactoring: Universal AST Utility Migration Prompt

Bu prompt, **Skylint** linter projesindeki kural sınıflarında (`src/checks/zcl_skylint_check_*.clas.abap`) yer alan manuel indeks aritmetiğini, doğrudan dizi erişimlerini (`tokens[ i ]`, `READ TABLE ... INDEX`) ve eski/kaldırılmış yardımcı metotları (`get_token_safe`, `get_statement_safe`), yeni ve güçlü **`zcl_skylint_ast_util`** sınıfına geçirmek amacıyla hazırlanmıştır.

---

## 🎯 Ana Hedef & Sorumluluk
1. `zcl_skylint_ast_util` içerisinden kaldırılan eski `get_token_safe` ve `get_statement_safe` metotlarını kullanan **18 öncelikli dosyayı** yeni fonksiyonel metotlara dönüştür.
2. Tüm check sınıflarındaki (`zcl_skylint_check_001` - `zcl_skylint_check_079`) manuel indeks kontrollerini, `tokens[ i ]` veya `lines( is_statement-tokens )` kontrollerini `zcl_skylint_ast_util` metotlarıyla sadeleştir.
3. Gereksiz kalan bayrak değişkenlerini (`lv_found`, `lv_found_next`, `lv_found1`, `lv_idx` vb.) metot başındaki `DATA` bloklarından temizle.
4. `npm run lint` (0 issue) ve `npm test` (tüm kurallar yeşil) ile doğrula.

---

## 📚 `zcl_skylint_ast_util` Tam API Referansı

Aşağıdaki tüm metotlar güvenlidir (`safe`); sınır dışı indekslerde exception/dump fırlatmaz, boş/initial yapı döner.

### 1. Token Erişim Metotları
- **`get_token( is_statement, iv_index )`**: Belirtilen indeksteki (1-tabanlı) `ty_token` yapısını döner. Bulunamazsa boş döner.
- **`get_token_lexeme( is_statement, iv_index, iv_case_sensitive )`**: Belirtilen indeksteki token'ın lexeme metnini döner (varsayılan: büyük harf).
- **`get_first_token( is_statement )`**: Cümlenin ilk token'ını döner.
- **`get_last_token( is_statement )`**: Cümlenin son token'ını döner.
- **`token_count( is_statement )`**: Cümledeki token sayısını döner (`lines( is_statement-tokens )` yerine).

### 2. Göreceli (Relative) Token İşlemleri (İndeks Aritmetiğini Bitiren Metotlar)
- **`find_token( is_statement, iv_lexeme, iv_start_index, iv_case_sensitive )`**: Belirtilen lexeme'in indeksini döner (yoksa 0).
- **`get_token_after( is_statement, iv_lexeme, iv_start_index, iv_case_sensitive )`**: Belirtilen kelimeden hemen sonraki (`index + 1`) token'ı döner.
- **`get_token_before( is_statement, iv_lexeme, iv_start_index, iv_case_sensitive )`**: Belirtilen kelimeden hemen önceki (`index - 1`) token'ı döner.
- **`find_token_sequence( is_statement, it_expected, iv_start_index, iv_case_sensitive )`**: Token dizisinin başlangıç indeksini döner.
- **`get_token_after_sequence( is_statement, it_expected, iv_start_index, iv_case_sensitive )`**: Token dizisinden hemen sonraki token'ı doğrudan döner.
- **`matches_token_at( is_statement, iv_index, iv_expected, iv_case_sensitive )`**: Belirtilen indeksteki token'ın beklenen metinle eşleşip eşleşmediğini döner (`abap_bool`).
- **`match_token_sequence( is_statement, it_expected, iv_start_index, iv_case_sensitive )`**: Dizi eşleşiyor mu kontrolü döner (`abap_bool`).
- **`has_token_lexeme( is_statement, iv_lexeme )`**: Cümle içinde bu lexeme var mı kontrol eder (`abap_bool`).

### 3. Cümle (Statement) Erişim Metotları
- **`get_statement( it_statements, iv_index )`**: Belirtilen indeksteki cümleyi döner (yoksa initial döner).
- **`get_next_statement( it_statements, iv_current_index )`**: `iv_current_index + 1` deki cümleyi döner (boşsa initial döner).
- **`get_previous_statement( it_statements, iv_current_index )`**: `iv_current_index - 1` deki cümleyi döner.
- **`statement_count( it_statements )`**: Tablodaki cümle sayısını döner.
- **`statement_is_method_call( is_statement )`**: Cümlenin metot çağrısı olup olmadığını döner (`+CALL_METHOD`, `CALL`, veya compiler referanslı).
- **`is_assignment( is_statement )`**: Cümlenin atama (`COMPUTE` veya type `'C'`) olup olmadığını döner.

### 4. Semantik ve Tip Doğrulayıcılar
- **`token_is_literal( is_token )`**: Token literal mi kontrol eder (`'...'`, `` `...` ``, `|...|`, sayılar veya type `'S'`).
- **`token_is_identifier( is_token )`**: Token geçerli değişken/sembol adı mı kontrol eder.
- **`is_comparison_operator( iv_lexeme )`**: `=`, `<>`, `<`, `>`, `<=`, `>=`, `EQ`, `NE`, `CP` vb. karşılaştırma operatörü mü kontrol eder.
- **`has_compiler_reference( is_token, iv_kind, iv_usage_mode )`**: Token üzerinde beklenen compiler referansı var mı kontrol eder.

---

## 🔄 Dönüşüm Şablonları (Before & After)

### Şablon 1: `get_token_safe` ve `tokens[ i ]` Değişimi
```abap
" ❌ ESKİ (Kaldırıldı)
DATA ls_token TYPE zif_skylint_types=>ty_token.
DATA lv_found TYPE abap_bool.

zcl_skylint_ast_util=>get_token_safe(
    EXPORTING is_statement = is_statement
              iv_index     = 2
    IMPORTING es_token     = ls_token
              ev_found     = lv_found ).
IF lv_found = abap_true AND ls_token-lexeme = 'TABLE'.
  ...
ENDIF.

" ✅ YENİ (Tek satır, dump korumalı, bayraksız)
DATA ls_token TYPE zif_skylint_types=>ty_token.

ls_token = zcl_skylint_ast_util=>get_token(
    is_statement = is_statement
    iv_index     = 2 ).
IF ls_token-lexeme = 'TABLE'.
  ...
ENDIF.

" ✅ DAHA DA TEMİZİ (Sadece değer veya eşleşme kontrolü için):
IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement iv_index = 2 iv_expected = 'TABLE' ) = abap_true.
  ...
ENDIF.
```

---

### Şablon 2: `get_statement_safe` ile Sonraki / Önceki Cümle Erişimi
```abap
" ❌ ESKİ
DATA lv_idx TYPE i.
DATA ls_next TYPE zif_skylint_types=>ty_statement.
DATA lv_found TYPE abap_bool.

LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
  lv_idx = sy-tabix.
  zcl_skylint_ast_util=>get_statement_safe(
      EXPORTING it_statements = is_procedure-statements
                iv_index      = lv_idx + 1
      IMPORTING es_statement  = ls_next
                ev_found      = lv_found ).
  IF lv_found = abap_true AND ls_next-keyword = 'ENDIF'.
    ...
  ENDIF.
ENDLOOP.

" ✅ YENİ (Manuel +1 yok, lv_idx yok, lv_found yok)
DATA ls_next TYPE zif_skylint_types=>ty_statement.

LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
  ls_next = zcl_skylint_ast_util=>get_next_statement(
      it_statements    = is_procedure-statements
      iv_current_index = sy-tabix ).
  IF ls_next-keyword = 'ENDIF'.
    ...
  ENDIF.
ENDLOOP.
```

---

### Şablon 3: Token Dizisi veya Anahtar Kelimeden Sonraki Token'ı Alma
```abap
" ❌ ESKİ (Manuel index aritmetiği: pos + 4)
lt_expected = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ).
lv_pos = zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement it_expected = lt_expected ).
IF lv_pos > 0.
  zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement iv_index = lv_pos + 4 IMPORTING es_token = ls_token ev_found = lv_found ).
ENDIF.

" ✅ YENİ (Tek çağrı ile doğrudan hedeflenen token)
ls_token = zcl_skylint_ast_util=>get_token_after_sequence(
    is_statement = is_statement
    it_expected  = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ) ).
```

Kelime bazlı (örn: `TYPE` sonrası değişken tipi):
```abap
ls_type_tok = zcl_skylint_ast_util=>get_token_after(
    is_statement = <ls_statement>
    iv_lexeme    = 'TYPE' ).
```

---

### Şablon 4: Token Sayısı ve İndeks Kontrolleri
```abap
" ❌ ESKİ
IF lines( is_statement-tokens ) <> 3.
  RETURN.
ENDIF.

" ✅ YENİ
IF zcl_skylint_ast_util=>token_count( is_statement ) <> 3.
  RETURN.
ENDIF.
```

---

## 🚨 Öncelikli Dosyalar (Derlemeyi Bloklayan 18 Kural)

Bu dosyalarda kaldırılan `get_token_safe` ve `get_statement_safe` metotları bulunmaktadır. İlk olarak bu 18 dosyayı düzelt:

1. `src/checks/zcl_skylint_check_004.clas.abap`
2. `src/checks/zcl_skylint_check_008.clas.abap`
3. `src/checks/zcl_skylint_check_010.clas.abap`
4. `src/checks/zcl_skylint_check_016.clas.abap`
5. `src/checks/zcl_skylint_check_017.clas.abap`
6. `src/checks/zcl_skylint_check_019.clas.abap`
7. `src/checks/zcl_skylint_check_024.clas.abap`
8. `src/checks/zcl_skylint_check_025.clas.abap`
9. `src/checks/zcl_skylint_check_033.clas.abap`
10. `src/checks/zcl_skylint_check_036.clas.abap`
11. `src/checks/zcl_skylint_check_039.clas.abap`
12. `src/checks/zcl_skylint_check_041.clas.abap`
13. `src/checks/zcl_skylint_check_047.clas.abap`
14. `src/checks/zcl_skylint_check_069.clas.abap`
15. `src/checks/zcl_skylint_check_070.clas.abap`
16. `src/checks/zcl_skylint_check_073.clas.abap`
17. `src/checks/zcl_skylint_check_074.clas.abap`
18. `src/checks/zcl_skylint_check_075.clas.abap`

Ardından kalan tüm check sınıflarını (`zcl_skylint_check_001` - `zcl_skylint_check_079`) tarayarak manuel indeks hesaplarını `zcl_skylint_ast_util` metotlarına refactor et.

---

## ⚖️ Clean ABAP Kuralları (abaplint ile %100 Uyum)

Refactoring sırasında abaplint kurallarını ihlal etmemek için şu kurallara **kesinlikle** uy:
- **No Inline Declarations:** Asla `DATA(...)` veya `ASSIGN ... TO FIELD-SYMBOL(...)` yazma. Tüm `DATA` ve `FIELD-SYMBOLS` tanımları metot başında olmalı.
- **Unused Variables:** Artık ihtiyaç kalmayan `lv_found`, `lv_found_next`, `lv_idx` gibi değişkenleri metot başındaki `DATA` bloğundan kaldır.
- **No End-Of-Line Comments:** Satır sonuna asla yorum ekleme (`" ...`). Yorumlar kendi bağımsız satırında olmalıdır.
- **No IF in IF:** İç içe `IF` blokları yerine `IF cond1 AND cond2.` birleşimini tercih et.
- **Keyword Casing:** Tüm ABAP anahtar kelimeleri ve metot isimleri büyük harfle (`UPPERCASE`) yazılmalıdır.

---

## ✅ Doğrulama & Kontrol Listesi

Her dosya grubunu düzenledikten sonra terminalden sırasıyla şunları çalıştır:
```bash
npm run lint
```
*(Sonuç: `abaplint: 0 issue(s) found` olmalıdır).*

```bash
npm test
```
*(Sonuç: Tüm kural ve test modülleri başarıyla geçmeli, exit code 0 olmalıdır).*

```bash
npm run index
```
*(Sonuç: Indexer çalışmalı ve README güncellenmelidir).*
