require './meu_carro_novo_service'

scrap = MeuCarroNovoService.new
veiculos = scrap.obter_todos_veiculos

file = File.open('veiculos.json', 'w')
file << veiculos.to_json
file.close_write
