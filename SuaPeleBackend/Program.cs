using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Data;
using SuaPeleBackend.Repositories;
using SuaPeleBackend.Repositories.Interfaces;
using SuaPeleBackend.Services;
using SuaPeleBackend.Services.Interfaces;
using System.Text.Json;
using System.Text.Json.Serialization;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);



var builder = WebApplication.CreateBuilder(args);




builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.WriteIndented = true;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Registro dos services,  que se comunicarao com o Gemini e o E-mail
builder.Services.AddHttpClient<IGeminiService, GeminiService>();
builder.Services.AddScoped<IEmailService, EmailService>();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Configuração do Banco SQLite
/*builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=suapele.db"));*/

// Dependencia dos repositorios com suas interfaces
builder.Services.AddScoped<IPacienteRepository, PacienteRepository>();
builder.Services.AddScoped<ILesaoRepository, LesaoRepository>();
builder.Services.AddScoped<ITratamentoRepository, TratamentoRepository>();
builder.Services.AddScoped<ILembreteRepository, LembreteRepository>();
builder.Services.AddScoped<IProfissionalDeSaudeRepository, ProfissionalDeSaudeRepository>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AppDbContext>(); // Criea um BD e as tabelas se nao existirem, e aplica as migrations, se existirem sao atualizados
        
        context.Database.Migrate(); 
        Console.WriteLine("Êxito na criacao de tabelas");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Erro ao criar tabelas: {ex.Message}");
    }
}

// Swagger para ajudar debugging no backend
app.UseSwagger();
app.UseSwaggerUI(c => 
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Sua Pele Core MVP");
    c.RoutePrefix = string.Empty; 
});

app.UseAuthorization();
app.MapControllers();

app.Run();