using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// SQL Server 2025 baglantisi (ortam degiskeni SQL_CONN ile gecersiz kilinabilir)
string cs = Environment.GetEnvironmentVariable("SQL_CONN")
    ?? "Server=localhost;Database=DevBook;User Id=sa;Password=Your#Passw0rd;Encrypt=True;TrustServerCertificate=True";

// GET /search?q=0.3,0.3,...  (virgul ayrimli 384 float) -> en yakin 3 kayit
app.MapGet("/search", async (string q) =>
{
    string jsonVec = "[" + q + "]";                     // vektoru JSON dizisi metnine cevir

    await using var conn = new SqlConnection(cs);
    await conn.OpenAsync();

    const string sql =
        "SELECT TOP (3) id, chunk, " +
        "ROUND(VECTOR_DISTANCE('cosine', embedding, CAST(@q AS vector(384))), 4) AS dist " +
        "FROM dbo.Kb ORDER BY dist";

    await using var cmd = new SqlCommand(sql, conn);
    cmd.Parameters.Add(new SqlParameter("@q", jsonVec)); // JSON metni; motor vector(384)'e CAST eder
    // Microsoft.Data.SqlClient 6.1+ ile native: new SqlVector<float>(floats) + SqlDbType.Vector

    var results = new List<object>();
    await using var r = await cmd.ExecuteReaderAsync();
    while (await r.ReadAsync())
        results.Add(new { id = r.GetInt32(0), chunk = r.GetString(1), dist = r.GetDouble(2) });

    return Results.Json(results);
});

app.Run();
