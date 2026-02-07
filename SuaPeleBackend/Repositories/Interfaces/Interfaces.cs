using SuaPeleBackend.Models;

namespace SuaPeleBackend.Repositories.Interfaces // Cada INterface forca ao repositorio ter certas funcoes implemetnadas, a maioria delas e a memsa, crriar, buscar por is, listar e deletar. Essas funcoes vao agir diretamente no Banco de Dados
{
    public interface IPacienteRepository
    {
        Task<Paciente> CriarAsync(Paciente p);
        Task<Paciente?> BuscarPorIdAsync(int id);
        Task<Paciente?> BuscarPorEmailAsync(string email);
        Task<List<Paciente>> ListarTodosAsync();
        Task AtualizarAsync(Paciente p);
        Task DeletarAsync(int id);
        
        // Feito para funcionar o vinculo de muitos para muitos, isso é encessario apra o futuro quando medicos forem usuarios do sistema
        Task<bool> VincularMedicoPorCrmAsync(int pacienteId, string crm);
    }

    public interface ILesaoRepository
    {
        Task<Lesao> CriarAsync(Lesao l); 
        Task<List<Lesao>> ListarPorPacienteAsync(int pacienteId);
        Task<Lesao?> BuscarPorIdAsync(int id);
        
        Task AtualizarAsync(Lesao l); 
        Task DeletarAsync(int id); 
    }

    public interface ITratamentoRepository
    {
        Task<Tratamento> CriarAsync(Tratamento t);
        Task<List<Tratamento>> ListarPorPacienteAsync(int pacienteId);
        Task DeletarAsync(int id); 
    }

    public interface IProfissionalDeSaudeRepository
    {
        Task<ProfissionalDeSaude> AdicionarAsync(ProfissionalDeSaude m, int pacienteId);
        Task<List<ProfissionalDeSaude>> ListarAgendaPacienteAsync(int pacienteId);
        Task DeletarAsync(int id);
    }

    public interface ILembreteRepository
    {
        Task<Lembrete> CriarAsync(Lembrete l);
        Task<List<Lembrete>> ListarAtivosPorPacienteAsync(int pacienteId);
        Task AlternarStatusAsync(int id);
        Task DeletarAsync(int id); 
    }
}