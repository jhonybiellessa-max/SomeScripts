--[[ 
    Roblox Follow Script (JhonyFollow)
    Versão: 1.1 (Com lógica de seguimento)
]]

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = localPlayer and localPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

local targetPlayer = nil
local isFollowing = false
local FOLLOW_DISTANCE = 10 -- Distância mínima para manter do alvo

-- Função para enviar mensagem no chat (adaptada para o chat do Roblox)
local function sendMessageToChat(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            generalChannel:SendAsync(msg)
        else
            warn("JhonyFollow: Canal RBXGeneral não encontrado para enviar mensagem.")
        end
    else
        -- Fallback para o sistema de chat antigo
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

-- Função principal de seguimento
local function updateFollow()
    if isFollowing and targetPlayer and targetPlayer.Character and humanoid and humanoidRootPart then
        local targetCharacter = targetPlayer.Character
        local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")

        if targetHumanoidRootPart then
            local distance = (humanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude

            if distance > FOLLOW_DISTANCE then
                humanoid:MoveTo(targetHumanoidRootPart.Position)
            else
                humanoid:MoveTo(humanoidRootPart.Position) -- Parar de se mover se estiver perto o suficiente
            end
        else
            sendMessageToChat("JhonyFollow: O personagem de " .. targetPlayer.Name .. " não tem HumanoidRootPart. Parando de seguir.")
            isFollowing = false
            targetPlayer = nil
        end
    end
end

-- Conectar a função de seguimento ao RunService.Stepped para atualização contínua
RunService.Stepped:Connect(updateFollow)

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
        -- Processa comandos apenas se vierem do próprio jogador local
        if msg.TextSource and msg.TextSource.UserId == localPlayer.UserId then
            processChatCommand(msg.Text, localPlayer)
        end
    end)
    print("JhonyFollow: Usando TextChatService para comandos.")
else
    if localPlayer then
        localPlayer.Chatted:Connect(function(msg)
            processChatCommand(msg, localPlayer) -- No sistema legado, msg é a string e localPlayer é o speaker
        end)
        print("JhonyFollow: Usando chat legado para comandos.")
    else
        warn("JhonyFollow: LocalPlayer não encontrado. O script pode não funcionar corretamente.")
    end
end

-- Atualizar personagem ao respawn
if localPlayer then
    localPlayer.CharacterAdded:Connect(function(char)
        character = char
        humanoid = character:FindFirstChildOfClass("Humanoid")
        humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart then
            warn("JhonyFollow: Humanoid ou HumanoidRootPart não encontrados no personagem após respawn.")
        end
    end)
else
    warn("JhonyFollow: LocalPlayer não disponível no início. Certifique-se de que este é um LocalScript.")
end

-- Verificações iniciais para garantir que o personagem e Humanoid/HumanoidRootPart existam
if not character then
    localPlayer.CharacterAdded:Wait() -- Espera o personagem carregar se ainda não estiver pronto
    character = localPlayer.Character
    humanoid = character:FindFirstChildOfClass("Humanoid")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end

if not humanoid or not humanoidRootPart then
    warn("JhonyFollow: Humanoid ou HumanoidRootPart não encontrados no personagem. O seguimento pode não funcionar.")
end

print("JhonyFollow: Script de seguimento carregado com sucesso!")
