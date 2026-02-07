using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Data;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Repositories
{
    
    public class LembreteRepository : ILembreteRepository
    {
        private readonly AppDbContext _context;

        public LembreteRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<Lembrete> CriarAsync(Lembrete l) 
        { 
            
            _context.Lembretes.Add(l); 
            await _context.SaveChangesAsync(); 
            return l; 
        }
        
        public async Task<List<Lembrete>> ListarAtivosPorPacienteAsync(int pacienteId)
        {
            // Retorna lembretes ativos incluindo Tratamento  e lesao (opicional)
            
            return await _context.Lembretes
                .Include(x => x.Tratamento) 
                .Include(x => x.Lesao)
                .Where(x => x.PacienteId == pacienteId && x.Ativo)
                .ToListAsync();
        }

        public async Task AlternarStatusAsync(int id)
        {
            var l = await _context.Lembretes.FindAsync(id);
            if (l != null) 
            { 
                l.Ativo = !l.Ativo; 
                await _context.SaveChangesAsync(); 
            }
        }

        public async Task DeletarAsync(int id)
        {
            // Busca o lembrete para remoção fisica
            var lembrete = await _context.Lembretes.FindAsync(id);
            if (lembrete != null)
            {
                _context.Lembretes.Remove(lembrete);
                await _context.SaveChangesAsync();
            }
        }
    }
}