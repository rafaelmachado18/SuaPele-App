using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using SuaPeleBackend.Services.Interfaces;

namespace SuaPeleBackend.Services
{
    public class EmailService : IEmailService
    {
       
        public async Task EnviarRelatorioAsync(string emailDestino, string nomePaciente, string sexoPaciente, string detalhesLesao, string resultadoIA, List<string>? imagensBase64 = null)
        {
            
            var smtpClient = new SmtpClient("sandbox.smtp.mailtrap.io") // Esotu deixando esse aqui para os testes, mas o codigo comentado a baixo seria para enviar para e-mails reais
            {
                Port = 2525,
                Credentials = new NetworkCredential("77e1e41e84fe78", "a6ed5ed044468a"),
                EnableSsl = true,
            };

            /*var smtpClient = new SmtpClient("smtp.gmail.com") 
            {
                Port = 587,
                Credentials = new NetworkCredential("rafamcmeneses@gmail.com", "senhas-deapp (encontradas na sua cnta google apos autentificacao em duas etapas)"), 
                EnableSsl = true,
            };*/

            
            string[] partes = resultadoIA.Split('|');
            string previsaoIA = partes.Length > 0 ? partes[0].Trim() : "Não identificada";
            string recomendacaoPaciente = partes.Length > 1 ? partes[1].Trim() : "Consulte um dermatologista para avaliação.";
            string sugestaoMedica = partes.Length > 2 ? partes[2].Replace("SUGESTÃO MÉDICA:", "").Trim() : "Avaliação clínica e dermatoscopia sugeridas.";

            // Galeria de Fotos em HTML
            string galeriaHtml = "";
            if (imagensBase64 != null && imagensBase64.Count > 0)
            {
                galeriaHtml = "<h3 style='color: #333; margin-top: 25px;'>Galeria de Fotos da Lesão:</h3><div style='display: flex; flex-wrap: wrap; gap: 10px;'>";
                foreach (var img in imagensBase64)
                {
                    
                    if (string.IsNullOrWhiteSpace(img)) continue;

                    // Remove o prefixo Data URI que bases 64 podem ter
                    // O SmtpClient e tags HTML precisam apenas da string de dados pura.
                    var cleanBase64 = img.Contains(",") ? img.Split(',')[1] : img; 

                    // Adiciona cada imagem à galeria usando estilização Inline para email
                    galeriaHtml += $@"
                        <div style='margin-bottom: 15px;'>
                            <img src='data:image/jpeg;base64,{cleanBase64.Trim()}' 
                                style='width: 280px; border: 2px solid #E91E63; border-radius: 12px; display: block;' />
                        </div>";
                }
                galeriaHtml += "</div>";
            }

            // Montagem do corpo do e-mail
            var mensagem = new MailMessage
            {
                From = new MailAddress("no-reply@suapele.com", "Sua Pele App"),
                Subject = $"Relatório de Triagem Digital: {nomePaciente}",
                Body = $@"
                    <div style='font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; padding: 20px; border: 1px solid #eee;'>
                        <h2 style='color: #E91E63; border-bottom: 2px solid #E91E63; padding-bottom: 10px;'>
                            Relatório de Avaliação Digital
                        </h2>
                        
                        <p style='margin: 5px 0;'><b>Paciente:</b> {nomePaciente}</p>
                        <p style='margin: 5px 0;'><b>Data:</b> {DateTime.Now:dd/MM/yyyy HH:mm}</p>
                        <p style='margin: 5px 0;'><b>Sexo:</b> {sexoPaciente}</p>
                        
                        <hr style='border: 0; border-top: 1px solid #eee; margin: 20px 0;'/>

                        <div style='background-color: #f9f9f9; padding: 15px; border-radius: 8px; border-left: 5px solid #E91E63;'>
                            <h3 style='margin-top: 0; color: #E91E63;'>Parecer da Inteligência Artificial</h3>
                            <p><b>Previsão:</b> {previsaoIA}</p>
                            <p><b>Orientações ao Paciente:</b> {recomendacaoPaciente}</p>
                        </div>

                        <div style='margin-top: 20px; background-color: #e3f2fd; padding: 15px; border-radius: 8px; border-left: 5px solid #2196F3;'>
                            <h3 style='margin-top: 0; color: #0D47A1;'>Sugestão Técnica para o Médico</h3>
                            <p style='font-size: 14px; color: #0D47A1;'><i>Esta seção contém auxílio diagnóstico e sugestões de conduta clínica:</i></p>
                            <p><b>Sugestão:</b> {sugestaoMedica}</p>
                        </div>

                        <h3 style='margin-top: 25px;'>Relato de Sintomas (Paciente):</h3>
                        <p style='background-color: #fff; padding: 15px; border: 1px solid #eee; border-radius: 8px; font-style: italic;'>
                            ""{detalhesLesao}""
                        </p>

                        {galeriaHtml}

                        <p style='font-size: 11px; color: #777; margin-top: 40px; text-align: center; border-top: 1px solid #eee; padding-top: 10px;'>
                            <b>Aviso Legal:</b> Este relatório é uma triagem baseada em IA e não substitui o diagnóstico médico presencial.
                        </p>
                    </div>",
                IsBodyHtml = true
            };

            mensagem.To.Add(emailDestino);
            await smtpClient.SendMailAsync(mensagem);
        }
    }
}