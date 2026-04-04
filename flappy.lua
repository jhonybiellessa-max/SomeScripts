--[[ 
    Roblox GUI Lister com Webhook (VERSÃO CORRIGIDA PARA EXECUTOR)

    Agora usa request/http.request/syn.request ao invés de HttpService:PostAsync
    para evitar o erro: "vulnerable function"
]]

local WEBHOOK_URL = "https://discord.com/api/webhooks/1488371810964733972/0vxZMUetBEMnIYUMU0TZu72i2lrQ_ai4ltvarV119HZSdPirp5d1MFg3z1SlgmIqfinm"

-- SERVIÇOS
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Função para coletar informações
local function collectInstanceInfo(instance, indentLevel)
    local info = {}
    local indent = string.rep("  ", indentLevel)

    table.insert(info, indent .. "- Name: " .. instance.Name)
    table.insert(info, indent .. "  Class: " .. instance.ClassName)
    table.insert(info, indent .. "  Parent: " .. (instance.Parent and instance.Parent.Name or "nil"))

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

    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("ScreenGui") or child:IsA("GuiObject") then
            for _, line in ipairs(collectInstanceInfo(child, indentLevel + 1)) do
                table.insert(info, line)
            end
        end
    end

    return info
end

-- Função de envio CORRIGIDA
local function sendToWebhook(messageContent)
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            content = "```lua\n" .. messageContent .. "\n```",
            username = "Roblox GUI Lister Bot",
            avatar_url = "https://www.roblox.com/favicon.ico"
        })

        -- Detecta automaticamente a função disponível no executor
        local requestFunction = (syn and syn.request) 
            or (http and http.request) 
            or request

        if not requestFunction then
            error("Executor não suporta request")
        end

        return requestFunction({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = data
        })
    end)

    if success then
        print("Dados enviados para o Webhook com sucesso!")
    else
        warn("Erro ao enviar dados para o Webhook: " .. tostring(response))
    end
end

-- INÍCIO
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

    -- ⚠️ Discord tem limite de 2000 caracteres, então vamos dividir
    local chunkSize = 1900
    for i = 1, #formattedInfo, chunkSize do
        local chunk = string.sub(formattedInfo, i, i + chunkSize - 1)
        sendToWebhook(chunk)
        task.wait(1) -- evita rate limit
    end
else
    warn("Jogador local não encontrado.")
end

print("Varredura de GUI concluída. Verifique o Discord.")
