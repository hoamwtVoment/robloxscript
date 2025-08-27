-- 配置设置
local killerFolder = "Players.Killers"  -- 杀手文件夹路径
local speedMultipliersFolder = "SpeedMultipliers"  -- 速度倍率文件夹名称
local valueConfigs = {
    {name = "ENRAGED", value = 2.166},
    {name = "Pacified", value = 1}
}

-- 为单个杀手角色确保值存在
local function ensureValuesForKiller(killer)
    -- 查找或创建SpeedMultipliers文件夹
    local speedMultipliers = killer:FindFirstChild(speedMultipliersFolder)
    if not speedMultipliers then
        speedMultipliers = Instance.new("Folder")
        speedMultipliers.Name = speedMultipliersFolder
        speedMultipliers.Parent = killer
        print("为 "..killer.Name.." 创建速度倍率文件夹")
    end
    
    -- 确保所有值正确
    for _, config in ipairs(valueConfigs) do
        local valueName = config.name
        local targetValue = config.value
        
        local valueObj = speedMultipliers:FindFirstChild(valueName)
        
        -- 创建值（如果不存在）
        if not valueObj then
            valueObj = Instance.new("NumberValue")
            valueObj.Name = valueName
            valueObj.Value = targetValue
            valueObj.Parent = speedMultipliers
            print("为 "..killer.Name.." 创建值: "..valueName.." = "..targetValue)
        end
        
        -- 确保值类型正确
        if valueObj and not valueObj:IsA("NumberValue") then
            valueObj:Destroy()
            valueObj = nil
            warn("删除 "..killer.Name.." 的非NumberValue对象: "..valueName)
        end
        
        -- 确保值正确
        if valueObj and valueObj.Value ~= targetValue then
            valueObj.Value = targetValue
            print("修正 "..killer.Name.." 的值: "..valueName.." = "..targetValue)
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
                    print("阻止修改 "..killer.Name.." 的值: "..valueName.." 已重置为 "..targetValue)
                end
            end)
        end
    end
end

-- 创建循环任务确保所有杀手角色的值存在
local function ensureAllValues()
    while true do
        -- 查找杀手文件夹
        local killersFolder = workspace
        for _, part in ipairs(killerFolder:split(".")) do
            killersFolder = killersFolder:FindFirstChild(part)
            if not killersFolder then break end
        end
        
        -- 如果找到杀手文件夹，处理所有杀手角色
        if killersFolder then
            for _, killer in ipairs(killersFolder:GetChildren()) do
                if killer:IsA("Model") then
                    ensureValuesForKiller(killer)
                end
            end
        else
            print("杀手文件夹不存在: "..killerFolder.." - 等待后重试...")
        end
        
        task.wait(1)  -- 每秒检查一次
    end
end

-- 启动任务
task.spawn(ensureAllValues)
print("值守护任务已启动...")
print("监控以下值:")
for _, config in ipairs(valueConfigs) do
    print(" - "..config.name.." = "..config.value)
end
print("应用于所有杀手角色")