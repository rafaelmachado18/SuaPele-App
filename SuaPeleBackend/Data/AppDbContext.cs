using Microsoft.EntityFrameworkCore;
using SuaPeleBackend.Models;

namespace SuaPeleBackend.Data 
{
    public class AppDbContext : DbContext // Aqui é onde vamos criar nosso banco de daos usando o ENtity 
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        // Mapeamento das Tabelas
        public DbSet<Paciente> Pacientes { get; set; }
        public DbSet<Lesao> Lesoes { get; set; }
        public DbSet<Foto> Fotos { get; set; }
        public DbSet<PreDiagnostico> PreDiagnosticos { get; set; }
        public DbSet<Tratamento> Tratamentos { get; set; }
        public DbSet<Medicamento> Medicamentos { get; set; }
        public DbSet<Lembrete> Lembretes { get; set; }
        public DbSet<ProfissionalDeSaude> ProfissionaisDeSaude { get; set; } 

       
        protected override void OnModelCreating(ModelBuilder modelBuilder) // Modelacao das nossas tabelas, o EF deixa o trabalho bem simplificado
        {
            base.OnModelCreating(modelBuilder);

            
            
            modelBuilder.Entity<Paciente>()
                .HasMany(p => p.ProfissionaisDeSaude) // relacionamento NxN
                .WithMany(m => m.Pacientes)          
                .UsingEntity(j => j.ToTable("PacienteMedicos")); // Cria a tabela de união automaticamente com este nome

            
            modelBuilder.Entity<Lesao>()
                .HasMany(l => l.PreDiagnosticos)
                .WithOne(pd => pd.Lesao)
                .HasForeignKey(pd => pd.LesaoId)
                .OnDelete(DeleteBehavior.Cascade);
                
            
            modelBuilder.Entity<Lesao>()
                .HasMany(l => l.Fotos)
                .WithOne(f => f.Lesao)
                .HasForeignKey(f => f.LesaoId)
                .OnDelete(DeleteBehavior.Cascade);

            
            modelBuilder.Entity<Paciente>()
                .HasIndex(p => p.Email)
                .IsUnique();

            modelBuilder.Entity<ProfissionalDeSaude>()
                .HasIndex(m => m.CRM)
                .IsUnique();

            
            modelBuilder.Entity<Lembrete>()
                .Property(l => l.Tipo)
                .HasConversion<string>(); 
        }
    }
}