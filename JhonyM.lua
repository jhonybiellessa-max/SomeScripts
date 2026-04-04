--[[ 
    Roblox AI Chat Bot (Jhony + Groq + ngrok)
    Versão: 1.1 (Com suporte a logs no backend)
]]

local API_URL = "https://snortingly-unbevelled-pearl.ngrok-free.dev/ai"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

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
    if string.sub(lowerText, 1, 5) == "jhonym" then
        -- Extrai a pergunta (pula "jhony" e o espaço/caractere seguinte)
        local pergunta = string.sub(text, 7)
        
        if #pergunta < 2 then
            return
        end

        print("Jhony detectou pergunta: " .. pergunta)

        task.spawn(function()
            local resposta = askAI(pergunta)

            if resposta then
                -- Envia a resposta de volta para o chat
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                    if generalChannel then
                        generalChannel:SendAsync(resposta)
                    else
                        warn("Canal RBXGeneral não encontrado.")
                    end
                else
                    -- Fallback para o sistema de chat antigo
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(resposta, "All")
                end
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
