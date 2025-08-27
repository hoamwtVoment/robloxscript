-- 目标路径和值设置
local targetPath = "Players.Killers.Jason.SpeedMultipliers"
local valueConfigs = {
    {name = "ENRAGED", value = 2.166},
    {name = "Pacified", value = 1}
}

-- 创建循环任务确保值存在
local function ensureValues()
    while true do
        -- 查找目标路径
        local current = workspace
        local pathParts = {}
        
        -- 分割路径
        for part in targetPath:gmatch("[^%.]+") do
            table.insert(pathParts, part)
        end
        
        -- 逐级查找路径
        local foundPath = true
        for i, part in ipairs(pathParts) do
            current = current:FindFirstChild(part)
            if not current then
                foundPath = false
                break
            end
        end
        
        -- 如果路径存在，确保所有值正确
        if foundPath then
            for _, config in ipairs(valueConfigs) do
                local valueName = config.name
                local targetValue = config.value
                
                local valueObj = current:FindFirstChild(valueName)
                
                -- 创建值（如果不存在）
                if not valueObj then
                    valueObj = Instance.new("NumberValue")
                    valueObj.Name = valueName
                    valueObj.Value = targetValue
                    valueObj.Parent = current
                    print("已创建值: "..valueObj:GetFullName().." = "..targetValue)
                end
                
                -- 确保值类型正确
                if valueObj and not valueObj:IsA("NumberValue") then
                    valueObj:Destroy()
                    valueObj = nil
                    warn("删除非NumberValue对象: "..valueName)
                end
                
                -- 确保值正确
                if valueObj and valueObj.Value ~= targetValue then
                    valueObj.Value = targetValue
                    print("已修正值: "..valueObj:GetFullName().." = "..targetValue)
                end
                
                -- 添加值修改监听器
                if valueObj and not valueObj:FindFirstChild("ValueGuard") then
                    local bindable = Instance.new("BindableEvent")
                    bindable.Name = "ValueGuard"
                    bindable.Parent = valueObj
                    
                    valueObj.Changed:Connect(function(newValue)
                        if newValue ~= targetValue then
                            task.wait(0.1)  -- 避免递归
                            valueObj.Value = targetValue
                            print("阻止修改: "..valueObj:GetFullName().." 已重置为 "..targetValue)
                        end
                    end)
                end
            end
        else
            print("路径不存在: "..targetPath.." - 等待后重试...")
        end
        
        task.wait(0.01)  -- 每秒检查一次
    end
end

-- 启动任务
task.spawn(ensureValues)
print("值守护任务已启动...")
print("监控以下值:")
for _, config in ipairs(valueConfigs) do
    print(" - "..config.name.." = "..config.value)
end