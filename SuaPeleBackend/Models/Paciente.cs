using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SuaPeleBackend.Models
{
    public class Paciente
    {
        [Key]
        public int Id {get; set; }

        [Required(ErrorMessage = "O nome é obrigatório.")]
        public required string Nome {get; set;}

        [Required]
        [EmailAddress(ErrorMessage = "E-mail invalido.")]
        public required string Email { get; set;}

        [Required]
        [MinLength(8, ErrorMessage = "A senha deve ter, no mínimo, 8 caracteres")]
        public required string SenhaHash { get; set;}

        [Required]
        public DateTime DataNascimento { get; set;}

        [Required(ErrorMessage = "O nome é obrigatório.")]
        public required string Sexo {get; set;}

        //Lesao
        public List<Lesao> Lesoes { get; set; } = new List<Lesao>();

        // Tratamento
        public List<Tratamento> Tratamentos { get; set; } = new List<Tratamento>();

        // Profissional de Saúde
        public List<ProfissionalDeSaude> ProfissionaisDeSaude { get; set; } = new List<ProfissionalDeSaude>();
    }

}