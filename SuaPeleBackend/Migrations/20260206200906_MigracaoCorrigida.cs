using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace suapelebackend.Migrations
{
    /// <inheritdoc />
    public partial class MigracaoCorrigida : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Pacientes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nome = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    SenhaHash = table.Column<string>(type: "text", nullable: false),
                    DataNascimento = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    Sexo = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Pacientes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ProfissionaisDeSaude",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nome = table.Column<string>(type: "text", nullable: false),
                    CRM = table.Column<string>(type: "text", nullable: false),
                    Dermatologista = table.Column<bool>(type: "boolean", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    Telefone = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProfissionaisDeSaude", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Lesoes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DataRegistro = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    RegiaoCorpo = table.Column<string>(type: "text", nullable: false),
                    DescricaoTextual = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    PacienteId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Lesoes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Lesoes_Pacientes_PacienteId",
                        column: x => x.PacienteId,
                        principalTable: "Pacientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PacienteMedicos",
                columns: table => new
                {
                    PacientesId = table.Column<int>(type: "integer", nullable: false),
                    ProfissionaisDeSaudeId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PacienteMedicos", x => new { x.PacientesId, x.ProfissionaisDeSaudeId });
                    table.ForeignKey(
                        name: "FK_PacienteMedicos_Pacientes_PacientesId",
                        column: x => x.PacientesId,
                        principalTable: "Pacientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PacienteMedicos_ProfissionaisDeSaude_ProfissionaisDeSaudeId",
                        column: x => x.ProfissionaisDeSaudeId,
                        principalTable: "ProfissionaisDeSaude",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Fotos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CaminhoArquivo = table.Column<string>(type: "text", nullable: false),
                    DataCaptura = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    LesaoId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Fotos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Fotos_Lesoes_LesaoId",
                        column: x => x.LesaoId,
                        principalTable: "Lesoes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PreDiagnosticos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DataAnalise = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    ResultadoIA = table.Column<string>(type: "text", nullable: false),
                    Probabilidade = table.Column<float>(type: "real", nullable: false),
                    Recomendacao = table.Column<string>(type: "text", nullable: false),
                    LesaoId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PreDiagnosticos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PreDiagnosticos_Lesoes_LesaoId",
                        column: x => x.LesaoId,
                        principalTable: "Lesoes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Tratamentos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Titulo = table.Column<string>(type: "text", nullable: false),
                    ObservacoesGerais = table.Column<string>(type: "text", nullable: false),
                    DataInicio = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    DataFim = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    PacienteId = table.Column<int>(type: "integer", nullable: false),
                    LesaoId = table.Column<int>(type: "integer", nullable: true),
                    ProfissionalDeSaudeId = table.Column<int>(type: "integer", nullable: true),
                    PreDiagnosticoId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tratamentos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Tratamentos_Lesoes_LesaoId",
                        column: x => x.LesaoId,
                        principalTable: "Lesoes",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Tratamentos_Pacientes_PacienteId",
                        column: x => x.PacienteId,
                        principalTable: "Pacientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Tratamentos_PreDiagnosticos_PreDiagnosticoId",
                        column: x => x.PreDiagnosticoId,
                        principalTable: "PreDiagnosticos",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Tratamentos_ProfissionaisDeSaude_ProfissionalDeSaudeId",
                        column: x => x.ProfissionalDeSaudeId,
                        principalTable: "ProfissionaisDeSaude",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Lembretes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Tipo = table.Column<string>(type: "text", nullable: false),
                    Horario = table.Column<TimeSpan>(type: "interval", nullable: false),
                    DiasSemana = table.Column<string>(type: "text", nullable: false),
                    Ativo = table.Column<bool>(type: "boolean", nullable: false),
                    PacienteId = table.Column<int>(type: "integer", nullable: false),
                    TratamentoId = table.Column<int>(type: "integer", nullable: false),
                    LesaoId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Lembretes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Lembretes_Lesoes_LesaoId",
                        column: x => x.LesaoId,
                        principalTable: "Lesoes",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Lembretes_Pacientes_PacienteId",
                        column: x => x.PacienteId,
                        principalTable: "Pacientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Lembretes_Tratamentos_TratamentoId",
                        column: x => x.TratamentoId,
                        principalTable: "Tratamentos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Medicamentos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nome = table.Column<string>(type: "text", nullable: false),
                    Dosagem = table.Column<string>(type: "text", nullable: false),
                    Frequencia = table.Column<string>(type: "text", nullable: false),
                    InstrucoesEspecificas = table.Column<string>(type: "text", nullable: false),
                    TratamentoId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Medicamentos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Medicamentos_Tratamentos_TratamentoId",
                        column: x => x.TratamentoId,
                        principalTable: "Tratamentos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Fotos_LesaoId",
                table: "Fotos",
                column: "LesaoId");

            migrationBuilder.CreateIndex(
                name: "IX_Lembretes_LesaoId",
                table: "Lembretes",
                column: "LesaoId");

            migrationBuilder.CreateIndex(
                name: "IX_Lembretes_PacienteId",
                table: "Lembretes",
                column: "PacienteId");

            migrationBuilder.CreateIndex(
                name: "IX_Lembretes_TratamentoId",
                table: "Lembretes",
                column: "TratamentoId");

            migrationBuilder.CreateIndex(
                name: "IX_Lesoes_PacienteId",
                table: "Lesoes",
                column: "PacienteId");

            migrationBuilder.CreateIndex(
                name: "IX_Medicamentos_TratamentoId",
                table: "Medicamentos",
                column: "TratamentoId");

            migrationBuilder.CreateIndex(
                name: "IX_PacienteMedicos_ProfissionaisDeSaudeId",
                table: "PacienteMedicos",
                column: "ProfissionaisDeSaudeId");

            migrationBuilder.CreateIndex(
                name: "IX_Pacientes_Email",
                table: "Pacientes",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PreDiagnosticos_LesaoId",
                table: "PreDiagnosticos",
                column: "LesaoId");

            migrationBuilder.CreateIndex(
                name: "IX_ProfissionaisDeSaude_CRM",
                table: "ProfissionaisDeSaude",
                column: "CRM",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Tratamentos_LesaoId",
                table: "Tratamentos",
                column: "LesaoId");

            migrationBuilder.CreateIndex(
                name: "IX_Tratamentos_PacienteId",
                table: "Tratamentos",
                column: "PacienteId");

            migrationBuilder.CreateIndex(
                name: "IX_Tratamentos_PreDiagnosticoId",
                table: "Tratamentos",
                column: "PreDiagnosticoId");

            migrationBuilder.CreateIndex(
                name: "IX_Tratamentos_ProfissionalDeSaudeId",
                table: "Tratamentos",
                column: "ProfissionalDeSaudeId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Fotos");

            migrationBuilder.DropTable(
                name: "Lembretes");

            migrationBuilder.DropTable(
                name: "Medicamentos");

            migrationBuilder.DropTable(
                name: "PacienteMedicos");

            migrationBuilder.DropTable(
                name: "Tratamentos");

            migrationBuilder.DropTable(
                name: "PreDiagnosticos");

            migrationBuilder.DropTable(
                name: "ProfissionaisDeSaude");

            migrationBuilder.DropTable(
                name: "Lesoes");

            migrationBuilder.DropTable(
                name: "Pacientes");
        }
    }
}
