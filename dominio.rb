#!/usr/bin/ruby

$VERBOSE = nil
require 'socket'
require 'timeout'
require 'colorize'

def whois_br(dominio, host: 'whois.registro.br', port: 43, timeout_s: 8)
  Timeout.timeout(timeout_s) do
    resposta = +""
    TCPSocket.open(host, port) do |sock|
      sock.write("#{dominio}\r\n")
      while (linha = sock.gets)
        resposta << linha
      end
    end
    resposta
  end
rescue => e
  "Erro ao consultar WHOIS: #{e.message}"
end

puts "Digite o domínio:"
dominio = gets.chomp

puts"\n\nDADOS DO DOMÍNIO:\n\n".bold

whois =
  if dominio['.br']
    whois_br(dominio)
  else
    %x(whois #{dominio})
  end

begin
  ip = IPSocket::getaddress(dominio)
  host = %x(host #{ip})
rescue
  puts "Não foi possível obter o Ip, site fora do ar."
    ip= "???.???.???.???"
end

puts "Ip: #{ip} \n\n"
puts "Host: #{host} \n\n".green.bold

if dominio['.br']

  puts whois.lines.grep /owner-c|admin-c|tech-c|billing-c|person|e-mail/

  status_linhas = whois.lines.grep(/status:/)
  if status_linhas.any?
    if whois['status:      published']
      puts "\nSTATUS: Domínio publicado".green.bold
    else
      puts "\n!!!ATENÇÃO!!!".red.bold
      puts "O status do domíno é:"
      puts status_linhas
    end
  else
    puts "\nSTATUS: não retornado pelo WHOIS."
  end

  nservers = whois.lines.grep(/nserver/)
  if nservers.any?
    puts("\nDNSs:")
    puts nservers
  else
    puts "\nDNSs: não retornados pelo WHOIS."
  end

else
  saida = whois.lines.grep /Registrant Name|Registrant Email|Admin Name|Admin Email|Tech Name|Tech Email|Expiry Date|Expiration|Reseller/
  puts saida.to_s.encode('utf-8')
  puts("\nDNSs:")
  puts whois.lines.grep /Name Server/
end

puts "\nSERVIDORES DE EMAIL"
puts %x(host -t MX #{dominio})
