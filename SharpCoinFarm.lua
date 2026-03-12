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
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,160)
frame.Position = UDim2.new(0.4,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

Instance.new("UICorner", frame)

local drag = Instance.new("UIDragDetector")
drag.Parent = frame

-- Toggle Farm
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1,-20,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "Farm: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Parent = frame

-- Ocultar UI
local hide = Instance.new("TextButton")
hide.Size = UDim2.new(1,-20,0,40)
hide.Position = UDim2.new(0,10,0,60)
hide.Text = "Ocultar UI"
hide.BackgroundColor3 = Color3.fromRGB(70,70,70)
hide.TextColor3 = Color3.new(1,1,1)
hide.Parent = frame

-- Botão Destroy
local destroy = Instance.new("TextButton")
destroy.Size = UDim2.new(1,-20,0,40)
destroy.Position = UDim2.new(0,10,0,110)
destroy.Text = "Destroy Script"
destroy.BackgroundColor3 = Color3.fromRGB(170,0,0)
destroy.TextColor3 = Color3.new(1,1,1)
destroy.Parent = frame

-- Botão abrir UI
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0,120,0,40)
openButton.Position = UDim2.new(0,10,0,10)
openButton.Text = "Abrir Farm UI"
openButton.Visible = false
openButton.Parent = gui

-- Função puxar pickup
local function bringPickup(model)

    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

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
task.spawn(function()

    while running do
        
        if farming then
            
            for _,obj in pairs(debrisFolder:GetChildren()) do
                
                if obj:IsA("Model") and string.find(obj.Name,"Pickup") then
                    bringPickup(obj)
                end
                
            end
            
        end
        
        task.wait(0.2)
        
    end

end)

-- Toggle Farm
toggle.MouseButton1Click:Connect(function()

    farming = not farming

    if farming then
        toggle.Text = "Farm: ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggle.Text = "Farm: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end

end)

-- Ocultar UI
hide.MouseButton1Click:Connect(function()
    frame.Visible = false
    openButton.Visible = true
end)

-- Mostrar UI
openButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    openButton.Visible = false
end)

-- Destroy Script
destroy.MouseButton1Click:Connect(function()

    farming = false
    running = false
    
    gui:Destroy()

end)

-- Atualizar personagem
player.CharacterAdded:Connect(function(char)
    character = char
end)
