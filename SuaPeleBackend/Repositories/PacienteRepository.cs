using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Data;
using SuaPeleBackend.Models;

namespace SuaPeleBackend.Repositories
{
    public class PacienteRepository : Interfaces.IPacienteRepository
    {
        private readonly AppDbContext _context;
        public PacienteRepository(AppDbContext context) => _context = context;

        public async Task<Paciente> CriarAsync(Paciente p) { _context.Pacientes.Add(p); await _context.SaveChangesAsync(); return p; }
        public async Task<Paciente?> BuscarPorIdAsync(int id) => await _context.Pacientes.FindAsync(id);
        public async Task<Paciente?> BuscarPorEmailAsync(string email) => await _context.Pacientes.FirstOrDefaultAsync(x => x.Email == email);
        public async Task<List<Paciente>> ListarTodosAsync() => await _context.Pacientes.ToListAsync();
        public async Task AtualizarAsync(Paciente p) { _context.Entry(p).State = EntityState.Modified; await _context.SaveChangesAsync(); }
        public async Task DeletarAsync(int id) { var p = await BuscarPorIdAsync(id); if (p != null) { _context.Pacientes.Remove(p); await _context.SaveChangesAsync(); } }

        // Vinculo para deixar possivel a relacao NXN entre medicos e pacientes
        public async Task<bool> VincularMedicoPorCrmAsync(int pacienteId, string crm)
        {
            // Busca o paciente trazendo a lista de medicos dele
            var paciente = await _context.Pacientes.Include(p => p.ProfissionaisDeSaude).FirstOrDefaultAsync(p => p.Id == pacienteId);
            // Busca o medico no banco geral pelo CRM
            var medico = await _context.ProfissionaisDeSaude.FirstOrDefaultAsync(m => m.CRM == crm);

            if (paciente == null || medico == null) return false;
            
            // Se já estiver na lista, não faz nada e retorna true
            if (paciente.ProfissionaisDeSaude.Any(m => m.Id == medico.Id)) return true;

            // Adiciona na lista e o EF Core cria a linha na tabela de união automaticamente
            paciente.ProfissionaisDeSaude.Add(medico);
            return await _context.SaveChangesAsync() > 0;
        }
    }
}