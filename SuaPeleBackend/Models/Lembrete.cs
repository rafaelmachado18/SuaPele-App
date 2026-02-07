using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SuaPeleBackend.Models
{
    public enum TipoLembrete
    {
        Medicamento,
        FotoAcompanhamento,
        ConsultaMedica
    }

    public class Lembrete
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "O tipo do lembrete é obrigatório.")]
        public TipoLembrete Tipo { get; set; } = TipoLembrete.Medicamento;

        [Required(ErrorMessage = "O horário do lembrete é obrigatório.")]
        public TimeSpan Horario { get; set; }

        [Required(ErrorMessage = "Os dias da semana são obrigatórios.")]
        public string DiasSemana { get; set; } = string.Empty;

        public bool Ativo { get; set; } = true;

        // Vìnculos Externos
        [Required]
        public int PacienteId { get; set; }
        
        [ForeignKey("PacienteId")]
        public Paciente? Paciente { get; set; }

        // --- VÍNCULOS OPCIONAIS ---
        [Required]
        public int TratamentoId {get; set;}
        [ForeignKey("TratamentoId")]
        public Tratamento? Tratamento { get; set; }

        public int? LesaoId { get; set; }

        [ForeignKey("LesaoId")]
        public Lesao? Lesao { get; set; }
    }
}