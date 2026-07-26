# AlwaysEncryptedDemo (.NET 10)

SQL Server 2025 **Always Encrypted**'ı tamamen **yerel** (Azure ya da Windows sertifika deposu
olmadan) gösteren, `dotnet build` ile hatasız derlenen örnek (kitap Bölüm 7.6).

Column Master Key olarak self-signed bir RSA sertifikası, `Microsoft.Data.SqlClient`'ta özel bir
`SqlColumnEncryptionKeyStoreProvider` ile kullanılır. İstemci Ssn kolonunu şifreleyip yazar ve
deşifre okur; anahtarı olmayan düz bir sorgu yalnızca ciphertext görür.

```bash
export SQL_CONN="Server=localhost,14333;Database=DevBook;User Id=sa;Password=***;Encrypt=True;TrustServerCertificate=True;Column Encryption Setting=Enabled"
dotnet run
```

İlk çalıştırmada `cmk.pfx` (self-signed CMK) üretilir ve yerelde kalır, depoya **eklenmez**.
