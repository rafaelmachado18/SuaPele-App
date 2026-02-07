using Microsoft.AspNetCore.Mvc;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Controllers
{

    [Route("core/[controller]")]
    [ApiController]
    public class TratamentoController : ControllerBase
    {
        private readonly ITratamentoRepository _repository;
        private readonly IPacienteRepository _pacienteRepository;

        public TratamentoController(ITratamentoRepository repository, IPacienteRepository pacienteRepository)
        {
            _repository = repository;
            _pacienteRepository = pacienteRepository;
        }

        [HttpPost("cadastrar")]
        public async Task<ActionResult<Tratamento>> Cadastrar([FromBody] Tratamento tratamento)
        {
            try
            {
                // O paciente deve existir no sistema
                var paciente = await _pacienteRepository.BuscarPorIdAsync(tratamento.PacienteId);
                if (paciente == null) 
                    return BadRequest(new { mensagem = "Erro: Paciente não encontrado para este tratamento." });

                // 
                if (tratamento.DataInicio == DateTime.MinValue) 
                    tratamento.DataInicio = DateTime.Now;

                //O repositório salva o plano e os medicamentos em cascata
                var novoTratamento = await _repository.CriarAsync(tratamento);

                return Ok(new { 
                    mensagem = "Plano de tratamento guardado com sucesso!", 
                    id = novoTratamento.Id,
                    paciente = paciente.Nome 
                });
            }
            catch (Exception ex)
            {
                
                return StatusCode(500, new { erro = "Falha ao processar o tratamento: " + ex.Message });
            }
        }

      
        [HttpGet("paciente/{pacienteId}")]
        public async Task<ActionResult<IEnumerable<Tratamento>>> ListarPorPaciente(int pacienteId)
        {
            try
            {
                var tratamentos = await _repository.ListarPorPacienteAsync(pacienteId);
                return Ok(tratamentos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Erro ao listar tratamentos: " + ex.Message });
            }
        }

      
        [HttpDelete("{id}")]
        public async Task<ActionResult> Deletar(int id)
        {
            try
            {
                
                await _repository.DeletarAsync(id);
                
                return Ok(new { mensagem = "O plano de tratamento foi removido do sistema com sucesso." });
            }
            catch (Exception ex)
            {
                
                return StatusCode(500, new { erro = "Não foi possível apagar o tratamento: " + ex.Message });
            }
        }
    }
}