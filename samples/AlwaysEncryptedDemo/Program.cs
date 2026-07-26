// Always Encrypted, tamamen yerel (Azure/Windows olmadan).
// Column Master Key = self-signed RSA sertifikası; anahtar sağlayıcısı özel (custom).
// İstemci veriyi şifreleyip yazar/okur; düz bir sorgu yalnızca ciphertext görür.
using Microsoft.Data.SqlClient;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

string cs = Environment.GetEnvironmentVariable("SQL_CONN")
    ?? "Server=localhost,14333;Database=DevBook;User Id=sa;Password=Dev@Sql2025!Lab;"
     + "Encrypt=True;TrustServerCertificate=True;Column Encryption Setting=Enabled";

// 1) CMK sertifikası (self-signed RSA), PFX'e kalıcı -> provizyon + çalışma aynı anahtarı kullanır
const string PfxPath = "cmk.pfx"; const string PfxPwd = "Cmk#Dev2025";
X509Certificate2 cert;
if (File.Exists(PfxPath))
    cert = X509CertificateLoader.LoadPkcs12(File.ReadAllBytes(PfxPath), PfxPwd, X509KeyStorageFlags.Exportable);
else
{
    using var rsa = RSA.Create(2048);
    var req = new CertificateRequest("CN=DMC-AlwaysEncrypted-CMK", rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
    using var made = req.CreateSelfSigned(DateTimeOffset.Now.AddDays(-1), DateTimeOffset.Now.AddYears(5));
    File.WriteAllBytes(PfxPath, made.Export(X509ContentType.Pfx, PfxPwd));
    cert = X509CertificateLoader.LoadPkcs12(File.ReadAllBytes(PfxPath), PfxPwd, X509KeyStorageFlags.Exportable);
}

// 2) Özel anahtar deposu sağlayıcısı: CEK'i sertifikanın RSA anahtarıyla sarar/açar
var provider = new LocalCertProvider(cert);
SqlConnection.RegisterColumnEncryptionKeyStoreProviders(
    new Dictionary<string, SqlColumnEncryptionKeyStoreProvider>(StringComparer.OrdinalIgnoreCase)
    { { "DMC_LOCAL", provider } });

// 3) CEK üret (256-bit) ve CMK ile şifrele -> CREATE COLUMN ENCRYPTION KEY için ENCRYPTED_VALUE
byte[] cekPlain = RandomNumberGenerator.GetBytes(32);
byte[] cekEnc = provider.EncryptColumnEncryptionKey("local/dmc-cmk", "RSA_OAEP", cekPlain);
string cekHex = "0x" + Convert.ToHexString(cekEnc);

// 4) Provizyon (DDL), düz bağlantı
using (var ddl = new SqlConnection(cs))
{
    ddl.Open();
    Exec(ddl, "IF OBJECT_ID('dbo.Patients') IS NOT NULL DROP TABLE dbo.Patients;");
    Exec(ddl, "IF EXISTS(SELECT 1 FROM sys.column_encryption_keys WHERE name='CEK1') DROP COLUMN ENCRYPTION KEY CEK1;");
    Exec(ddl, "IF EXISTS(SELECT 1 FROM sys.column_master_keys WHERE name='CMK1') DROP COLUMN MASTER KEY CMK1;");
    Exec(ddl, "CREATE COLUMN MASTER KEY CMK1 WITH (KEY_STORE_PROVIDER_NAME='DMC_LOCAL', KEY_PATH='local/dmc-cmk');");
    Exec(ddl, $"CREATE COLUMN ENCRYPTION KEY CEK1 WITH VALUES (COLUMN_MASTER_KEY=CMK1, ALGORITHM='RSA_OAEP', ENCRYPTED_VALUE={cekHex});");
    Exec(ddl, @"CREATE TABLE dbo.Patients (
        Id   int IDENTITY PRIMARY KEY,
        Name nvarchar(60),
        Ssn  nvarchar(16) COLLATE Latin1_General_BIN2
             ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY=CEK1, ENCRYPTION_TYPE=DETERMINISTIC,
                             ALGORITHM='AEAD_AES_256_CBC_HMAC_SHA_256'));");
    Console.WriteLine("Provizyon tamam: CMK1, CEK1, dbo.Patients (Ssn sifreli).");
}

// 5) İstemci şifreli yazar (Column Encryption Setting=Enabled -> SqlClient parametreyi sifreler)
using (var app = new SqlConnection(cs))
{
    app.Open();
    foreach (var (name, ssn) in new[] { ("Ada Lovelace", "12345678901"), ("Linus T.", "98765432109") })
    {
        using var cmd = new SqlCommand("INSERT dbo.Patients (Name, Ssn) VALUES (@n, @s)", app);
        cmd.Parameters.Add(new SqlParameter("@n", System.Data.SqlDbType.NVarChar, 60) { Value = name });
        cmd.Parameters.Add(new SqlParameter("@s", System.Data.SqlDbType.NVarChar, 16) { Value = ssn });
        cmd.ExecuteNonQuery();
    }
    // 6) İstemci deşifre okur (yetkili + anahtar var -> düz metin)
    Console.WriteLine("\nİstemci görünümü (AE etkin, deşifre edilmiş):");
    using var q = new SqlCommand("SELECT Id, Name, Ssn FROM dbo.Patients ORDER BY Id", app);
    using var r = q.ExecuteReader();
    while (r.Read()) Console.WriteLine($"  {r.GetInt32(0)}  {r.GetString(1),-14}  {r.GetString(2)}");
}
Console.WriteLine("\nBitti. (Düz SELECT ise yalnızca ciphertext görür, betikle gösterilecek.)");

static void Exec(SqlConnection c, string sql) { using var cmd = new SqlCommand(sql, c); cmd.ExecuteNonQuery(); }

// Özel Column Master Key deposu: CEK'i sertifikanın RSA anahtarıyla OAEP-SHA256 ile sarar/açar
sealed class LocalCertProvider : SqlColumnEncryptionKeyStoreProvider
{
    private readonly RSA _rsa;
    public LocalCertProvider(X509Certificate2 cert) => _rsa = cert.GetRSAPrivateKey()!;
    public override byte[] EncryptColumnEncryptionKey(string masterKeyPath, string algorithm, byte[] cek)
        => _rsa.Encrypt(cek, RSAEncryptionPadding.OaepSHA256);
    public override byte[] DecryptColumnEncryptionKey(string masterKeyPath, string algorithm, byte[] encryptedCek)
        => _rsa.Decrypt(encryptedCek, RSAEncryptionPadding.OaepSHA256);
    public override byte[] SignColumnMasterKeyMetadata(string masterKeyPath, bool allowEnclaveComputations)
        => Array.Empty<byte>();
    public override bool VerifyColumnMasterKeyMetadata(string masterKeyPath, bool allowEnclaveComputations, byte[] signature)
        => true;
}
