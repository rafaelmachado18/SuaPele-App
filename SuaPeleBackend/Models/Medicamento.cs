using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SuaPeleBackend.Models
{
    public class Medicamento
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "O nome do medicamento é obrigatório.")]
        public required string Nome { get; set; }

        [Required]
        public required string Dosagem { get; set; }

        [Required]
        public required string Frequencia { get; set; }

        [Required]
        public required string InstrucoesEspecificas { get; set; }

        // Tratamento
        
        [Required]
        public int TratamentoId { get; set; } 

        [ForeignKey("TratamentoId")]
        public Tratamento? Tratamento { get; set; }
    }
}