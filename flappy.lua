--[[ 
    Roblox GUI Lister com Webhook para Delta Executor
    Este script irá percorrer todos os elementos da PlayerGui (ScreenGui, Frame, TextButton, ImageButton, etc.)
    e enviar a estrutura hierárquica e os detalhes para um Webhook do Discord.

    Isso é útil para identificar os nomes exatos e as propriedades de elementos da interface
    que podem ser usados em scripts de automação ou para depuração.

    Instruções:
    1. Copie o conteúdo deste script.
    2. Cole no Delta Executor.
    3. Execute o script.
    4. Verifique o canal do Discord configurado com o Webhook para ver a lista de GUIs.

    **ATENÇÃO**: O Webhook URL está embutido no script. Certifique-se de que é o correto.
]]

local WEBHOOK_URL = "https://discord.com/api/webhooks/1488371810964733972/0vxZMUetBEMnIYUMU0TZu72i2lrQ_ai4ltvarV119HZSdPirp5d1MFg3z1SlgmIqfinm"

-- SERVIÇOS DO ROBLOX
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Função para coletar informações de uma instância e seus filhos
local function collectInstanceInfo(instance, indentLevel)
    local info = {}
    local indent = string.rep("  ", indentLevel)

    -- Adiciona informações básicas da instância
    table.insert(info, indent .. "- Name: " .. instance.Name)
    table.insert(info, indent .. "  Class: " .. instance.ClassName)
    table.insert(info, indent .. "  Parent: " .. (instance.Parent and instance.Parent.Name or "nil"))

    -- Adiciona propriedades específicas para elementos de GUI
    if instance:IsA("GuiObject") then
        table.insert(info, indent .. "  AbsolutePosition: " .. tostring(instance.AbsolutePosition))
        table.insert(info, indent .. "  AbsoluteSize: " .. tostring(instance.AbsoluteSize))
        table.insert(info, indent .. "  Visible: " .. tostring(instance.Visible))
        table.insert(info, indent .. "  ZIndex: " .. tostring(instance.ZIndex))
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            table.insert(info, indent .. "  Text: \"" .. instance.Text .. "\"")
            table.insert(info, indent .. "  TextColor3: " .. tostring(instance.TextColor3))
            table.insert(info, indent .. "  TextSize: " .. tostring(instance.TextSize))
        end
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            table.insert(info, indent .. "  Image: " .. instance.Image)
        end
    end

    -- Coleta informações dos filhos recursivamente
    for _, child in ipairs(instance:GetChildren()) do
        -- Filtra apenas elementos de GUI ou ScreenGui
        if child:IsA("ScreenGui") or child:IsA("GuiObject") then
            for _, line in ipairs(collectInstanceInfo(child, indentLevel + 1)) do
                table.insert(info, line)
            end
        end
    end

    return info
end

-- Função para enviar dados para o Webhook do Discord
local function sendToWebhook(messageContent)
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            content = "```lua\n" .. messageContent .. "\n```", -- Formata como bloco de código Lua
            username = "Roblox GUI Lister Bot",
            avatar_url = "https://www.roblox.com/favicon.ico" -- Ícone do Roblox
        })
        return HttpService:PostAsync(WEBHOOK_URL, data)
    end)

    if success then
        print("Dados enviados para o Webhook com sucesso!")
    else
        warn("Erro ao enviar dados para o Webhook: " .. response)
    end
end

-- Início da varredura
if LocalPlayer then
    print("Iniciando varredura da PlayerGui de " .. LocalPlayer.Name .. "...")
    local guiInfo = {}
    table.insert(guiInfo, "=== PLAYERGUI de " .. LocalPlayer.Name .. " ===")

    for _, screenGui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") then
            for _, line in ipairs(collectInstanceInfo(screenGui, 0)) do
                table.insert(guiInfo, line)
            end
        end
    end

    local formattedInfo = table.concat(guiInfo, "\n")
    sendToWebhook(formattedInfo)
else
    warn("Jogador local não encontrado. Não foi possível varrer a PlayerGui.")
end

print("Varredura de GUI concluída. Verifique o console e o Discord.")
