local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local targetPlayer = nil
local isFollowing = false

-- Função para enviar mensagem
local function sendMessageToChat(msg)
    print(msg)
end

-- Atualizar personagem ao respawn
localPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Encontrar player ignorando maiúsculas/minúsculas
local function findPlayerByName(name)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == name:lower() then
            return player
        end
    end
    return nil
end

-- Processar comandos
local function processChatCommand(message)
    local lowerMessage = message:lower()

    -- FOLLOW
    if lowerMessage:sub(1, 7) == "!follow" then
        local targetName = message:sub(8):gsub("^%s*", "")
        local playerToFollow = findPlayerByName(targetName)

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

    -- UNFOLLOW
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
            processChatCommand(msg.Text)
        end
    end)
    print("JhonyFollow: Usando TextChatService")
else
    localPlayer.Chatted:Connect(function(msg)
        processChatCommand(msg)
    end)
    print("JhonyFollow: Usando chat legado")
end

-- LOOP DE FOLLOW
task.spawn(function()
    while true do
        task.wait(0.2)

        if isFollowing and targetPlayer then
            local targetCharacter = targetPlayer.Character

            if targetCharacter and humanoid and humanoidRootPart then
                local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")

                if targetHRP then
                    local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude

                    -- Só se move se estiver longe
                    if distance > 5 then
                        humanoid:MoveTo(targetHRP.Position)
                    end
                end
            end
        end
    end
end)

print("JhonyFollow: Script carregado com sucesso!")
