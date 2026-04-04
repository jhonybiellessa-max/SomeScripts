--[[ 
    Roblox GUI Explorer Sender → Envia estrutura em árvore para seu servidor
    Versão Melhorada
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
-- VARIÁVEIS GLOBAIS
-- ============================================================================
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- FUNÇÕES AUXILIARES
-- ============================================================================

--- Retorna um valor de propriedade formatado para envio.
local function formatPropertyValue(value)
    if typeof(value) == "Vector2" or typeof(value) == "Vector3" or typeof(value) == "UDim2" or typeof(value) == "Color3" then
        return tostring(value)
    elseif typeof(value) == "boolean" or typeof(value) == "number" or typeof(value) == "string" then
        return value
    else
        -- Para outros tipos complexos, pode-se decidir como serializar ou ignorar.
        -- Por enquanto, retorna tostring para ter alguma representação.
        return tostring(value)
    end
end

--- Constrói uma árvore hierárquica de instâncias da GUI.
--- @param instance Instance O objeto Instance a ser processado.
--- @return table Uma tabela representando o nó da árvore.
local function buildTree(instance)
    local node = {
        name = instance.Name,
        class = instance.ClassName,
        properties = {},
        children = {}
    }

    -- Coleta de propriedades relevantes para GuiObjects
    if instance:IsA("GuiObject") then
        local props = {
            -- Propriedades de Layout
            Visible = instance.Visible,
            Active = instance.Active,
            Size = instance.Size,
            Position = instance.Position,
            AnchorPoint = instance.AnchorPoint,
            ZIndex = instance.ZIndex,
            ClipsDescendants = instance.ClipsDescendants,
            LayoutOrder = instance.LayoutOrder,

            -- Propriedades de Aparência
            BackgroundColor3 = instance.BackgroundColor3,
            BackgroundTransparency = instance.BackgroundTransparency,
            BorderColor3 = instance.BorderColor3,
            BorderMode = instance.BorderMode,
            BorderSizePixel = instance.BorderSizePixel,
            Draggable = instance.Draggable,
            Selectable = instance.Selectable,
            Transparency = instance.Transparency,

            -- Propriedades de Interação
            AutoButtonColor = instance.AutoButtonColor,
            Modal = instance.Modal,
            ResizesContents = instance.ResizesContents,
            SizeConstraint = instance.SizeConstraint,
            AutomaticSize = instance.AutomaticSize,
        }

        -- Propriedades específicas de texto
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            props.Text = instance.Text
            props.Font = instance.Font.Name
            props.TextSize = instance.TextSize
            props.TextColor3 = instance.TextColor3
            props.TextTransparency = instance.TextTransparency
            props.TextStrokeColor3 = instance.TextStrokeColor3
            props.TextStrokeTransparency = instance.TextStrokeTransparency
            props.TextScaled = instance.TextScaled
            props.TextWrapped = instance.TextWrapped
            props.TextXAlignment = instance.TextXAlignment.Name
            props.TextYAlignment = instance.TextYAlignment.Name
        end

        -- Propriedades específicas de imagem
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            props.Image = instance.Image
            props.ImageColor3 = instance.ImageColor3
            props.ImageTransparency = instance.ImageTransparency
            props.ScaleType = instance.ScaleType.Name
            props.SliceCenter = instance.SliceCenter
            props.SliceScale = instance.SliceScale
            props.TileSize = instance.TileSize
        end

        -- Formata e adiciona propriedades ao nó
        for key, value in pairs(props) do
            node.properties[key] = formatPropertyValue(value)
        end
    end

    -- Processa filhos recursivamente
    for _, child in ipairs(instance:GetChildren()) do
        -- Filtra apenas ScreenGuis e GuiObjects para a árvore
        if child:IsA("ScreenGui") or child:IsA("GuiObject") then
            table.insert(node.children, buildTree(child))
        end
    end

    return node
end

--- Envia os dados da árvore para a API.
--- @param treeData table A tabela de dados da árvore a ser enviada.
local function sendToAPI(treeData)
    local jsonPayload
    local success, err = pcall(function()
        jsonPayload = HttpService:JSONEncode({ content = treeData })
    end)

    if not success then
        warn("Erro ao codificar JSON: " .. tostring(err))
        return
    end

    local headers = {
        ["Content-Type"] = "application/json",
        ["ngrok-skip-browser-warning"] = "true" -- Necessário para ngrok
    }

    local responseSuccess, responseResult = pcall(function()
        return HttpService:PostAsync(API_URL, jsonPayload, Enum.HttpContentType.ApplicationJson, false, headers)
    end)

    if responseSuccess then
        print("Árvore enviada para o servidor com sucesso!")
        -- Opcional: print(responseResult) para ver a resposta do servidor
    else
        warn("Erro ao enviar para a API: " .. tostring(responseResult))
    end
end

-- ============================================================================
-- INÍCIO DA EXECUÇÃO
-- ============================================================================
if LocalPlayer then
    print("Iniciando varredura da PlayerGui de " .. LocalPlayer.Name .. "...")

    local tree = {}

    -- Itera sobre as ScreenGuis do jogador
    for _, screenGui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") then
            table.insert(tree, buildTree(screenGui))
        end
    end

    -- Envia a árvore construída para a API
    sendToAPI(tree)

    print("Varredura concluída. Verifique seu site.")
else
    warn("Jogador local não encontrado. Certifique-se de que o script está sendo executado no cliente.")
end
