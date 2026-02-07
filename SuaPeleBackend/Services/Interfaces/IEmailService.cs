using System.Collections.Generic;
using System.Threading.Tasks;

namespace SuaPeleBackend.Services.Interfaces
{
    public interface IEmailService
    {
        // O 5º parâmetro deve ser obrigatoriamente uma List<string> para aceitar múltiplas fotos
        Task EnviarRelatorioAsync(
            string emailDestino, 
            string nomePaciente,
            string sexoPaciente,
            string detalhesLesao, 
            string resultadoIA, 
            List<string>? imagensBase64 = null);
    }
}