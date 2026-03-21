--[[
    SmashX UI v2 - Script Local Luau
    Funcionalidades: Drag System (Main & Toggle), Minimizar/Fechar, Toggle Button (ID 11517872858), 
    Setagem de Dinheiro Customizada, Pet de Robux, Auto Treino.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Configurações de Cores e Estilo
local COLORS = {
    Background = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(40, 40, 40),
    Button = Color3.fromRGB(50, 50, 50),
    ButtonHover = Color3.fromRGB(70, 70, 70)
}

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmashX_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = COLORS.Accent
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Top Bar (Drag Area)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = COLORS.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SmashX"
Title.TextColor3 = COLORS.Accent
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Botões de Controle (Fechar/Minimizar)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = COLORS.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = COLORS.Button
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = COLORS.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinimizeBtn

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = Content

-- Função para criar botões bonitos
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = COLORS.Button
    btn.Text = text
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Button}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Seção de Dinheiro
local MoneyFrame = Instance.new("Frame")
MoneyFrame.Size = UDim2.new(0.9, 0, 0, 80)
MoneyFrame.BackgroundTransparency = 1
MoneyFrame.Parent = Content

local MoneyInput = Instance.new("TextBox")
MoneyInput.Size = UDim2.new(1, 0, 0, 35)
MoneyInput.BackgroundColor3 = COLORS.Secondary
MoneyInput.PlaceholderText = "Digite a quantia de dinheiro..."
MoneyInput.Text = "6099999999999"
MoneyInput.TextColor3 = COLORS.Text
MoneyInput.Font = Enum.Font.Gotham
MoneyInput.TextSize = 14
MoneyInput.Parent = MoneyFrame

local MoneyInputCorner = Instance.new("UICorner")
MoneyInputCorner.CornerRadius = UDim.new(0, 6)
MoneyInputCorner.Parent = MoneyInput

local MoneyBtn = Instance.new("TextButton")
MoneyBtn.Size = UDim2.new(1, 0, 0, 35)
MoneyBtn.Position = UDim2.new(0, 0, 0, 40)
MoneyBtn.BackgroundColor3 = COLORS.Accent
MoneyBtn.Text = "Executar Setagem de Dinheiro"
MoneyBtn.TextColor3 = COLORS.Text
MoneyBtn.Font = Enum.Font.GothamBold
MoneyBtn.Parent = MoneyFrame

local MoneyBtnCorner = Instance.new("UICorner")
MoneyBtnCorner.CornerRadius = UDim.new(0, 6)
MoneyBtnCorner.Parent = MoneyBtn

-- Funcionalidade de Dinheiro
MoneyBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(MoneyInput.Text) or 6099999999999
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local args = {
            amount,
            amount,
            false,
            hrp.Position,
            0
        }
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StompDamage")
        remote:FireServer(unpack(args))
    end
end)

-- Botão Pet de Robux
createButton("Chocar Pet de Robux", function()
    local HatchEgg = ReplicatedStorage.Remotes.HatchEgg
    local Egg = workspace.Eggs.OPEGG.EggModel.Egg
    local RemoteArgs = {
        Egg,
        true,
        "Please purchase from the shop!"
    }
    HatchEgg:FireServer(unpack(RemoteArgs))
end)

-- Botões de Treino
createButton("Iniciar Auto Treino", function()
    ReplicatedStorage:WaitForChild("TrainingRemotes"):WaitForChild("StartTraining"):FireServer()
end)

createButton("Parar Auto Treino", function()
    ReplicatedStorage:WaitForChild("TrainingRemotes"):WaitForChild("EndTraining"):FireServer()
end)

-- Botão Flutuante (Toggle Button)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = COLORS.Background
ToggleButton.Image = "rbxassetid://11517872858"
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = COLORS.Accent
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Função de Drag Genérica
local function makeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea = dragArea or frame

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Aplicar Drag na MainFrame e no ToggleButton
makeDraggable(MainFrame, TopBar)
makeDraggable(ToggleButton)

-- Funcionalidade de Ocultar/Mostrar
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Minimizar/Maximizar
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 40), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 300), "Out", "Quad", 0.3, true, function()
            Content.Visible = true
        end)
        MinimizeBtn.Text = "-"
    end
end)

-- Fechar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("SmashX UI v2 Carregada com Sucesso!")
