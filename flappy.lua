--[[ 
    Bot para Flappy Box (Roblox) - Adaptado para Delta Executor
    Baseado na lógica do script Python original, mas reescrito para Lua/Luau
    e adaptado para interagir diretamente com objetos do Workspace do Roblox.

    Este script assume que o jogo Flappy Box no Roblox possui:
    - Um objeto que representa o jogador (a 'caixa'), com um nome identificável (ex: 'PlayerBox' ou 'Bird').
    - Objetos que representam os canos (obstáculos), com nomes identificáveis (ex: 'PipeTop', 'PipeBottom', 'Obstacle').
    - Uma forma de acionar o pulo do jogador (ex: um RemoteEvent, uma função global, ou manipulando o Humanoid.Jump).

    **IMPORTANTE:** Você pode precisar ajustar os nomes dos objetos e a forma de pular
    para corresponder ao jogo específico que você está jogando no Roblox.
]]

-- CONFIGURAÇÕES
local PLAYER_BOX_NAME = "PlayerBox" -- Nome do objeto do jogador no Workspace
local PIPE_PART_NAME = "Pipe"       -- Nome base dos objetos dos canos no Workspace
local JUMP_FUNCTION_NAME = "JumpEvent" -- Nome do RemoteEvent ou função para pular

local DISTANCIA_OLHAR_LONGE = 180 -- Distância à frente para procurar canos (em studs)
local DISTANCIA_OLHAR_PERTO = 100 -- Distância para manter o foco ao passar pelo cano (em studs)
local MARGEM_CENTRO = 4           -- Margem de precisão para o centro do vão
local DELAY_PULO_BASE = 0.10      -- Tempo mínimo entre pulos (em segundos)

-- SERVIÇOS DO ROBLOX
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Variáveis de estado
local ultimo_pulo = 0
local caixa_y_anterior = 0
local alvo_y_suave = 0
local bot_ativo = false

-- Função para simular o pulo
local function Pular()
    -- Tenta encontrar um RemoteEvent ou função para pular
    local jumpEvent = game:GetService("ReplicatedStorage"):FindFirstChild(JUMP_FUNCTION_NAME)
    if jumpEvent and jumpEvent:IsA("RemoteEvent") then
        jumpEvent:FireServer() -- Se for RemoteEvent, dispara para o servidor
    elseif _G[JUMP_FUNCTION_NAME] and typeof(_G[JUMP_FUNCTION_NAME]) == "function" then
        _G[JUMP_FUNCTION_NAME]() -- Se for função global, chama-a
    else
        -- Fallback: Tenta usar o Humanoid.Jump (pode não funcionar em todos os jogos)
        Humanoid.Jump = true
        task.wait(0.1) -- Pequeno delay para garantir o pulo
        Humanoid.Jump = false
    end
end

-- Função para detectar a caixa do jogador
local function detectar_caixa()
    return Workspace:FindFirstChild(PLAYER_BOX_NAME)
end

-- Função para encontrar o vão entre os canos
local function encontrar_vao_procedural(playerBox)
    local playerPos = playerBox.Position
    local playerX = playerPos.X
    local playerY = playerPos.Y

    local pipes = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if string.find(child.Name, PIPE_PART_NAME) and child:IsA("BasePart") then
            -- Filtra canos que estão à frente do jogador
            if child.Position.X > playerX + DISTANCIA_OLHAR_PERTO and child.Position.X < playerX + DISTANCIA_OLHAR_LONGE then
                table.insert(pipes, child)
            end
        end
    end

    if #pipes == 0 then return nil end

    -- Ordena os canos por posição X para processar na ordem correta
    table.sort(pipes, function(a, b) return a.Position.X < b.Position.X end)

    local closestPipeX = nil
    local gapTopY = nil
    local gapBottomY = nil

    -- Tenta encontrar um par de canos (superior e inferior) que formam um vão
    for i = 1, #pipes do
        local pipe1 = pipes[i]
        for j = i + 1, #pipes do
            local pipe2 = pipes[j]

            -- Verifica se estão na mesma coluna X (ou muito próximos)
            if math.abs(pipe1.Position.X - pipe2.Position.X) < 5 then -- Margem de erro para X
                -- Assume que um é o topo e outro é o fundo
                if pipe1.Position.Y > pipe2.Position.Y then -- pipe1 é o de cima
                    gapTopY = pipe1.Position.Y - (pipe1.Size.Y / 2)
                    gapBottomY = pipe2.Position.Y + (pipe2.Size.Y / 2)
                else -- pipe2 é o de cima
                    gapTopY = pipe2.Position.Y - (pipe2.Size.Y / 2)
                    gapBottomY = pipe1.Position.Y + (pipe1.Size.Y / 2)
                end

                -- Se um vão foi encontrado, calcula o centro Y
                if gapTopY and gapBottomY and gapTopY > gapBottomY then
                    closestPipeX = pipe1.Position.X
                    return (gapTopY + gapBottomY) / 2
                end
            end
        end
    end

    return nil
end

-- Loop principal do bot
local function main_loop()
    print("\n" .. string.rep("🚀", 20))
    print("   FLAPPY BOX BOT (DELTA EXECUTOR)   ")
    print("🚀" .. string.rep("🚀", 19))
    print("Comandos: 'Q' para parar | 'P' para iniciar/pausar")

    for i = 3, 1, -1 do
        print(string.format("Iniciando em %d...\r", i))
        task.wait(1)
    end
    print("\nBot Inativo. Pressione 'P' para iniciar.")

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.Q then
            bot_ativo = false
            print("\nBot Desativado. Pressione 'P' para iniciar novamente.")
        elseif input.KeyCode == Enum.KeyCode.P then
            bot_ativo = not bot_ativo
            if bot_ativo then
                print("\nBot Ativo! Dominando vãos procedurais...")
            else
                print("\nBot Pausado. Pressione 'P' para retomar.")
            end
        end
    end)

    RunService.Stepped:Connect(function()
        if not bot_ativo then return end

        local playerBox = detectar_caixa()
        if not playerBox then
            print("Objeto do jogador não encontrado. Verifique PLAYER_BOX_NAME.")
            return
        end

        local cY = playerBox.Position.Y
        local velocidade_y = cY - caixa_y_anterior
        caixa_y_anterior = cY

        local alvo_y_real = encontrar_vao_procedural(playerBox)

        if alvo_y_real ~= nil then
            if alvo_y_suave == 0 then alvo_y_suave = alvo_y_real end
            alvo_y_suave = (alvo_y_suave * 0.7) + (alvo_y_real * 0.3)
            print(string.format("Caixa: %d | Alvo: %d | VÃO DETECTADO EM %d 🟢\r", math.floor(cY), math.floor(alvo_y_suave), math.floor(alvo_y_real)))
        else
            if alvo_y_suave == 0 then alvo_y_suave = playerBox.Size.Y * 0.5 end -- Centro da tela como fallback
            print(string.format("Caixa: %d | Alvo: %d | BUSCANDO PRÓXIMO VÃO... 🔍\r", math.floor(cY), math.floor(alvo_y_suave)))
        end

        -- LÓGICA DE HOVER (PLANAR)
        local ponto_futuro_y = cY + (velocidade_y * 1.5)

        if ponto_futuro_y > (alvo_y_suave + MARGEM_CENTRO) then
            local agora = os.clock()
            local delay_ajustado = DELAY_PULO_BASE
            if velocidade_y > 5 then delay_ajustado = delay_ajustado * 0.8 end

            if agora - ultimo_pulo > delay_ajustado then
                Pular()
                ultimo_pulo = agora
            end
        end
    end)
end

-- Inicia o bot
main_loop()
