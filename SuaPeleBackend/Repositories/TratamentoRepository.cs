using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Data;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Repositories
{
    public class TratamentoRepository : ITratamentoRepository
    {
        private readonly AppDbContext _context;

        public TratamentoRepository(AppDbContext context) => _context = context;

        public async Task<Tratamento> CriarAsync(Tratamento t) 
        { 
            _context.Tratamentos.Add(t); 
            await _context.SaveChangesAsync(); 
            return t; 
        }

        public async Task<List<Tratamento>> ListarPorPacienteAsync(int pacienteId) => 
            await _context.Tratamentos
                .Where(x => x.PacienteId == pacienteId)
                .Include(x => x.Medicamentos)
                .ToListAsync();

        public async Task DeletarAsync(int id)
{
    // Buscamos o tratamento com os Medicamentos incluidos
    var tratamento = await _context.Tratamentos
        .Include(t => t.Medicamentos)
        .FirstOrDefaultAsync(t => t.Id == id);

    if (tratamento != null)
    {
        
        var lembretesParaRemover = await _context.Lembretes
            .Where(l => l.TratamentoId == id)
            .ToListAsync();

        if (lembretesParaRemover.Any())
        {
            _context.Lembretes.RemoveRange(lembretesParaRemover);
        }

        //Para a delecao em cascata funcionar
        if (tratamento.Medicamentos != null && tratamento.Medicamentos.Any())
        {
            _context.Medicamentos.RemoveRange(tratamento.Medicamentos);
        }

        //Tratamento apagado
        _context.Tratamentos.Remove(tratamento);

        // 5. UMA ÚNICA TRANSAÇÃO: Ou apaga tudo, ou não apaga nada.
        await _context.SaveChangesAsync();
    }
}
    }
}