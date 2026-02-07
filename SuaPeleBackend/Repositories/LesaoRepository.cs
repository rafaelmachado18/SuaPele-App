using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Data;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Repositories
{
    public class LesaoRepository : ILesaoRepository
    {
        private readonly AppDbContext _context;
        public LesaoRepository(AppDbContext context) => _context = context;

        public async Task<Lesao> CriarAsync(Lesao l) { _context.Lesoes.Add(l); await _context.SaveChangesAsync(); return l; }
        
        public async Task<List<Lesao>> ListarPorPacienteAsync(int pacienteId) => 
            await _context.Lesoes
                .Where(x => x.PacienteId == pacienteId)
                .Include(x => x.Fotos)
                .Include(x => x.PreDiagnosticos)
                .OrderByDescending(x => x.DataRegistro)
                .ToListAsync();

        public async Task<Lesao?> BuscarPorIdAsync(int id) => 
            await _context.Lesoes
                .Include(x => x.Fotos)
                .Include(x => x.PreDiagnosticos)
                .FirstOrDefaultAsync(x => x.Id == id);

        public async Task AtualizarAsync(Lesao l) { _context.Entry(l).State = EntityState.Modified; await _context.SaveChangesAsync(); }

        
        public async Task DeletarAsync(int id)
        {
            // Delecao em cascata
            var lesao = await _context.Lesoes
                .Include(l => l.Fotos)
                .Include(l => l.PreDiagnosticos)
                .FirstOrDefaultAsync(l => l.Id == id);

            if (lesao != null)
            {
                
                var tratamentosVinculados = await _context.Tratamentos
                    .Where(t => t.LesaoId == id)
                    .ToListAsync();

                foreach (var t in tratamentosVinculados)
                {
                    t.LesaoId = null; // Remove o vínculo antes de apagar a lesão
                }

                _context.Lesoes.Remove(lesao);
                await _context.SaveChangesAsync();
            }
        }
    }
}