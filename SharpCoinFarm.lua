local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local debrisFolder = workspace:WaitForChild("DebrisClient")

local farming = false
local running = true

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PickupFarmUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,180)
frame.Position = UDim2.new(0.4,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,8)

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

Instance.new("UICorner",titleBar).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Pickup Farm"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Drag apenas na barra
local drag = Instance.new("UIDragDetector")
drag.Parent = titleBar

-- Container botões
local container = Instance.new("Frame")
container.Size = UDim2.new(1,-20,1,-40)
container.Position = UDim2.new(0,10,0,35)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,8)
layout.Parent = container

-- Botão farm
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1,0,0,40)
toggle.Text = "Farm OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.BackgroundColor3 = Color3.fromRGB(170,50,50)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Parent = container
Instance.new("UICorner",toggle)

-- Botão ocultar
local hide = Instance.new("TextButton")
hide.Size = UDim2.new(1,0,0,40)
hide.Text = "Ocultar UI"
hide.Font = Enum.Font.GothamBold
hide.TextSize = 14
hide.BackgroundColor3 = Color3.fromRGB(60,60,60)
hide.TextColor3 = Color3.new(1,1,1)
hide.Parent = container
Instance.new("UICorner",hide)

-- Botão destruir
local destroy = Instance.new("TextButton")
destroy.Size = UDim2.new(1,0,0,40)
destroy.Text = "Destroy Script"
destroy.Font = Enum.Font.GothamBold
destroy.TextSize = 14
destroy.BackgroundColor3 = Color3.fromRGB(200,60,60)
destroy.TextColor3 = Color3.new(1,1,1)
destroy.Parent = container
Instance.new("UICorner",destroy)

-- Botão abrir UI
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0,120,0,35)
openButton.Position = UDim2.new(0,10,0,10)
openButton.Text = "Abrir Farm UI"
openButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Visible = false
openButton.Parent = gui
Instance.new("UICorner",openButton)

-- Função puxar pickup
local function bringPickup(model)

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    part.CanCollide = false

    local tween = TweenService:Create(
        part,
        TweenInfo.new(0.15,Enum.EasingStyle.Linear),
        {CFrame = root.CFrame}
    )

    tween:Play()

end

-- Loop farm
task.spawn(function()

    while running do
        
        if farming then
            
            for _,obj in pairs(debrisFolder:GetChildren()) do
                
                if obj:IsA("Model") and string.find(obj.Name,"Pickup") then
                    bringPickup(obj)
                end
                
            end
            
        end
        
        task.wait(0.1)
        
    end

end)

-- Toggle farm
toggle.MouseButton1Click:Connect(function()

    farming = not farming

    if farming then
        toggle.Text = "Farm ON"
        toggle.BackgroundColor3 = Color3.fromRGB(60,170,60)
    else
        toggle.Text = "Farm OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,50,50)
    end

end)

-- Ocultar
hide.MouseButton1Click:Connect(function()
    frame.Visible = false
    openButton.Visible = true
end)

-- Mostrar
openButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    openButton.Visible = false
end)

-- Destroy
destroy.MouseButton1Click:Connect(function()

    farming = false
    running = false
    
    gui:Destroy()

end)

-- Atualizar personagem
player.CharacterAdded:Connect(function(char)
    character = char
end)
