using SuaPeleBackend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SuaPeleBackend.Services.Interfaces
{
    public interface IGeminiService
    {
        Task<PreDiagnostico> AnalisarLesaoAsync(List<string> base64Imagens, int lesaoId);
    }
}