using Microsoft.AspNetCore.Mvc;
using SuaPeleBackend.Models;
using SuaPeleBackend.Repositories.Interfaces;
using SuaPeleBackend.Services.Interfaces; 

namespace SuaPeleBackend.Controllers
{
    [Route("core/[controller]")]
    [ApiController]
    public class LesaoController : ControllerBase
    {
        private readonly ILesaoRepository _repository;
        private readonly IPacienteRepository _pacienteRepository;
        private readonly IProfissionalDeSaudeRepository _profissionalRepository;
        private readonly IGeminiService _geminiService;
        private readonly IEmailService _emailService;

        public LesaoController(
            ILesaoRepository repository, 
            IPacienteRepository pacienteRepository,
            IProfissionalDeSaudeRepository profissionalRepository,
            IGeminiService geminiService,
            IEmailService emailService)
        {
            _repository = repository;
            _pacienteRepository = pacienteRepository;
            _profissionalRepository = profissionalRepository;
            _geminiService = geminiService;
            _emailService = emailService;
        }

        // 1. CADASTRAR (Cria o registo inicial da mancha)
        [HttpPost("cadastrar")]
        public async Task<ActionResult<Lesao>> Cadastrar([FromBody] Lesao lesao)
        {
            try
            {
                var paciente = await _pacienteRepository.BuscarPorIdAsync(lesao.PacienteId);
                if (paciente == null) return BadRequest(new { mensagem = "Paciente não encontrado." });

                lesao.DataRegistro = DateTime.Now;
                lesao.Status = "Cadastrada";
                
                var novaLesao = await _repository.CriarAsync(lesao);
                return Ok(novaLesao); 
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Erro ao registar: " + ex.Message });
            }
        }

        // 2. ANALISAR (Processa as fotos, chama o Gemini e envia e-mail)
        [HttpPost("{id}/analisar")]
        public async Task<ActionResult> Analisar(int id, [FromBody] AnaliseRequest request)
        {
            try
            {
                var lesao = await _repository.BuscarPorIdAsync(id);
                if (lesao == null) return NotFound(new { mensagem = "Lesão não encontrada." });

                // Guarda as fotos enviadas na galeria da lesão no banco
                foreach (var imgBase64 in request.ImagensBase64)
                {
                    lesao.Fotos.Add(new Foto { CaminhoArquivo = imgBase64, DataCaptura = DateTime.Now, LesaoId = id });
                }

                // LÓGICA "SÓ SALVAR": Se o Flutter pedir para não analisar agora
                if (request.SoloSalvar)
                {
                    lesao.Status = "Fotos guardadas (Sem análise)";
                    await _repository.AtualizarAsync(lesao);
                    return Ok(new { status = "Guardado", mensagem = "Imagens armazenadas com sucesso." });
                }

                // 2.1 Chama a IA para analisar
                var preDiagnostico = await _geminiService.AnalisarLesaoAsync(request.ImagensBase64, id);
                
                lesao.Status = "Analisada pela IA";
                lesao.PreDiagnosticos.Add(preDiagnostico);
                await _repository.AtualizarAsync(lesao);

                // 2.2 Envia o relatório inicial por e-mail (ID da agenda ou E-mail manual)
                string statusEmail = await ProcessarEnvioEmail(lesao, request.ProfissionalDeSaudeId, request.EmailMedico, preDiagnostico.ResultadoIA, request.ImagensBase64);

                return Ok(new { 
                    status = "Análise Concluída", 
                    resultado = preDiagnostico.ResultadoIA, 
                    recomendacao = preDiagnostico.Recomendacao, // Já inclui a Sugestão Médica se vier do GeminiService
                    relatorioStatus = statusEmail 
                });
            }
            catch (Exception ex) { return StatusCode(500, new { erro = "Erro na análise: " + ex.Message }); }
        }

        // 3. REENVIAR RELATÓRIO (Disparado manualmente pelo histórico)
        [HttpPost("{id}/enviar-relatorio")]
        public async Task<ActionResult> EnviarRelatorio(int id, [FromBody] EnvioRelatorioSimples request)
        {
            try
            {
                var lesao = await _repository.BuscarPorIdAsync(id);
                if (lesao == null) return NotFound();

                var ultimaAnalise = lesao.PreDiagnosticos.LastOrDefault();
                if (ultimaAnalise == null) return BadRequest(new { mensagem = "Realize a análise antes de enviar o relatório." });

                var fotos = lesao.Fotos.Select(f => f.CaminhoArquivo).ToList();

                string status = await ProcessarEnvioEmail(lesao, request.ProfissionalDeSaudeId, request.EmailMedico, ultimaAnalise.ResultadoIA, fotos);
                return Ok(new { mensagem = status });
            }
            catch (Exception ex) { return StatusCode(500, new { erro = "Erro no reenvio: " + ex.Message }); }
        }

        // 4. BUSCAR POR ID
        [HttpGet("{id}")]
        public async Task<ActionResult> BuscarPorId(int id)
        {
            var lesao = await _repository.BuscarPorIdAsync(id);
            return lesao == null ? NotFound() : Ok(lesao);
        }

        // 5. LISTAR POR PACIENTE
        [HttpGet("paciente/{pacienteId}")]
        public async Task<ActionResult> ListarPorPaciente(int pacienteId)
        {
            try
            {
                var lesoes = await _repository.ListarPorPacienteAsync(pacienteId);
                return Ok(lesoes);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Erro ao listar: " + ex.Message });
            }
        }

        // 6. APAGAR (Delete Físico do Banco)
        [HttpDelete("{id}")]
        public async Task<ActionResult> Deletar(int id)
        {
            try
            {
                var lesao = await _repository.BuscarPorIdAsync(id);
                if (lesao == null) return NotFound(new { mensagem = "Registo não encontrado." });

                await _repository.DeletarAsync(id);
                return Ok(new { mensagem = "Registo de mancha removido com sucesso." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { erro = "Erro ao eliminar: " + ex.Message });
            }
        }

        // MÉTODOS PRIVADOS: Lógica de decisão do destinatário
        private async Task<string> ProcessarEnvioEmail(Lesao lesao, int? medicoId, string? emailManual, string resultado, List<string> fotos)
        {
            string emailDestino = "";

            if (medicoId.HasValue)
            {
                var agenda = await _profissionalRepository.ListarAgendaPacienteAsync(lesao.PacienteId);
                var medico = agenda.FirstOrDefault(m => m.Id == medicoId.Value);
                if (medico != null && !string.IsNullOrEmpty(medico.Email)) emailDestino = medico.Email;
            }
            
            if (string.IsNullOrEmpty(emailDestino) && !string.IsNullOrEmpty(emailManual))
            {
                emailDestino = emailManual;
            }

            if (string.IsNullOrEmpty(emailDestino)) return "E-mail não configurado.";

            var paciente = await _pacienteRepository.BuscarPorIdAsync(lesao.PacienteId);
            await _emailService.EnviarRelatorioAsync(emailDestino, paciente?.Nome ?? "Paciente", paciente?.Sexo?? "Sexo", lesao.DescricaoTextual, resultado, fotos);
            
            lesao.Status = $"Relatório enviado para {emailDestino}";
            await _repository.AtualizarAsync(lesao);

            return $"Relatório enviado com sucesso para {emailDestino}";
        }
    }

    // DTOs (Objetos de Troca de Dados)
    public class AnaliseRequest 
    { 
        public List<string> ImagensBase64 { get; set; } = new List<string>(); 
        public int? ProfissionalDeSaudeId { get; set; } 
        public string? EmailMedico { get; set; }
        public bool SoloSalvar { get; set; } // Flag necessária para o botão "SÓ SALVAR" do Flutter
    }

    public class EnvioRelatorioSimples
    {
        public int? ProfissionalDeSaudeId { get; set; }
        public string? EmailMedico { get; set; }
    }
}