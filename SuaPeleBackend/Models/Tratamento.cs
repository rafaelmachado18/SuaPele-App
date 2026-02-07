using System;
using System.Collections.Generic; // Necessário para List<>
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SuaPeleBackend.Models
{
    public class Tratamento
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "O título do tratamento é obrigatório.")]
        public required string Titulo { get; set; }

        public string ObservacoesGerais { get; set; } = string.Empty;

        [Required]
        public DateTime DataInicio { get; set; } = DateTime.Now;

        public DateTime? DataFim { get; set; }

        //Paciente
        [Required]
        public int PacienteId { get; set; }

        [ForeignKey("PacienteId")]
        public Paciente? Paciente { get; set; }

        //Lesao
        public int? LesaoId { get; set; }

        [ForeignKey("LesaoId")]
        public Lesao? Lesao { get; set; }

        //Medico
        public int? ProfissionalDeSaudeId { get; set; }

        [ForeignKey("ProfissionalDeSaudeId")]
        public ProfissionalDeSaude? MedicoResponsavel { get; set; }

        //Pré-Diagnóstico
        public int? PreDiagnosticoId { get; set; }

        [ForeignKey("PreDiagnosticoId")]
        public PreDiagnostico? PreDiagnosticoOrigem { get; set; }

        // Medicamento
        public List<Medicamento> Medicamentos { get; set; } = new List<Medicamento>();
    }
}