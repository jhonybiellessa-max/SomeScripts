-- LocalScript para Roblox (v2 com Auto-Rebirth)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações Iniciais
local farmActive = false
local rebirthActive = false
local farmValue = 1
local isMinimized = false

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGui_Manus_v2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 310) -- Aumentado para caber o novo botão
mainFrame.Position = UDim2.new(0.85, 0, 0.6, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Arredondar cantos
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Título / Barra de Arrastar
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.Text = " Manus Farm UI v2 "
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = titleLabel

-- Botão Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = mainFrame

-- Container de Conteúdo (para esconder ao minimizar)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentFrame

-- Botão Farm ON/OFF
local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(0, 160, 0, 35)
farmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
farmBtn.Text = "Farm: OFF"
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.Font = Enum.Font.GothamBold
farmBtn.TextSize = 14
farmBtn.Parent = contentFrame

local farmCorner = Instance.new("UICorner")
farmCorner.Parent = farmBtn

-- Botão Auto-Rebirth
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Size = UDim2.new(0, 160, 0, 35)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
rebirthBtn.Text = "Auto-Rebirth: OFF"
rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.TextSize = 14
rebirthBtn.Parent = contentFrame

local rebirthCorner = Instance.new("UICorner")
rebirthCorner.Parent = rebirthBtn

-- Label de Instrução
local labelInfo = Instance.new("TextLabel")
labelInfo.Size = UDim2.new(0, 160, 0, 20)
labelInfo.BackgroundTransparency = 1
labelInfo.Text = "Quantidade do Farm:"
labelInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
labelInfo.Font = Enum.Font.Gotham
labelInfo.TextSize = 12
labelInfo.Parent = contentFrame

-- TextBox para o Número
local numberInput = Instance.new("TextBox")
numberInput.Size = UDim2.new(0, 160, 0, 35)
numberInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
numberInput.Text = "1"
numberInput.PlaceholderText = "Digite o número..."
numberInput.TextColor3 = Color3.fromRGB(255, 255, 255)
numberInput.Font = Enum.Font.Gotham
numberInput.TextSize = 14
numberInput.Parent = contentFrame

local inputCorner = Instance.new("UICorner")
inputCorner.Parent = numberInput

-- Botão Destruir
local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(0, 160, 0, 35)
destroyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
destroyBtn.Text = "Destruir UI"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.TextSize = 14
destroyBtn.Parent = contentFrame

local destroyCorner = Instance.new("UICorner")
destroyCorner.Parent = destroyBtn

-- Lógica de Arrastar (Drag)
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Lógica do Farm
farmBtn.MouseButton1Click:Connect(function()
	farmActive = not farmActive
	if farmActive then
		farmBtn.Text = "Farm: ON"
		farmBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		farmBtn.Text = "Farm: OFF"
		farmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

-- Lógica do Auto-Rebirth
rebirthBtn.MouseButton1Click:Connect(function()
	rebirthActive = not rebirthActive
	if rebirthActive then
		rebirthBtn.Text = "Auto-Rebirth: ON"
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		rebirthBtn.Text = "Auto-Rebirth: OFF"
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

-- Atualizar número em tempo real
numberInput:GetPropertyChangedSignal("Text"):Connect(function()
	local val = tonumber(numberInput.Text)
	if val then
		farmValue = val
	end
end)

-- Loop Principal (Executa RemoteEvents)
task.spawn(function()
	while true do
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			-- Executar Farm se ativo
			if farmActive then
				local stepTaken = remotes:FindFirstChild("StepTaken")
				if stepTaken then
					stepTaken:FireServer(farmValue, false)
				end
			end
			
			-- Executar Rebirth se ativo
			if rebirthActive then
				local requestRebirth = remotes:FindFirstChild("RequestRebirth")
				if requestRebirth then
					requestRebirth:FireServer("free")
				end
			end
		end
		task.wait(0.1) -- Delay de 0.1s para evitar lag
	end
end)

-- Lógica de Minimizar
minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		contentFrame.Visible = false
		mainFrame:TweenSize(UDim2.new(0, 200, 0, 30), "Out", "Quad", 0.3, true)
		minBtn.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 200, 0, 310), "Out", "Quad", 0.3, true, function()
			contentFrame.Visible = true
		end)
		minBtn.Text = "-"
	end
end)

-- Lógica de Destruir
destroyBtn.MouseButton1Click:Connect(function()
	farmActive = false
	rebirthActive = false
	screenGui:Destroy()
end)
