--[[ 
    Roblox GUI Lister → Enviando para seu servidor local (FastAPI)
]]

local API_URL = ""http://192.168.1.212:8000/upload""

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

-- Função de envio para seu site
local function sendToAPI(messageContent)
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            content = messageContent
        })

        local requestFunction = (syn and syn.request) 
            or (http and http.request) 
            or request

        if not requestFunction then
            error("Executor não suporta request")
        end

        return requestFunction({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = data
        })
    end)

    if success then
        print("Dados enviados para o seu servidor!")
    else
        warn("Erro ao enviar: " .. tostring(response))
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

    -- Envia tudo de uma vez
    sendToAPI(formattedInfo)

else
    warn("Jogador local não encontrado.")
end

print("Varredura concluída. Verifique seu site.")
