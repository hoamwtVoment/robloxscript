local function createESP(character, color, name)
    -- 创建高亮效果
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.OutlineColor = color
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.2  -- 20%透明度 = 80%可见度
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    -- 创建名称标签
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag"
    billboard.Adornee = character:WaitForChild("Head", 5) or character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = name
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color  -- 关键修改：使用ESP颜色
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    billboard.Parent = character
    
    return {highlight, billboard}
end

-- 监听玩家目录
local function setupESP()
    local killersFolder = workspace:FindFirstChild("Players"):FindFirstChild("Killers")
    local survivorsFolder = workspace:FindFirstChild("Players"):FindFirstChild("Survivors")
    
    if killersFolder then
        killersFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") and child:FindFirstChild("Humanoid") then
                createESP(child, Color3.new(1, 0, 0), child.Name)  -- 红色
            end
        end)
    end
    
    if survivorsFolder then
        survivorsFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") and child:FindFirstChild("Humanoid") then
                createESP(child, Color3.new(0, 1, 0), child.Name)  -- 绿色
            end
        end)
    end
    
    -- 初始处理现有角色
    for _, folder in pairs({killersFolder, survivorsFolder}) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChild("Humanoid") then
                    local color = folder == killersFolder and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                    createESP(child, color, child.Name)
                end
            end
        end
    end
end

setupESP()