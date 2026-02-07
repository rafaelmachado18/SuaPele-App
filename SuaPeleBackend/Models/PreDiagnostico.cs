using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SuaPeleBackend.Models
{
    public class PreDiagnostico
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public DateTime DataAnalise { get; set; } = DateTime.Now;

        [Required]
        public required string ResultadoIA { get; set; } = string.Empty;

        public float Probabilidade { get; set; }

        public string Recomendacao { get; set; } = string.Empty; 

        //Lesao
        [Required]
        public required int LesaoId { get; set; }

        [ForeignKey("LesaoId")]
        public Lesao? Lesao { get; set; }

        

    }
}