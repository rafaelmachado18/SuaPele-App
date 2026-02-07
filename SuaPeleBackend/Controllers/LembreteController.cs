using Microsoft.AspNetCore.Mvc;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Controllers
{
    [Route("core/[controller]")]
    [ApiController]
    public class LembreteController : ControllerBase
    {
        private readonly ILembreteRepository _repository;
        private readonly IPacienteRepository _pacienteRepository;

        public LembreteController(ILembreteRepository repository, IPacienteRepository pacienteRepository)
        {
            _repository = repository;
            _pacienteRepository = pacienteRepository;
        }

        [HttpPost("cadastrar")] // Aqui cadastramos o lembret
        public async Task<ActionResult> Cadastrar([FromBody] Lembrete lembrete)
        {
            try
            {
                var paciente = await _pacienteRepository.BuscarPorIdAsync(lembrete.PacienteId);
                if (paciente == null)
                {
                    return BadRequest(new { mensagem = "Erro: Paciente não encontrado." });
                }

                lembrete.Ativo = true;
                var novoLembrete = await _repository.CriarAsync(lembrete);
                
                return Ok(new { 
                    mensagem = "Lembrete guardado com sucesso!", 
                    id = novoLembrete.Id,
                    horario = novoLembrete.Horario.ToString(@"hh\:mm")
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Falha ao criar lembrete: " + ex.Message });
            }
        }

        [HttpGet("ativos/paciente/{pacienteId}")]
        public async Task<ActionResult> ListarAtivos(int pacienteId)
        {
            try
            {
                var lembretes = await _repository.ListarAtivosPorPacienteAsync(pacienteId);
                
                // Formatamos a saída sem o MedicamentoId, focando no Tratamento
                var resultado = lembretes.Select(l => new {
                    l.Id,
                    l.Tipo,
                    Horario = l.Horario.ToString(@"hh\:mm"),
                    l.DiasSemana,
                    l.Ativo,
                    // Agora pegamos o nome do plano de tratamento vinculado
                    TratamentoTitulo = l.Tratamento?.Titulo ?? "Plano de Cuidado",
                    LocalLesao = l.Lesao?.RegiaoCorpo ?? "Geral"
                });

                return Ok(resultado);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Erro ao listar lembretes: " + ex.Message });
            }
        }

        [HttpPatch("alternar-status/{id}")]
        public async Task<ActionResult> AlternarStatus(int id)
        {
            try
            {
                await _repository.AlternarStatusAsync(id);
                return Ok(new { mensagem = "Status alterado." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Deletar(int id)
        {
            try
            {
                await _repository.DeletarAsync(id);
                return Ok(new { mensagem = "Lembrete removido." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = ex.Message });
            }
        }
    }
}