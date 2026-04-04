local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local targetPlayer = nil
local isFollowing = false

-- Função de mensagem
local function sendMessageToChat(msg)
    print(msg)
end

-- Atualizar personagem ao respawn
localPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Encontrar player por Name OU DisplayName
local function findPlayer(name)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == name:lower() 
        or player.DisplayName:lower() == name:lower() then
            return player
        end
    end
    return nil
end

-- Encontrar player mais próximo
local function getClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and humanoidRootPart then
                local distance = (humanoidRootPart.Position - hrp.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end

    return closest
end

-- Processar comandos
local function processChatCommand(message)
    local lowerMessage = message:lower()

    -- FOLLOW
    if lowerMessage:sub(1, 7) == "!follow" then
        local targetName = message:sub(8):gsub("^%s*", "")

        -- Se vier ##### ou vazio → pega o mais próximo
        if targetName == "" or targetName:find("#") then
            local closest = getClosestPlayer()
            if closest then
                targetPlayer = closest
                isFollowing = true
                sendMessageToChat("JhonyFollow: Seguindo o jogador mais próximo: " .. closest.Name)
            else
                sendMessageToChat("JhonyFollow: Nenhum jogador próximo encontrado.")
            end
            return
        end

        local playerToFollow = findPlayer(targetName)

        if playerToFollow then
            if playerToFollow ~= localPlayer then
                targetPlayer = playerToFollow
                isFollowing = true
                sendMessageToChat("JhonyFollow: Agora estou seguindo " .. playerToFollow.Name)
            else
                sendMessageToChat("JhonyFollow: Não posso seguir a mim mesmo!")
            end
        else
            sendMessageToChat("JhonyFollow: Jogador não encontrado.")
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

-- Chat
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        if msg.TextSource and msg.TextSource.UserId == localPlayer.UserId then
            processChatCommand(msg.Text)
        end
    end)
else
    localPlayer.Chatted:Connect(function(msg)
        processChatCommand(msg)
    end)
end

-- LOOP FOLLOW
task.spawn(function()
    while true do
        task.wait(0.2)

        if isFollowing and targetPlayer then
            local targetChar = targetPlayer.Character

            if targetChar and humanoid and humanoidRootPart then
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

                if targetHRP then
                    local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude

                    if distance > 5 then
                        humanoid:MoveTo(targetHRP.Position)
                    end
                end
            end
        end
    end
end)

print("JhonyFollow: Script pronto!")
