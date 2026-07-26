# Yazılımcılar İçin SQL Server 2025 / SQL Server 2025 for Developers

[![Oku / Read online](https://img.shields.io/badge/%F0%9F%93%96_oku-online-0a6b73?style=flat-square)](https://dmcteknoloji.github.io/sql-server-2025-gelistirici-kitabi/)
[![Verify examples](https://github.com/dmcteknoloji/sql-server-2025-gelistirici-kitabi/actions/workflows/verify-examples.yml/badge.svg)](https://github.com/dmcteknoloji/sql-server-2025-gelistirici-kitabi/actions/workflows/verify-examples.yml)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg?style=flat-square)](LICENSE)

> **Yazılım geliştiriciler, yazılım uzmanları ve SQL developer'lar için** SQL Server 2025 e-book'u.
> An SQL Server 2025 ebook **for software developers, software specialists and SQL developers.**

Bol örnekli, kaynakçalı ve **canlı bir SQL Server 2025 örneğinde (RTM-CU7, 17.0.4065.4) doğrulanmış**.
Example-rich, fully sourced, and **validated on a live SQL Server 2025 instance (RTM-CU7, 17.0.4065.4).**

DMC Bilgi Teknolojileri · İki dilli (TR + EN) / Bilingual

🎬 **Tanıtım filmi / Trailer:** [Türkçe](https://github.com/dmcteknoloji/sql-server-2025-gelistirici-kitabi/releases/download/v2.0/SQL-Server-2025-Tanitim-TR.mp4) · [English](https://github.com/dmcteknoloji/sql-server-2025-gelistirici-kitabi/releases/download/v2.0/SQL-Server-2025-Trailer-EN.mp4)

---

## 📘 E-book / The ebook

GitHub `.docx` dosyalarını önizleyemez, **tarayıcıda okumak için PDF'e tıkla.**
GitHub can't preview `.docx`, **click the PDF to read in the browser.**

| Dil / Language | 📖 PDF (görüntüle / view) | 📝 .docx (düzenle / edit) | 📚 EPUB (e-okuyucu / e-reader) | 📄 Markdown |
|---|---|---|---|---|
| 🇹🇷 Türkçe | **[pdf/…-TR.pdf](pdf/SQL-Server-2025-Gelistirici-Kitabi-TR.pdf)** | [docx/…-TR.docx](docx/SQL-Server-2025-Gelistirici-Kitabi-TR.docx) | [epub/…-TR.epub](epub/SQL-Server-2025-Gelistirici-Kitabi-TR.epub) | [tr/README.md](tr/README.md) |
| 🇬🇧 English | **[pdf/…-EN.pdf](pdf/SQL-Server-2025-Developer-Handbook-EN.pdf)** | [docx/…-EN.docx](docx/SQL-Server-2025-Developer-Handbook-EN.docx) | [epub/…-EN.epub](epub/SQL-Server-2025-Developer-Handbook-EN.epub) | [en/README.md](en/README.md) |

Çalıştırılabilir T-SQL örnekleri / Runnable T-SQL examples → [`examples/`](examples/)

---

## 🇹🇷 Ne var içinde?

Bu kitap SQL Server 2025'i bir DBA gözünden değil, **uygulama yazan mühendisin gözünden** anlatır. Neredeyse her örnek gerçek bir motorda çalıştırılıp **çıktısıyla** verilmiştir; kutu ürünle Azure SQL/Fabric'in ayrıştığı yerler açıkça belirtilir.

1. **Giriş & Ortam**, Docker ile 60 saniyede kurulum, `PREVIEW_FEATURES`, uyumluluk düzeyi 170
2. **Yapay Zekâ & Vektör Arama**, `vector` tipi, `VECTOR_DISTANCE`, DiskANN indeks, `VECTOR_SEARCH`, `CREATE EXTERNAL MODEL`, `AI_GENERATE_EMBEDDINGS/CHUNKS`, .NET & EF Core 10
3. **Native JSON**, `json` tipi, `JSON_VALUE/QUERY/MODIFY`, `OPENJSON`, `JSON_OBJECTAGG/ARRAYAGG`
4. **RegEx & String**, `REGEXP_*`, fuzzy eşleşme, yeni fonksiyonlar
5. **Uygulama Entegrasyonu**, REST çağrısı, Data API Builder, SQL MCP Server, Change Event Streaming
6. **Eşzamanlılık & Performans**, Optimized Locking, OPPO, IQP, Query Store
7. **Güvenlik**, parametreleme, Always Encrypted, RLS, DDM, TLS 1.3
8. **Koddan Bağlanma**, .NET, EF Core 10, Python
9. **Yükseltme & Uyumluluk**, kaldırılanlar, kutu vs bulut farkları
10. **Sık Karşılaşılan Hatalar & Sorun Giderme**, gerçek hata mesajları + çözümler
11. **Pratik Tarifler (Cookbook)**, hibrit arama, JSON audit, RegEx CHECK
12. **2022 → 2025 Developer Farkları** + 13. **Sözlük** + 14. **Kaynakça**

🎨 **Görsellerle:** 8 diyagram (RAG hattı, exact vs DiskANN, CES, Optimized Locking, güvenlik katmanları…), **sözdizimi renklendirmeli** kod ve **kendi ölçümümde alınmış** performans grafiği (exact ~13 ms vs ANN ~5 ms).

🚀 **Uçtan uca canlı RAG mini-projesi** (Böl. 11.4): gerçek embedding'ler (Ollama `all-minilm`) → `vector(384)` → canlı `VECTOR_DISTANCE` → **canlı Data API Builder REST** çıktısı. In-Memory OLTP ve Ledger de canlı doğrulandı.

✍️ **Yazar:** Çağlar Özenç, DMC Bilgi Teknolojileri Kurucusu, **Microsoft Data Platform MVP** · [caglarozenc.com](https://caglarozenc.com)

> **Yazarken dört gerçek geliştirici tuzağına takıldım:** vektör indeks için `SET QUOTED_IDENTIFIER ON`; kutuda `TOP_N` (Azure/Fabric'te `WITH APPROXIMATE`); `VECTOR_SEARCH` alias kuralı; ve `REGEXP_LIKE`'ın bir **yüklem** (skaler değil) olması.

## 🇬🇧 What's inside?

This book explains SQL Server 2025 from the perspective of **an engineer who builds applications**, not a DBA. Nearly every example was executed on a real engine and is shown **with its output**; wherever the box product diverges from Azure SQL / Fabric, the difference is called out.

1. **Introduction & Setup**, 60-second Docker setup, `PREVIEW_FEATURES`, compatibility level 170
2. **AI & Vector Search**, `vector` type, `VECTOR_DISTANCE`, DiskANN index, `VECTOR_SEARCH`, `CREATE EXTERNAL MODEL`, `AI_GENERATE_EMBEDDINGS/CHUNKS`, .NET & EF Core 10
3. **Native JSON**, `json` type, `JSON_VALUE/QUERY/MODIFY`, `OPENJSON`, `JSON_OBJECTAGG/ARRAYAGG`
4. **RegEx & String**, `REGEXP_*`, fuzzy matching, new functions
5. **Application Integration**, REST calls, Data API Builder, SQL MCP Server, Change Event Streaming
6. **Concurrency & Performance**, Optimized Locking, OPPO, IQP, Query Store
7. **Security**, parameterization, Always Encrypted, RLS, DDM, TLS 1.3
8. **Connecting from Code**, .NET, EF Core 10, Python
9. **Upgrade & Compatibility**, removals, box vs cloud differences
10. **Common Errors & Troubleshooting**, real error messages + fixes
11. **Practical Recipes (Cookbook)**, hybrid search, JSON audit, RegEx CHECK
12. **2022 → 2025 Developer Differences** + 13. **Glossary** + 14. **References**

🎨 **Illustrated:** 8 diagrams (RAG pipeline, exact vs DiskANN, CES, Optimized Locking, security layers…), **syntax-highlighted** code and a **live-measured** performance chart (exact ~13 ms vs ANN ~5 ms).

🚀 **End-to-end live RAG mini-project** (Ch. 11.4): real embeddings (Ollama `all-minilm`) → `vector(384)` → live `VECTOR_DISTANCE` → **live Data API Builder REST** output. In-Memory OLTP and Ledger are verified live too.

✍️ **Author:** Çağlar Özenç, Founder of DMC Bilgi Teknolojileri, **Microsoft Data Platform MVP** · [caglarozenc.com](https://caglarozenc.com)

> **While writing this I hit four real developer traps:** `SET QUOTED_IDENTIFIER ON` for the vector index; `TOP_N` on the box vs `WITH APPROXIMATE` on Azure/Fabric; the `VECTOR_SEARCH` alias rule; and that `REGEXP_LIKE` is a **predicate**, not a scalar.

---

## 🚀 Hızlı başlangıç / Quick start

```bash
# SQL Server 2025 (Developer Edition, ücretsiz / free) - Docker
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Strong#Passw0rd" \
  -e "MSSQL_PID=Developer" -p 1433:1433 --name sqldev2025 -d \
  mcr.microsoft.com/mssql/server:2025-latest

# Örnekleri çalıştır / Run the examples
docker cp examples/00-lab-setup-and-examples.sql sqldev2025:/tmp/ex.sql
docker exec -it sqldev2025 /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'Strong#Passw0rd' -C -No -i /tmp/ex.sql
```

---

## 📄 Lisans / License

İçerik **CC BY 4.0** ile lisanslanmıştır; koddaki örnekler serbestçe kullanılabilir. Bkz. [LICENSE](LICENSE).
Content is licensed under **CC BY 4.0**; the code examples are free to use. See [LICENSE](LICENSE).

© DMC Bilgi Teknolojileri, [dmcteknoloji.com](https://dmcteknoloji.com)

> Örnekler canlı bir SQL Server 2025 örneğinde doğrulanmıştır; kesin sözdizimini kurulu derlemene ve resmi dokümana karşı teyit et, önizleme özellikleri GA'ya kadar değişebilir.
> Examples were validated on a live SQL Server 2025 instance; verify exact syntax against your installed build and the official docs, preview features may change before GA.
