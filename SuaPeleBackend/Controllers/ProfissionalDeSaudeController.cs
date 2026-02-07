using Microsoft.AspNetCore.Mvc;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Controllers
{
    [Route("core/[controller]")] 
    [ApiController]
    public class ProfissionalDeSaudeController : ControllerBase
    {
        private readonly IProfissionalDeSaudeRepository _repository;

        public ProfissionalDeSaudeController(IProfissionalDeSaudeRepository repository) => _repository = repository;

        
        [HttpPost("adicionar")]
        public async Task<ActionResult> Adicionar([FromBody] ProfissionalDeSaude m, [FromQuery] int pacienteId)
        {
            try {
                return Ok(await _repository.AdicionarAsync(m, pacienteId));
            }
            catch (Exception ex) {
                
                return BadRequest(new { erro = ex.Message });
            }
}

        [HttpGet("agenda/paciente/{pacienteId}")]
        public async Task<ActionResult> ListarAgenda(int pacienteId) => 
            Ok(await _repository.ListarAgendaPacienteAsync(pacienteId));

        [HttpDelete("{id}")]
        public async Task<ActionResult> Remover(int id)
        {
            await _repository.DeletarAsync(id);
            return Ok(new { mensagem = "Profissional removido." });
        }
    }
}