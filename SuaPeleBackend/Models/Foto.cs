using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SuaPeleBackend.Models
{
    public class Foto
    {
        [Key]
        public int Id {get; set;}

        [Required(ErrorMessage = "ERROR: caminho do arquivo não foi encontrado.")]
        public required string CaminhoArquivo{get; set;}

        [Required]
        public DateTime DataCaptura{get; set;}

        //Lesao

        [Required]
        public int LesaoId {get; set;}

        [ForeignKey("LesaoId")]
        public Lesao? Lesao {get; set;}
    }
}