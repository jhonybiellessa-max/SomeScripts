-- LocalScript para a GUI de automação

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Espera pelos RemoteEvents
local SharedCore = ReplicatedStorage:WaitForChild("SharedCore")
local Events = SharedCore:WaitForChild("Events")

local PunchEvent = Events:WaitForChild("Punch")
local WorkoutRepEvent = Events:WaitForChild("WorkoutRep")

-- Variáveis de controle para as automações
local autoPunchEnabled = false
local autoTrainEnabled = false
local currentTrainType = "Body" -- Padrão inicial

-- Criação da GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutomationGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250) -- Tamanho inicial maximizado
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125) -- Centraliza na tela
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Título e botões de controle (fechar/minimizar) ficarão em um TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0) -- Ajusta para botões de controle
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Automation Control"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = TitleBar

-- Botão Fechar UI
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Vermelho
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    autoPunchEnabled = false -- Para automações ativas
    autoTrainEnabled = false
    ScreenGui:Destroy() -- Remove a GUI
end)

-- Botão Minimizar/Maximizar UI
local MinimizeMaximizeButton = Instance.new("TextButton")
MinimizeMaximizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeMaximizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeMaximizeButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200) -- Azul
MinimizeMaximizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeMaximizeButton.Text = "-"
MinimizeMaximizeButton.Font = Enum.Font.SourceSansBold
MinimizeMaximizeButton.TextSize = 18
MinimizeMaximizeButton.Parent = TitleBar

local isMinimized = false
local originalSize = MainFrame.Size
local minimizedSize = UDim2.new(0, 200, 0, 30) -- Apenas o TitleBar

MinimizeMaximizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = minimizedSize
        ContentFrame.Visible = false
        MinimizeMaximizeButton.Text = "+"
    else
        MainFrame.Size = originalSize
        ContentFrame.Visible = true
        MinimizeMaximizeButton.Text = "-"
    end
end)

-- ContentFrame para agrupar os botões de automação e seleção de treino
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30) -- Ocupa o restante do MainFrame abaixo do TitleBar
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Botão Auto-Punch
local AutoPunchButton = Instance.new("TextButton")
AutoPunchButton.Size = UDim2.new(0.8, 0, 0, 40)
AutoPunchButton.Position = UDim2.new(0.1, 0, 0.05, 0) -- Ajusta posição dentro do ContentFrame
AutoPunchButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
AutoPunchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPunchButton.Text = "Auto-Punch: OFF"
AutoPunchButton.Font = Enum.Font.SourceSansSemibold
AutoPunchButton.TextSize = 16
AutoPunchButton.Parent = ContentFrame

AutoPunchButton.MouseButton1Click:Connect(function()
    autoPunchEnabled = not autoPunchEnabled
    if autoPunchEnabled then
        AutoPunchButton.Text = "Auto-Punch: ON"
        AutoPunchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Verde
        while autoPunchEnabled do
            pcall(function()
                PunchEvent:FireServer(false)
            end)
            task.wait(0.5) -- Intervalo entre os "socos"
        end
    else
        AutoPunchButton.Text = "Auto-Punch: OFF"
        AutoPunchButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Cinza
    end
end)

-- Label para o tipo de treino
local TrainTypeLabel = Instance.new("TextLabel")
TrainTypeLabel.Size = UDim2.new(0.8, 0, 0, 20)
TrainTypeLabel.Position = UDim2.new(0.1, 0, 0.3, 0)
TrainTypeLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TrainTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TrainTypeLabel.Text = "Train Type: Body"
TrainTypeLabel.Font = Enum.Font.SourceSansSemibold
TrainTypeLabel.TextSize = 14
TrainTypeLabel.Parent = ContentFrame

-- Botões de seleção de tipo de treino
local BodyButton = Instance.new("TextButton")
BodyButton.Size = UDim2.new(0.25, 0, 0, 25)
BodyButton.Position = UDim2.new(0.1, 0, 0.45, 0)
BodyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Verde para selecionado
BodyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BodyButton.Text = "Body"
BodyButton.Font = Enum.Font.SourceSansSemibold
BodyButton.TextSize = 14
BodyButton.Parent = ContentFrame

local ArmsButton = Instance.new("TextButton")
ArmsButton.Size = UDim2.new(0.25, 0, 0, 25)
ArmsButton.Position = UDim2.new(0.4, 0, 0.45, 0)
ArmsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ArmsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ArmsButton.Text = "Arms"
ArmsButton.Font = Enum.Font.SourceSansSemibold
ArmsButton.TextSize = 14
ArmsButton.Parent = ContentFrame

local LegsButton = Instance.new("TextButton")
LegsButton.Size = UDim2.new(0.25, 0, 0, 25)
LegsButton.Position = UDim2.new(0.7, 0, 0.45, 0)
LegsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
LegsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LegsButton.Text = "Legs"
LegsButton.Font = Enum.Font.SourceSansSemibold
LegsButton.TextSize = 14
LegsButton.Parent = ContentFrame

local function updateTrainType(newType)
    currentTrainType = newType
    TrainTypeLabel.Text = "Train Type: " .. newType
    -- Resetar cores dos botões
    BodyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ArmsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    LegsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    -- Definir cor do botão selecionado
    if newType == "Body" then
        BodyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    elseif newType == "Arms" then
        ArmsButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    elseif newType == "Legs" then
        LegsButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end

BodyButton.MouseButton1Click:Connect(function() updateTrainType("Body") end)
ArmsButton.MouseButton1Click:Connect(function() updateTrainType("Arms") end)
LegsButton.MouseButton1Click:Connect(function() updateTrainType("Legs") end)

-- Botão Auto-Train
local AutoTrainButton = Instance.new("TextButton")
AutoTrainButton.Size = UDim2.new(0.8, 0, 0, 40)
AutoTrainButton.Position = UDim2.new(0.1, 0, 0.65, 0) -- Ajusta posição dentro do ContentFrame
AutoTrainButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
AutoTrainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoTrainButton.Text = "Auto-Train: OFF"
AutoTrainButton.Font = Enum.Font.SourceSansSemibold
AutoTrainButton.TextSize = 16
AutoTrainButton.Parent = ContentFrame

AutoTrainButton.MouseButton1Click:Connect(function()
    autoTrainEnabled = not autoTrainEnabled
    if autoTrainEnabled then
        AutoTrainButton.Text = "Auto-Train: ON"
        AutoTrainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Verde
        while autoTrainEnabled do
            pcall(function()
                local equipmentObject
                if currentTrainType == "Body" then
                    equipmentObject = workspace:WaitForChild("Map", 10):WaitForChild("Equipment", 10):WaitForChild("BenchPress", 10):WaitForChild("BenchPress", 10)
                elseif currentTrainType == "Arms" then
                    equipmentObject = workspace:WaitForChild("Map", 10):WaitForChild("Equipment", 10):WaitForChild("Curls", 10):WaitForChild("Curls", 10)
                elseif currentTrainType == "Legs" then
                    equipmentObject = workspace:WaitForChild("Map", 10):WaitForChild("Equipment", 10):WaitForChild("Squat", 10):WaitForChild("Squat", 10)
                end

                if equipmentObject then
                    WorkoutRepEvent:FireServer(equipmentObject)
                else
                    warn("Equipment object not found for " .. currentTrainType .. ". Is the player in the correct training area?")
                end
            end)
            task.wait(1) -- Intervalo entre as "repetições"
        end
    else
        AutoTrainButton.Text = "Auto-Train: OFF"
        AutoTrainButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Cinza
    end
end)

-- Função para arrastar a GUI (agora conectada ao TitleBar)
local dragging
local dragInput
local dragStart
local startPosition

local function onMouseMoved(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
end

local function onMouseUp(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragInput = nil
        -- Desconecta o evento MouseMoved
        if TitleBar.MouseMoved:find(onMouseMoved) then
            TitleBar.MouseMoved:Disconnect()
        end
    end
end

local function onMouseDown(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragInput = input
        dragStart = input.Position
        startPosition = MainFrame.Position
        -- Conecta o evento MouseMoved
        TitleBar.MouseMoved:Connect(onMouseMoved)
    end
end

TitleBar.InputBegan:Connect(onMouseDown)
TitleBar.InputEnded:Connect(onMouseUp)

print("Automation GUI Loaded!")
