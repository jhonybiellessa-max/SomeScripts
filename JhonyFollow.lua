local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local targetPlayer = nil
local isFollowing = false

-- Função para enviar mensagem no chat
local function sendMessageToChat(msg)
    print(msg) -- você pode adaptar pra aparecer no chat se quiser
end

-- Processar comandos
local function processChatCommand(message, speaker)
    local lowerMessage = message:lower()

    -- COMANDO FOLLOW
    if lowerMessage:sub(1, 7) == "!follow" then
        local targetName = message:sub(8):gsub("^%s*", "") -- remove espaços
        local playerToFollow = Players:FindFirstChild(targetName)

        if playerToFollow then
            if playerToFollow ~= localPlayer then
                targetPlayer = playerToFollow
                isFollowing = true
                sendMessageToChat("JhonyFollow: Agora estou seguindo " .. targetPlayer.Name .. ".")
            else
                sendMessageToChat("JhonyFollow: Não posso seguir a mim mesmo!")
            end
        else
            sendMessageToChat("JhonyFollow: Jogador '" .. targetName .. "' não encontrado.")
        end

    -- COMANDO UNFOLLOW
    elseif lowerMessage == "!unfollow" then
        if isFollowing then
            isFollowing = false
            targetPlayer = nil
            sendMessageToChat("JhonyFollow: Parei de seguir.")
        else
            sendMessageToChat("JhonyFollow: Não estou seguindo ninguém.")
        end
    end
end

-- Conectar chat
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        if msg.TextSource and msg.TextSource.UserId == localPlayer.UserId then
            processChatCommand(msg.Text, localPlayer)
        end
    end)
    print("JhonyFollow: Usando TextChatService")
else
    localPlayer.Chatted:Connect(function(msg)
        processChatCommand(msg, localPlayer)
    end)
    print("JhonyFollow: Usando chat legado")
end

-- Atualizar personagem ao respawn
localPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:FindFirstChildOfClass("Humanoid")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end)

print("JhonyFollow: Script carregado com sucesso!")
