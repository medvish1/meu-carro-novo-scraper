require 'json'
require 'mechanize'

class MeuCarroNovoService

  def initialize
    @mec = Mechanize.new
    @mec_image = Mechanize.new
    @mec_image.pluggable_parser.default = Mechanize::Image
  end

  def _extrair_dados_pagina(json_pagina)
    veiculos = []
    json_pagina['documentos'].each do |veiculo|
      veiculos << _extrair_dados_veiculo(veiculo)
    end
    return veiculos
  end

  def _extrair_dados_veiculo(json_veiculo)
    veiculo = {}
    veiculo['id'] = json_veiculo['veiculoAnunciadoId']
    veiculo['url'] = json_veiculo['url']
    veiculo['modelo'] = json_veiculo['modeloNome']
    veiculo['marca'] = json_veiculo['marcaNome']
    veiculo['valor'] = json_veiculo['preco']
    veiculo['ano_fabricacao'] = json_veiculo['anoFabricacao']
    veiculo['ano_modelo'] = json_veiculo['anoModelo']
    if (imagem_capa = _baixar_imagem(json_veiculo))
      veiculo['local_path'] = imagem_capa
    end
    return veiculo
  end

  def _baixar_imagem(json_veiculo)
    foto = json_veiculo['fotoCapa']

    if foto && (match = /(\w+\.\w+$)/.match(foto))
      uri = "https://static2.meucarronovo.com.br/imagens-dinamicas/lista/fotos/#{foto}"
      nome = "imagens/#{json_veiculo['veiculoAnunciadoId']}-#{match.captures[0]}"
      @mec_image.pluggable_parser.default = Mechanize::Image
      return @mec_image.get(uri).save(nome)
    end

    return nil
  end

  def _obter_pagina(pagina, limite, tipo, cidade)
    @mec.get 'https://www.meucarronovo.com.br/api/v2/busca',
             { 'limite' => limite, 'pagina' => pagina, 'tipoVeiculo' => tipo, 'cidade' => cidade }
    response_json = JSON.parse(@mec.page.content)
    ultima_pagina = response_json['ultimaPagina']
    return ultima_pagina, response_json
  end

  def obter_todos_veiculos
    veiculos = []
    pagina = 1
    loop do
      ultima_pagina, response_json = _obter_pagina(pagina, 50, 'A', 'Francisco Beltrão')
      veiculos += _extrair_dados_pagina(response_json)

      break if pagina >= ultima_pagina

      pagina += 1
    end

    return veiculos
  end
end
