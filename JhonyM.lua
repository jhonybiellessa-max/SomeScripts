--[[ 
    Roblox AI Chat Bot (Jhony + Groq + ngrok)
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

        local requestFunction = (syn and syn.request) 
            or (http and http.request) 
            or request

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
        return decoded.response
    end

    return "Erro ao falar com a IA"
end

-- 🧠 Detecta mensagem
local function processMessage(text)
    text = text:lower()

    if string.sub(text, 1, 5) == "jhony" then
        local pergunta = string.sub(text, 7)

        task.spawn(function()
            local resposta = askAI(pergunta)

            if resposta then
                TextChatService.TextChannels.RBXGeneral:SendAsync(resposta)
            end
        end)
    end
end

-- 📡 Conectar chat
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        processMessage(msg.Text)
    end)
else
    local Players = game:GetService("Players")

    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(msg)
            processMessage(msg)
        end)
    end
end
