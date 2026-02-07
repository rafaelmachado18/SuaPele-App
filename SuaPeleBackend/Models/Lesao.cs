using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SuaPeleBackend.Models
{
    public class Lesao
    {
        [Key]
        public int Id {get; set;}

        [Required(ErrorMessage = "Esse campo é obrigatório.")]
        public required DateTime DataRegistro {get; set;} = DateTime.Now;

        public string RegiaoCorpo {get; set;} = string.Empty;
        public string DescricaoTextual {get; set;} = string.Empty;

        [Required]
        public required string Status {get; set;}

        // Paciente
        [Required]
        public int PacienteId {get; set;}

        [ForeignKey("PacienteId")]
        public Paciente? Paciente {get;set;}
        // Fotos
        public List<Foto> Fotos { get; set; } = new List<Foto>();

        //PreDiagnostico
        public List<PreDiagnostico> PreDiagnosticos { get; set; } = new List<PreDiagnostico>();
    
    }
}
