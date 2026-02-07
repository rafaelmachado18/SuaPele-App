using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Data;
using SuaPeleBackend.Models;

namespace SuaPeleBackend.Repositories
{
    public class ProfissionalDeSaudeRepository : Interfaces.IProfissionalDeSaudeRepository
    {
        private readonly AppDbContext _context;
        public ProfissionalDeSaudeRepository(AppDbContext context) => _context = context;
        public async Task<ProfissionalDeSaude> AdicionarAsync(ProfissionalDeSaude m, int pacienteId)
{
    // Para verificar se o medico etem o mesmo crm
    var medicoExistente = await _context.ProfissionaisDeSaude
        .FirstOrDefaultAsync(x => x.CRM == m.CRM);

    // 2. Busca o paciente
    var paciente = await _context.Pacientes
        .Include(x => x.ProfissionaisDeSaude)
        .FirstOrDefaultAsync(x => x.Id == pacienteId);

    if (paciente == null) throw new Exception("Paciente não encontrado.");

    if (medicoExistente != null)
    {
        // Caso o CRM já exista mas o nome seja diferente (Erro de digitação ou fraude)
        if (medicoExistente.Nome.ToLower() != m.Nome.ToLower())
        {
            throw new Exception($"O CRM {m.CRM} já está registrado para o(a) Dr(a). {medicoExistente.Nome}.");
        }

        // Se o médico já existe e o nome bate, verifica se já está na agenda do paciente
        if (paciente.ProfissionaisDeSaude.Any(x => x.Id == medicoExistente.Id))
        {
            throw new Exception("Este médico já está na sua agenda.");
        }

        // Se não estava na agenda, apenas vincula o médico que já existe no sistema
        paciente.ProfissionaisDeSaude.Add(medicoExistente);
    }
    else
    {
        // Se o  medico tem crm inedito, e adicionado
        paciente.ProfissionaisDeSaude.Add(m);
    }

    await _context.SaveChangesAsync();
    return medicoExistente ?? m;
}
        public async Task<List<ProfissionalDeSaude>> ListarAgendaPacienteAsync(int pacienteId) => await _context.Pacientes.Where(p => p.Id == pacienteId).SelectMany(p => p.ProfissionaisDeSaude).ToListAsync();
        public async Task DeletarAsync(int id) => await _context.ProfissionaisDeSaude.Where(m => m.Id == id).ExecuteDeleteAsync();
    }
}