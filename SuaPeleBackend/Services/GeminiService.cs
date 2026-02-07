using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Configuration;
using SuaPeleBackend.Models;
using SuaPeleBackend.Services.Interfaces;

namespace SuaPeleBackend.Services
{
    public class GeminiService : IGeminiService
    {
        private readonly string _apiKey;
        private readonly HttpClient _httpClient;

        public GeminiService(HttpClient httpClient, IConfiguration config)
        {
            _httpClient = httpClient;
            _apiKey = config["Gemini:ApiKey"] ?? string.Empty;
        }

        public async Task<PreDiagnostico> AnalisarLesaoAsync(List<string> base64Imagens, int lesaoId)
        {
            var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key={_apiKey}";

            var parts = new List<object>();
            
            parts.Add(new { text = @"
                Aja como um médico dermatologista experiente e empático. 
                Analise estas imagens de uma lesão cutânea e forneça um parecer técnico consolidado.
                
                Instruções de Resposta:
                1. Resultado: Nome da condição sugerida.
                2. Recomendacao: Explicação clara para o paciente, sem causar pânico, enfatizando a necessidade de consulta presencial.
                3. SugestaoMedico: Seção técnica para o colega médico. Sugira exames (ex: dermatoscopia, biópsia, lâmpada de Wood) ou cite literatura relevante/padrões diagnósticos (ex: Regra ABCDE, Padrões de Fitzpatrick).

                Retorne estritamente um JSON no seguinte formato:
                {
                  ""resultado"": ""string"",
                  ""recomendacao"": ""string"",
                  ""sugestaoMedico"": ""string""
                }" 
            });

            foreach (var img in base64Imagens)
            {
                var cleanBase64 = img.Contains(",") ? img.Split(',')[1] : img;
                parts.Add(new { inline_data = new { mime_type = "image/jpeg", data = cleanBase64.Trim() } });
            }

            var payload = new
            {
                contents = new[] { new { parts = parts.ToArray() } },
                generationConfig = new 
                { 
                    response_mime_type = "application/json",
                    temperature = 0.2
                }
            };

            // Serializa o objeto prompt + imagem para JSON e configura o cabeçalho para 'application/json'
            var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json"); 

            var response = await _httpClient.PostAsync(url, content);// Realiza a chamada POST
            
            if (response.IsSuccessStatusCode)
            {
                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                var textResponse = doc.RootElement
                    .GetProperty("candidates")[0]
                    .GetProperty("content")
                    .GetProperty("parts")[0]
                    .GetProperty("text")
                    .GetString();
                
                var analise = JsonSerializer.Deserialize<GeminiResponse>(textResponse!, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                return new PreDiagnostico
                {
                    LesaoId = lesaoId,
                    DataAnalise = DateTime.Now,
                    ResultadoIA = analise?.Resultado ?? "Inconclusivo",
                   
                    Probabilidade = 0, //por enqunato vou zerar, depois vou retirar
                  
                    Recomendacao = $"{analise?.Recomendacao} | SUGESTÃO MÉDICA: {analise?.SugestaoMedico}"
                };
            }

            throw new Exception($"Erro na comunicação com Gemini. Status: {response.StatusCode}");
        }

        private class GeminiResponse 
        { 
            public string? Resultado { get; set; } 
            public string? Recomendacao { get; set; } 
            public string? SugestaoMedico { get; set; }
        }
    }
}