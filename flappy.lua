--[[ 
    Roblox GUI Explorer Sender → Envia estrutura em árvore para seu servidor
]]

local API_URL = "https://snortingly-unbevelled-pearl.ngrok-free.dev/upload"

-- SERVIÇOS
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- 🔥 Função para construir árvore da GUI
local function buildTree(instance)
    local node = {
        name = instance.Name,
        class = instance.ClassName,
        properties = {},
        children = {}
    }

    -- Propriedades gerais
    if instance:IsA("GuiObject") then
        node.properties = {
            Visible = instance.Visible,
            Size = tostring(instance.Size),
            Position = tostring(instance.Position),
            AbsoluteSize = tostring(instance.AbsoluteSize),
            AbsolutePosition = tostring(instance.AbsolutePosition),
            ZIndex = instance.ZIndex
        }

        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            node.properties.Text = instance.Text
            node.properties.TextSize = instance.TextSize
            node.properties.TextColor3 = tostring(instance.TextColor3)
        end

        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            node.properties.Image = instance.Image
        end
    end

    -- 🔁 Filhos (recursivo)
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("ScreenGui") or child:IsA("GuiObject") then
            table.insert(node.children, buildTree(child))
        end
    end

    return node
end

-- 📤 Função de envio
local function sendToAPI(treeData)
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            content = treeData
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
                ["Content-Type"] = "application/json",
                ["ngrok-skip-browser-warning"] = "true"
            },
            Body = data
        })
    end)

    if success then
        print("Árvore enviada para o servidor com sucesso!")
    else
        warn("Erro ao enviar: " .. tostring(response))
    end
end

-- 🚀 INÍCIO
if LocalPlayer then
    print("Iniciando varredura da PlayerGui de " .. LocalPlayer.Name .. "...")

    local tree = {}

    for _, screenGui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") then
            table.insert(tree, buildTree(screenGui))
        end
    end

    -- Converte para JSON e envia
    local encodedTree = HttpService:JSONEncode(tree)
    sendToAPI(encodedTree)

else
    warn("Jogador local não encontrado.")
end

print("Varredura concluída. Verifique seu site.")
