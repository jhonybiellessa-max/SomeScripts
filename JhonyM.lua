--[[ 
    Roblox AI Chat Bot (Jhony + Groq + ngrok)
    Versão: 1.2 (Com suporte a logs no backend e divisão de mensagens longas)
]]

local API_URL = "https://snortingly-unbevelled-pearl.ngrok-free.dev/ai"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local MAX_MESSAGE_LENGTH = 200 -- Limite de caracteres para mensagens no chat do Roblox

-- Função auxiliar para enviar mensagens ao chat (compatível com TextChatService e sistema legado)
local function sendMessageToChat(message)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            generalChannel:SendAsync(message)
        else
            warn("Canal RBXGeneral não encontrado para enviar mensagem.")
        end
    else
        -- Fallback para o sistema de chat antigo
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
    end
end

-- Função para dividir e enviar mensagens longas
local function sendLongMessage(fullMessage)
    local currentPosition = 1
    while currentPosition <= #fullMessage do
        local chunk = string.sub(fullMessage, currentPosition, currentPosition + MAX_MESSAGE_LENGTH - 1)
        
        -- Tenta quebrar a mensagem em uma palavra completa se não for o último chunk
        if currentPosition + MAX_MESSAGE_LENGTH - 1 < #fullMessage then
            local lastSpace = string.find(chunk, "%s", 1, -1) -- Encontra o último espaço
            if lastSpace and lastSpace > MAX_MESSAGE_LENGTH / 2 then -- Evita chunks muito pequenos
                chunk = string.sub(chunk, 1, lastSpace - 1)
            end
        end
        
        sendMessageToChat(chunk)
        currentPosition = currentPosition + #chunk
        task.wait(0.1) -- Pequeno delay para evitar flood no chat
    end
end

-- 🔁 Função IA
local function askAI(prompt)
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            prompt = prompt
        })

        -- Tenta encontrar a função de requisição disponível no executor
        local requestFunction = (syn and syn.request) 
            or (http and http.request) 
            or (fluxus and fluxus.request)
            or (Krnl and Krnl.request)
            or request

        if not requestFunction then
            warn("Nenhuma função de requisição HTTP encontrada no executor.")
            return nil
        end

        return requestFunction({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["ngrok-skip-browser-warning"] = "true"
            },
            Body = data
        })
    end)

    if success and response and response.Body then
        local decoded = HttpService:JSONDecode(response.Body)
        if decoded.response then
            return decoded.response
        elseif decoded.error then
            warn("Erro retornado pelo backend: " .. tostring(decoded.error))
            return "Erro no backend: " .. tostring(decoded.error)
        end
    end

    warn("Falha na requisição HTTP ou resposta inválida.")
    return "Erro ao falar com a IA. Verifique se o servidor está online."
end

-- 🧠 Detecta mensagem
local function processMessage(text)
    local lowerText = text:lower()

    -- Verifica se a mensagem começa com "jhony"
    if string.sub(lowerText, 1, 5) == "jhony" then
        -- Extrai a pergunta (pula "jhony" e o espaço/caractere seguinte)
        local pergunta = string.sub(text, 7)
        
        if #pergunta < 2 then
            return
        end

        print("Jhony detectou pergunta: " .. pergunta)

        task.spawn(function()
            local resposta = askAI(pergunta)

            if resposta then
                sendLongMessage(resposta) -- Usa a nova função para enviar a resposta
            end
        end)
    end
end

-- 📡 Conectar chat
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        if msg.TextSource then
            processMessage(msg.Text)
        end
    end)
    print("JhonyRobloxIA: Conectado ao TextChatService")
else
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg)
            processMessage(msg)
        end)
    end)
    
    -- Conectar jogadores já presentes no servidor
    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(msg)
            processMessage(msg)
        end)
    end
    print("JhonyRobloxIA: Conectado ao sistema de chat legado")
end

print("JhonyRobloxIA carregado com sucesso!")
