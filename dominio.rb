#!/usr/bin/ruby

$VERBOSE = nil
require 'socket'
require 'colorize'


puts "Digite o domínio:"
dominio = gets.chomp

puts"\n\nDADOS DO DOMÍNIO:\n\n".bold
whois = %x(whois #{dominio})

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

  if whois['status:      published']
    puts "\nSTATUS: Domínio publicado".green.bold
  else
    puts "\n!!!ATENÇÃO!!!".red.bold
    puts "O status do domíno é:"
    puts whois.lines.grep /status:/
  end
  puts("\nDNSs:")
  puts whois.lines.grep /nserver/

else
  saida = whois.lines.grep /Registrant Name|Registrant Email|Admin Name|Admin Email|Tech Name|Tech Email|Expiry Date|Expiration|Reseller/
  puts saida.to_s.encode('utf-8')
  puts("\nDNSs:")
  puts whois.lines.grep /Name Server/
end

puts "\nSERVIDORES DE EMAIL"
puts %x(host -t MX #{dominio})
