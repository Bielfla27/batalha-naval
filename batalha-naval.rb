require "ruby2d"
require_relative "./grid.rb"
require_relative "./computador.rb"

set background: Image.new("./images/fundo.png")
set width: 1155, height: 600
set title: "BATALHA NAVAL"

orientacaoNavio = 0 #true significa que o jogador quer colocar o navio na Horizontal
@tabuleiro = Grid.new
start = false # var. para saber se alguma tecla já foi pressionada
@vezDoComputador = false
navios = [6, 4, 3, 3, 1]
i = 0
previsualizacao = Image.new("./images/porta_avioes.png", width: 300, x: 600, y: 300, rotate: 0)
@botao = Rectangle.new(x: 80, y: 285, z: 20, width: 400, height: 60, color: "green", opacity: 0)
@ganhador = Image.new("./images/medal.png", width: 200, height: 200, x: 180, y: 200, opacity: 0)

def mapeamento_aleatorio(intervalo_x, intervalo_y)
  # retorna um valor aleatório para x e y, dados seus intervalos
  # retorna também uma orientação, 0 ou 90
  [rand(intervalo_x), rand(intervalo_y), [0, 90].shuffle.first]
end

on :mouse_down do |event|
  #puts event.x, event.y
  #puts "\n"
  p @vezDoComputador
  start == true ? square = @computador.contains(event.x, event.y) : square = @tabuleiro.contains(event.x, event.y)

  if square && @vezDoComputador == false # só irá executar se eu estou clicando em um quadrado e se não for a vez do computador
    if !start
      if i <= 4
        if @tabuleiro.mapearNavio(@tabuleiro.getPosicao(event.x, event.y), navios[i], orientacaoNavio) # o segundo parâmetro é o tamanho do barco /// se o barco foi inserido corretamente, entra
          previsualizacao.remove #remover o navio que estava antes para poder mostrar o navio novo sem que tenha uma imagem sobrepondo outra
          i = i + 1 #incremento para o proximo indice do vetor de navios
          previsualizacao = Image.new("./images/navio_de_guerra.png", width: 200, x: 650, y: 300, rotate: orientacaoNavio) if i == 1 #se o indice for 1, mostro o navio de guerra
          previsualizacao = Image.new("./images/navio_encouracado.png", width: 150, x: 700, y: 300, rotate: orientacaoNavio) if i == 2 or i == 3 #se o indice for 2 ou 3, mostro o navio encouraçado
          previsualizacao = Image.new("./images/submarino.png", width: 50, x: 750, y: 300, rotate: orientacaoNavio) if i == 4 # se o indice for 4, mostro o submarino
          @botao.opacity = 100 and @mensagemInicioJogo = Text.new("Click para iniciar o jogo", x: 90, y: 300, z: 25, size: 30, color: "white") and @tabuleiro.messageOrientacaoNavio.remove and @tabuleiro.messageMudarOrientacao.remove and @tabuleiro.message.remove if i == 5 #apagando as mensagens sobre a orietação do navio        end
        end
      else
        @mensagemInicioJogo.remove
        @botao.remove
        @computador = Computador.new  #cria um novo @tabuleiro para computador

        navios.each do |navio|
          loop do
            mapeamento = mapeamento_aleatorio((621..1119), (101..599))
            i = @computador.getPosicao(mapeamento[0], mapeamento[1])
            break if @computador.mapearNavio(i, navio, mapeamento[2])
          end
        end

        start = true
        @tabuleiro.message.text = "ACHE OS BARCOS"
        @tabuleiro.esconderNavios
        @computador.esconderNavios
        @jogadas = Image.new("./images/play.png", width: 70, height: 70, x: 535, y: 300)
      end
    else #o jogo iniciou
      if !@tabuleiro.posicaoJaJogada?(@computador.getPosicao(event.x, event.y))
        if @computador.temNavio?(@computador.getPosicao(event.x, event.y))
          @computador.revelarNavio(@computador.getPosicao(event.x, event.y))
          #verificar se alguém ganhou
          if @computador.ganhou?
            @ganhador.opacity = 100
            @tabuleiro.message.text = "TODOS OS BARCOS FORAM ENCONTRADOS"
          end
        else
          @computador.naoExisteNavio(@computador.getPosicao(event.x, event.y)) #pinta de vermelho
          #vez do computador
          @vezDoComputador = true
        end
        @tabuleiro.definirPosicaoComoJogada(@computador.getPosicao(event.x, event.y))
      end
    end
  end
end

# parte para quando o jogador clicar em Espaço, ele inserir o navio na Vertical e vice-versa
on :key_down do |event|
  if event.key == "space" && orientacaoNavio == 0
    orientacaoNavio = 90
    previsualizacao.rotate = 90
    @tabuleiro.messageOrientacaoNavio.text = "O barco será inserido na Vertical"
  else
    orientacaoNavio = 0
    previsualizacao.rotate = 0
    @tabuleiro.messageOrientacaoNavio.text = "O barco será inserido na Horizontal"
  end
end

clock = 1
update do
  if @vezDoComputador
    @jogadas.rotate = 180
    if clock % 120 == 0 # espera 2 segundos antes de jogar
      mapeamento = 0 # apenas para definir a variável, porque não daria pra acessar depois se a definição ficasse apenas no loop
      #vai entrar nesse loop enquanto não sair uma posição que ainda não foi jogada
      loop do
        mapeamento = mapeamento_aleatorio((21..519), (101..599)) # intervalo do jogador já definido
        break if !@computador.posicaoJaJogada?(@tabuleiro.getPosicao(mapeamento[0], mapeamento[1])) || !@computador.haPosicoesNaoJogadas()
      end
      @computador.definirPosicaoComoJogada(@tabuleiro.getPosicao(mapeamento[0], mapeamento[1])) # adiciona a posição jogada no array de posições jogadas
      # print @computador.jogadas

      if @tabuleiro.temNavio?(@tabuleiro.getPosicao(mapeamento[0], mapeamento[1]))
        @tabuleiro.revelarNavio(@tabuleiro.getPosicao(mapeamento[0], mapeamento[1]))
        if @tabuleiro.ganhou?
          @ganhador.opacity = 100
          @ganhador.x = 760
          @ganhador.y = 200
          @ganhador.z = 20
          @tabuleiro.message.text = "TODOS OS BARCOS FORAM ENCONTRADOS"
        end
      else
        @tabuleiro.naoExisteNavio(@tabuleiro.getPosicao(mapeamento[0], mapeamento[1])) #pinta de vermelho
        @vezDoComputador = false
        @jogadas.rotate = 0
      end
    end
    clock += 1
  end
end

show
