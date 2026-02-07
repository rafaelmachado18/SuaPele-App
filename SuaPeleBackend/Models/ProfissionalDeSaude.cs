using System.Text.Json.Serialization; // Necessário para o [JsonIgnore]
using System.ComponentModel.DataAnnotations;

namespace SuaPeleBackend.Models
{
    public class ProfissionalDeSaude
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "O nome é obrigatório.")]
        public required string Nome { get; set; }

        [Required]
        public required string CRM { get; set; } = string.Empty; 

        public bool Dermatologista { get; set; }

        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public string Telefone { get; set; } = string.Empty;

        // --- RELACIONAMENTO CORRETO (Muitos-para-Muitos) ---
        
      
      
        public ICollection<Paciente> Pacientes { get; set; } = new List<Paciente>();

        // Tratamentos que este médico prescreveu (Opcional, mas útil)
        
        public List<Tratamento> Tratamentos { get; set; } = new List<Tratamento>();
    }
}