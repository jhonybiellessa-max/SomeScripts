--[[ 
    Roblox GUI Explorer Sender → Versão FINAL (Estável e sem erros)
]]

-- ============================================================================
-- CONFIGURAÇÃO
-- ============================================================================
local API_URL = "https://snortingly-unbevelled-pearl.ngrok-free.dev/upload"

-- ============================================================================
-- SERVIÇOS
-- ============================================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ============================================================================
-- VARIÁVEIS
-- ============================================================================
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- FUNÇÕES AUXILIARES
-- ============================================================================

-- 🔥 Pega propriedade sem quebrar o script
local function safeGet(instance, property)
    local success, value = pcall(function()
        return instance[property]
    end)
    return success and value or nil
end

-- 🔥 Formata valores
local function formatPropertyValue(value)
    if value == nil then return nil end

    local t = typeof(value)

    if t == "Vector2" or t == "Vector3" or t == "UDim2" or t == "Color3" then
        return tostring(value)
    elseif t == "boolean" or t == "number" or t == "string" then
        return value
    else
        return tostring(value)
    end
end

-- ============================================================================
-- CONSTRUTOR DA ÁRVORE
-- ============================================================================

local function buildTree(instance)
    local node = {
        name = instance.Name,
        class = instance.ClassName,
        properties = {},
        children = {}
    }

    if instance:IsA("GuiObject") then
        local props = {}

        -- 🔥 Propriedades seguras (NUNCA quebra)
        props.Visible = safeGet(instance, "Visible")
        props.Active = safeGet(instance, "Active")
        props.Size = safeGet(instance, "Size")
        props.Position = safeGet(instance, "Position")
        props.AnchorPoint = safeGet(instance, "AnchorPoint")
        props.ZIndex = safeGet(instance, "ZIndex")
        props.LayoutOrder = safeGet(instance, "LayoutOrder")

        props.BackgroundColor3 = safeGet(instance, "BackgroundColor3")
        props.BackgroundTransparency = safeGet(instance, "BackgroundTransparency")
        props.BorderColor3 = safeGet(instance, "BorderColor3")
        props.BorderSizePixel = safeGet(instance, "BorderSizePixel")

        props.SizeConstraint = safeGet(instance, "SizeConstraint")
        props.AutomaticSize = safeGet(instance, "AutomaticSize")

        -- 🔥 BOTÕES (evita erro)
        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            props.AutoButtonColor = safeGet(instance, "AutoButtonColor")
            props.Modal = safeGet(instance, "Modal")
        end

        -- 🔥 SCROLL
        if instance:IsA("ScrollingFrame") then
            props.CanvasSize = safeGet(instance, "CanvasSize")
            props.ScrollBarThickness = safeGet(instance, "ScrollBarThickness")
        end

        -- 🔥 TEXTO
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            props.Text = safeGet(instance, "Text")
            props.TextSize = safeGet(instance, "TextSize")
            props.TextColor3 = safeGet(instance, "TextColor3")
            props.TextTransparency = safeGet(instance, "TextTransparency")
            props.TextScaled = safeGet(instance, "TextScaled")
            props.TextWrapped = safeGet(instance, "TextWrapped")
        end

        -- 🔥 IMAGEM
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            props.Image = safeGet(instance, "Image")
            props.ImageColor3 = safeGet(instance, "ImageColor3")
            props.ImageTransparency = safeGet(instance, "ImageTransparency")
        end

        -- 🔥 Formata tudo
        for key, value in pairs(props) do
            local formatted = formatPropertyValue(value)
            if formatted ~= nil then
                node.properties[key] = formatted
            end
        end
    end

    -- 🔁 Filhos
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("ScreenGui") or child:IsA("GuiObject") then
            table.insert(node.children, buildTree(child))
        end
    end

    return node
end

-- ============================================================================
-- ENVIO PARA API
-- ============================================================================

local function sendToAPI(treeData)
    local success, response = pcall(function()
        local data = HttpService:JSONEncode({
            content = HttpService:JSONEncode(treeData)
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
        print("Árvore enviada com sucesso!")
    else
        warn("Erro ao enviar: " .. tostring(response))
    end
end

-- ============================================================================
-- EXECUÇÃO
-- ============================================================================

if LocalPlayer then
    print("Iniciando varredura da PlayerGui de " .. LocalPlayer.Name .. "...")

    local tree = {}

    for _, screenGui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") then
            table.insert(tree, buildTree(screenGui))
        end
    end

    sendToAPI(tree)

    print("Varredura concluída. Verifique seu site.")
else
    warn("Jogador local não encontrado.")
end
