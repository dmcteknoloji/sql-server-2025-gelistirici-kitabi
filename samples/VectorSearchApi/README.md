# VectorSearchApi (.NET 10 minimal API)

SQL Server 2025 vektör aramasını bir REST endpoint'ine bağlayan **derlenip çalışan** örnek
(kitap Bölüm 8, "Koddan Bağlanma"). `dotnet build` ile hatasız derlenir.

```bash
export SQL_CONN="Server=localhost;Database=DevBook;User Id=sa;Password=***;Encrypt=True;TrustServerCertificate=True"
dotnet run
# GET http://localhost:5xxx/search?q=0.3,0.3,0.3,...   (virgülle ayrılmış 384 float)
```

Vektör, taşınabilirlik için JSON dizisi metni olarak gönderilip motorda `CAST(... AS vector(384))`
ile dönüştürülür. `Microsoft.Data.SqlClient` 6.1+ ile native `SqlVector<float>` + `SqlDbType.Vector`
de kullanılabilir (Program.cs içindeki nota bakın).
