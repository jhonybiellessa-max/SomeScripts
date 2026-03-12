--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local debrisFolder = workspace:WaitForChild("DebrisClient")

local farming = false
local running = true

-- Configurações da GUI
local GUI_SETTINGS = {
    MAIN_FRAME_SIZE = UDim2.new(0, 250, 0, 200),
    MAIN_FRAME_POSITION = UDim2.new(0.5, -125, 0.5, -100), -- Centralizado
    MAIN_FRAME_COLOR = Color3.fromRGB(40, 40, 40),
    BUTTON_SIZE = UDim2.new(1, -20, 0, 45),
    BUTTON_OFFSET_Y = 55,
    BUTTON_TEXT_COLOR = Color3.new(1, 1, 1),
    TOGGLE_ON_COLOR = Color3.fromRGB(0, 170, 0),
    TOGGLE_OFF_COLOR = Color3.fromRGB(170, 0, 0),
    HIDE_BUTTON_COLOR = Color3.fromRGB(70, 70, 70),
    DESTROY_BUTTON_COLOR = Color3.fromRGB(170, 0, 0),
    CORNER_RADIUS = UDim.new(0, 8), -- Cantos arredondados
    OPEN_BUTTON_SIZE = UDim2.new(0, 150, 0, 40),
    OPEN_BUTTON_POSITION = UDim2.new(1, -160, 0, 10), -- Canto superior direito
    OPEN_BUTTON_COLOR = Color3.fromRGB(50, 50, 50),
}

-- Função para criar botões padronizados
local function createButton(parent, text, position, backgroundColor, size)
    local button = Instance.new("TextButton")
    button.Size = size or GUI_SETTINGS.BUTTON_SIZE
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = backgroundColor
    button.TextColor3 = GUI_SETTINGS.BUTTON_TEXT_COLOR
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Parent = parent

    Instance.new("UICorner", button).CornerRadius = GUI_SETTINGS.CORNER_RADIUS
    Instance.new("UIPadding", button).PaddingBottom = UDim.new(0, 5)
    Instance.new("UIPadding", button).PaddingTop = UDim.new(0, 5)
    Instance.new("UIPadding", button).PaddingLeft = UDim.new(0, 10)
    Instance.new("UIPadding", button).PaddingRight = UDim.new(0, 10)

    return button
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PickupFarmUI_Improved"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") -- Melhor prática para GUIs de jogador

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = GUI_SETTINGS.MAIN_FRAME_SIZE
frame.Position = GUI_SETTINGS.MAIN_FRAME_POSITION
frame.BackgroundColor3 = GUI_SETTINGS.MAIN_FRAME_COLOR
frame.BorderColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = GUI_SETTINGS.CORNER_RADIUS

-- Adiciona um título ao frame
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = "Pickup Farm"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Parent = frame

Instance.new("UICorner", titleLabel).CornerRadius = GUI_SETTINGS.CORNER_RADIUS

-- Drag Detector para o frame
local drag = Instance.new("UIDragDetector")
drag.Parent = frame

-- Layout para os botões
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = frame

-- Adiciona um padding para o conteúdo do frame
local framePadding = Instance.new("UIPadding")
framePadding.PaddingTop = UDim.new(0, 40) -- Espaço para o título
framePadding.PaddingBottom = UDim.new(0, 10)
framePadding.PaddingLeft = UDim.new(0, 10)
framePadding.PaddingRight = UDim.new(0, 10)
framePadding.Parent = frame

-- Toggle Farm
local toggleButton = createButton(frame, "Farm: OFF", UDim2.new(0, 10, 0, 40), GUI_SETTINGS.TOGGLE_OFF_COLOR)

-- Ocultar UI
local hideButton = createButton(frame, "Ocultar UI", UDim2.new(0, 10, 0, 40 + GUI_SETTINGS.BUTTON_OFFSET_Y), GUI_SETTINGS.HIDE_BUTTON_COLOR)

-- Botão Destroy
local destroyButton = createButton(frame, "Destroy Script", UDim2.new(0, 10, 0, 40 + (GUI_SETTINGS.BUTTON_OFFSET_Y * 2)), GUI_SETTINGS.DESTROY_BUTTON_COLOR)

-- Botão abrir UI (pequeno e no canto)
local openButton = createButton(gui, "Abrir Farm UI", GUI_SETTINGS.OPEN_BUTTON_POSITION, GUI_SETTINGS.OPEN_BUTTON_COLOR, GUI_SETTINGS.OPEN_BUTTON_SIZE)
openButton.Visible = false

-- Função para puxar pickup
local function bringPickup(model)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart

    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local tween = TweenService:Create(
        part,
        TweenInfo.new(0.25, Enum.EasingStyle.Linear),
        {CFrame = root.CFrame}
    )

    tween:Play()
end

-- Loop Farm
local farmLoopConnection
local function startFarmLoop()
    if farmLoopConnection then return end -- Já está rodando
    farmLoopConnection = RunService.Heartbeat:Connect(function()
        if farming then
            for _, obj in pairs(debrisFolder:GetChildren()) do
                if obj:IsA("Model") and string.find(obj.Name, "Pickup") then
                    bringPickup(obj)
                end
            end
        end
    end)
end

local function stopFarmLoop()
    if farmLoopConnection then
        farmLoopConnection:Disconnect()
        farmLoopConnection = nil
    end
end

-- Eventos da GUI
toggleButton.MouseButton1Click:Connect(function()
    farming = not farming

    if farming then
        toggleButton.Text = "Farm: ON"
        toggleButton.BackgroundColor3 = GUI_SETTINGS.TOGGLE_ON_COLOR
        startFarmLoop()
    else
        toggleButton.Text = "Farm: OFF"
        toggleButton.BackgroundColor3 = GUI_SETTINGS.TOGGLE_OFF_COLOR
        stopFarmLoop()
    end
end)

hideButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    openButton.Visible = false
end)

destroyButton.MouseButton1Click:Connect(function()
    farming = false
    running = false -- Para o loop principal, se houver outros
    stopFarmLoop()
    gui:Destroy()
end)

-- Atualizar personagem
player.CharacterAdded:Connect(function(char)
    character = char
end)

-- Iniciar o loop de farm se já estiver ativo (caso o script seja injetado com farming = true)
if farming then
    startFarmLoop()
end

-- Centralizar o frame quando a tela for redimensionada (opcional, mas bom para responsividade)
local function centerFrame()
    frame.Position = UDim2.new(0.5, -frame.AbsoluteSize.X / 2, 0.5, -frame.AbsoluteSize.Y / 2)
end

frame.Changed:Connect(function(property)
    if property == "AbsoluteSize" then
        centerFrame()
    end
end)

centerFrame() -- Centraliza inicialmente

-- Adiciona um efeito de hover aos botões
local function setupHoverEffect(button, originalColor, hoverColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

setupHoverEffect(toggleButton, GUI_SETTINGS.TOGGLE_OFF_COLOR, Color3.fromRGB(200, 0, 0)) -- Cor inicial será ajustada pelo estado
setupHoverEffect(hideButton, GUI_SETTINGS.HIDE_BUTTON_COLOR, Color3.fromRGB(100, 100, 100))
setupHoverEffect(destroyButton, GUI_SETTINGS.DESTROY_BUTTON_COLOR, Color3.fromRGB(200, 0, 0))
setupHoverEffect(openButton, GUI_SETTINGS.OPEN_BUTTON_COLOR, Color3.fromRGB(80, 80, 80))

-- Ajusta a cor inicial do toggleButton
if farming then
    toggleButton.BackgroundColor3 = GUI_SETTINGS.TOGGLE_ON_COLOR
else
    toggleButton.BackgroundColor3 = GUI_SETTINGS.TOGGLE_OFF_COLOR
end
