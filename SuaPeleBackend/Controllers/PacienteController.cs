using Microsoft.AspNetCore.Mvc;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;

namespace SuaPeleBackend.Controllers
{
    [Route("core/[controller]")]
    [ApiController]
    public class PacienteController : ControllerBase
    {
        private readonly IPacienteRepository _repository;

        public PacienteController(IPacienteRepository repository) => _repository = repository;

        // GET: core/Paciente/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Paciente>> BuscarPorId(int id)
        {
            var paciente = await _repository.BuscarPorIdAsync(id);
            if (paciente == null) return NotFound(new { mensagem = "Paciente não encontrado." });
            return Ok(paciente);
        }

        // POST: core/Paciente/registrar
        [HttpPost("cadastrar")]
        public async Task<ActionResult> Registrar([FromBody] Paciente paciente)
        {
            try 
            {
                // Validação Proativa: Verifica se o e-mail já existe
                var existente = await _repository.BuscarPorEmailAsync(paciente.Email);
                if (existente != null) 
                    return BadRequest(new { mensagem = "Este e-mail já está em uso." });

                var novo = await _repository.CriarAsync(paciente);
                
                // Agora o CreatedAtAction funciona pois o método BuscarPorId existe!
                return CreatedAtAction(nameof(BuscarPorId), new { id = novo.Id }, novo);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Erro ao registrar: " + ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult> Login([FromBody] LoginRequest login)
        {
            var p = await _repository.BuscarPorEmailAsync(login.Email);
            if (p == null || p.SenhaHash != login.Senha) 
                return Unauthorized(new { mensagem = "E-mail ou senha incorretos." });

            return Ok(new { id = p.Id, nome = p.Nome });
        }

        // POST: core/Paciente/vincular-medico
        [HttpPost("vincular-medico")]
        public async Task<ActionResult> VincularMedico([FromQuery] int pacienteId, [FromQuery] string crm)
        {
            try
            {
                // O controller só manda o comando. O repositório faz o trabalho pesado.
                var sucesso = await _repository.VincularMedicoPorCrmAsync(pacienteId, crm);
                
                if (!sucesso) 
                    return NotFound(new { mensagem = "Paciente ou Médico (CRM) não encontrado." });

                return Ok(new { mensagem = "Médico vinculado com sucesso!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = ex.Message });
            }
        }

        [HttpGet("todos")]
        public async Task<ActionResult> Listar() => Ok(await _repository.ListarTodosAsync());

        [HttpDelete("{id}")]
        public async Task<ActionResult> Deletar(int id)
        {
            await _repository.DeletarAsync(id);
            return Ok(new { mensagem = "Paciente removido com sucesso." });
        }
    }

    public class LoginRequest { public string Email { get; set; } = string.Empty; public string Senha { get; set; } = string.Empty; }
}