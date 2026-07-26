/* ============================================================================
   SQL Server 2025 : Geliştirici Kitabı / Developer Handbook
   Çalıştırılabilir örnekler. SQL Server 2025 (RTM-CU7, 17.0.4065.4) üzerinde
   doğrulanmıştır. / Runnable examples, validated on SQL Server 2025.

   Docker ile ortam / Spin up the lab:
     docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Strong#Passw0rd" \
       -e "MSSQL_PID=Developer" -p 1433:1433 --name sqldev2025 -d \
       mcr.microsoft.com/mssql/server:2025-latest
   ============================================================================ */

------------------------------------------------------------------------------
-- 0) Veritabanı + önizleme + uyumluluk düzeyi / DB + preview + compat level
------------------------------------------------------------------------------
IF DB_ID('DevBook') IS NULL CREATE DATABASE DevBook;
GO
ALTER DATABASE DevBook SET COMPATIBILITY_LEVEL = 170;
GO
USE DevBook;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO
SET QUOTED_IDENTIFIER ON;   -- CREATE VECTOR INDEX bunu ister / required for vector index
GO

------------------------------------------------------------------------------
-- 1) Vektör fonksiyonları / Vector functions
------------------------------------------------------------------------------
DECLARE @a vector(3) = '[1,2,3]', @b vector(3) = '[2,3,4]';
SELECT VECTOR_DISTANCE('cosine', @a, @b)     AS cosine_dist,
       VECTOR_DISTANCE('euclidean', @a, @b)  AS euclid_dist,
       VECTOR_NORM(@a, 'norm2')              AS l2norm,
       CAST(VECTOR_NORMALIZE(@a, 'norm2') AS varchar(64)) AS normalized,
       VECTORPROPERTY(@a,'Dimensions')       AS dims,
       VECTORPROPERTY(@a,'BaseType')         AS basetype;
GO

------------------------------------------------------------------------------
-- 2) Vektör tablosu + DiskANN indeks + arama / Vector table + index + search
------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Articles;
CREATE TABLE dbo.Articles (id int PRIMARY KEY, title nvarchar(100), embedding vector(5));
INSERT dbo.Articles (id, title, embedding)
SELECT value, 'Article ' || value,
       CAST(JSON_ARRAY(value*0.01, value*0.02, value*0.03, value*0.04, value*0.05) AS vector(5))
FROM GENERATE_SERIES(1, 100);
GO
CREATE VECTOR INDEX vec_idx ON dbo.Articles(embedding) WITH (METRIC = 'cosine', TYPE = 'diskann');
GO
-- Exact (kNN) : her yerde çalışır / works everywhere:
DECLARE @qv vector(5) = '[0.3,0.3,0.3,0.3,0.3]';
SELECT TOP (3) id, title, VECTOR_DISTANCE('cosine', embedding, @qv) AS dist
FROM dbo.Articles ORDER BY dist;
GO
-- Approximate (ANN) : SQL Server 2025 kutu sözdizimi (TOP_N) / box syntax:
--   Tablo kolonları t alias'ı, distance s alias'ı / table cols via t, distance via s
DECLARE @qv vector(5) = '[0.3,0.3,0.3,0.3,0.3]';
SELECT t.id, t.title, s.distance
FROM VECTOR_SEARCH(TABLE = dbo.Articles AS t, COLUMN = embedding,
                   SIMILAR_TO = @qv, METRIC = 'cosine', TOP_N = 3) AS s
ORDER BY s.distance;
GO
-- Azure SQL DB / Fabric SQL (en güncel indeks) sözdizimi / latest-index syntax:
--   SELECT TOP (3) WITH APPROXIMATE t.id, s.distance
--   FROM VECTOR_SEARCH(TABLE=dbo.Articles AS t, COLUMN=embedding,
--                      SIMILAR_TO=@qv, METRIC='cosine') AS s
--   ORDER BY s.distance;

------------------------------------------------------------------------------
-- 3) Metni parçala (harici uç nokta gerektirmez) / Chunk text (no endpoint)
------------------------------------------------------------------------------
SELECT c.chunk, c.chunk_order, c.chunk_length
FROM (VALUES (N'SQL Server 2025 yazılımcılar için yerleşik vektör ve JSON getirir.')) d(t)
CROSS APPLY AI_GENERATE_CHUNKS(SOURCE = d.t, CHUNK_TYPE = FIXED, CHUNK_SIZE = 25, OVERLAP = 0) AS c;
GO

------------------------------------------------------------------------------
-- 4) Native JSON
------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders (Id int IDENTITY PRIMARY KEY, Doc json);
INSERT dbo.Orders (Doc) VALUES
 (N'{"customer":"Ada","total":1290.50,"items":["ssd","ram"],"paid":true}'),
 (N'{"customer":"Linus","total":540.00,"items":["kbd"],"paid":false}');
GO
SELECT Id, JSON_VALUE(Doc,'$.customer') AS customer,
       CAST(JSON_VALUE(Doc,'$.total') AS decimal(10,2)) AS total,
       JSON_QUERY(Doc,'$.items') AS items, ISJSON(Doc) AS is_valid
FROM dbo.Orders;
UPDATE dbo.Orders SET Doc = JSON_MODIFY(Doc,'$.paid','true') WHERE Id = 2;
SELECT JSON_ARRAYAGG(JSON_VALUE(Doc,'$.customer')) AS customers,
       JSON_OBJECTAGG(JSON_VALUE(Doc,'$.customer') : CAST(JSON_VALUE(Doc,'$.total') AS decimal(10,2))) AS totals
FROM dbo.Orders;
SELECT o.Id, j.[value] AS item FROM dbo.Orders o CROSS APPLY OPENJSON(o.Doc,'$.items') j;
GO

------------------------------------------------------------------------------
-- 5) RegEx & string
------------------------------------------------------------------------------
SELECT REGEXP_REPLACE('  çok   fazla    boşluk ','\s+',' ') AS normalized,
       REGEXP_SUBSTR('SKU: ABC-12345 stok','[A-Z]{3}-\d{5}') AS sku,
       REGEXP_COUNT('a1b2c3d4','\d') AS digit_count,
       REGEXP_INSTR('order-2026','\d{4}') AS year_pos;
-- REGEXP_LIKE bir YÜKLEMDİR / is a PREDICATE : WHERE/CASE içinde:
SELECT email FROM (VALUES('gecerli@x.com'),('gecersiz@@')) c(email)
WHERE NOT REGEXP_LIKE(email,'^[\w.+-]+@[\w-]+\.[\w.-]+$');
SELECT value FROM REGEXP_SPLIT_TO_TABLE('sql,server;2025|dev','[,;|]');
-- Fuzzy (önizleme / preview):
SELECT EDIT_DISTANCE('Istanbul','Istambul') AS edit_dist,
       EDIT_DISTANCE_SIMILARITY('Istanbul','Istambul') AS edit_sim,
       JARO_WINKLER_SIMILARITY('Ankara','Ankraa') AS jw_sim;
GO

------------------------------------------------------------------------------
-- 6) Yeni fonksiyonlar / New functions
------------------------------------------------------------------------------
SELECT 'sql'||'-'||'2025' AS pipe_concat, GREATEST(3,9,4,7) AS greatest_v,
       LEAST(3,9,4,7) AS least_v, CURRENT_DATE AS today,
       BASE64_ENCODE(CAST('DMC' AS varbinary(8))) AS b64,
       CAST(BASE64_DECODE('RE1D') AS varchar(8)) AS b64_back;
SELECT category, PRODUCT(factor) AS compound
FROM (VALUES('growth',1.10),('growth',1.05),('growth',1.20)) t(category,factor) GROUP BY category;
SELECT STRING_AGG(CAST(value AS varchar(4)),',') AS series FROM GENERATE_SERIES(1,10,2);
GO

------------------------------------------------------------------------------
-- 7) Eşzamanlılık / Concurrency : Optimized Locking (ADR + RCSI)
------------------------------------------------------------------------------
ALTER DATABASE DevBook SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE DevBook SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
SELECT is_accelerated_database_recovery_on AS adr, is_read_committed_snapshot_on AS rcsi
FROM sys.databases WHERE name = 'DevBook';
GO

------------------------------------------------------------------------------
-- 8) Güvenlik / Security : RLS/DDM (maskeleme != yetkilendirme / masking != authz)
------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Customers;
CREATE TABLE dbo.Customers (Id int, TenantId int,
    Tckn char(11) MASKED WITH (FUNCTION = 'partial(0,"*********",2)'));
INSERT dbo.Customers VALUES (1,10,'12345678901'), (2,20,'98765432109');
SELECT Id, TenantId, Tckn FROM dbo.Customers;  -- UNMASK yetkilisi tam görür / privileged sees full
GO

------------------------------------------------------------------------------
-- 9) Pratik tarifler / Cookbook (kitap Bölüm 11) : hepsi doğrulanmıştır
------------------------------------------------------------------------------
-- 9.1 Hibrit arama: vektör + anahtar kelime / Hybrid: vector + keyword
DECLARE @qh vector(5) = '[0.3,0.3,0.3,0.3,0.3]';
SELECT TOP (3) id, title, VECTOR_DISTANCE('cosine', embedding, @qh) AS dist
FROM dbo.Articles WHERE title LIKE '%1%' ORDER BY dist;
GO
-- 9.2 JSON denetim günlüğü / JSON audit log
DROP TABLE IF EXISTS dbo.Audit;
CREATE TABLE dbo.Audit (Id int IDENTITY, Event json);
INSERT dbo.Audit (Event) VALUES
 (N'{"user":"ada","action":"login","ok":true}'),
 (N'{"user":"ada","action":"delete","ok":false}');
SELECT JSON_VALUE(Event,'$.user') AS usr, COUNT(*) AS delete_count
FROM dbo.Audit WHERE JSON_VALUE(Event,'$.action') = 'delete'
GROUP BY JSON_VALUE(Event,'$.user');
GO
-- 9.3 RegEx CHECK kısıtı / RegEx CHECK constraint (REGEXP_LIKE bir yüklem / a predicate)
DROP TABLE IF EXISTS dbo.Signup;
CREATE TABLE dbo.Signup (email nvarchar(200)
    CHECK (REGEXP_LIKE(email, '^[\w.+-]+@[\w-]+\.[\w.-]+$')));
INSERT dbo.Signup VALUES ('ok@dmc.com');   -- kabul / accepted
GO

------------------------------------------------------------------------------
-- 10) Saha örnekleri / Field examples (kitap Bölüm 2-7) -- doğrulanmıştir
------------------------------------------------------------------------------
-- 10.1 Benzer destek biletleri / similar support tickets
SET QUOTED_IDENTIFIER ON;
DROP TABLE IF EXISTS dbo.Tickets;
CREATE TABLE dbo.Tickets (id int PRIMARY KEY, subject nvarchar(60), v vector(3));
INSERT dbo.Tickets VALUES
 (1,'Query runs very slowly','[0.90,0.10,0.05]'),
 (2,'App cannot connect','[0.10,0.90,0.10]'),
 (3,'Report screen opens late','[0.82,0.18,0.08]'),
 (4,'Nightly backup failed','[0.08,0.12,0.90]');
GO
DECLARE @new vector(3) = '[0.88,0.12,0.06]';
SELECT TOP 2 id, subject, ROUND(VECTOR_DISTANCE('cosine', v, @new),4) AS distance
FROM dbo.Tickets ORDER BY distance;
GO
-- 10.2 Belirli urunu iceren siparisler / orders containing a product
SELECT Id, JSON_VALUE(Doc,'$.customer') AS customer
FROM dbo.Orders WHERE 'ssd' IN (SELECT value FROM OPENJSON(Doc,'$.items'));
GO
-- 10.3 TR telefon + IBAN dogrulama / phone + IBAN validation
SELECT val,
  CASE WHEN REGEXP_LIKE(val,'^\+90 ?\d{3} ?\d{3} ?\d{2} ?\d{2}$') THEN 'phone OK'
       WHEN REGEXP_LIKE(val,'^TR\d{24}$') THEN 'IBAN OK' ELSE 'invalid' END AS result
FROM (VALUES ('+90 212 945 61 66'),('TR330006100519786457841326'),('broken-data')) v(val);
GO
