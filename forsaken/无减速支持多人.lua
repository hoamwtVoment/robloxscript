-- 配置设置
local killerFolder = "Players.Killers"  -- 杀手文件夹路径
local targetNames = {"SlowedStatus", "BeheadAbility", "HitRegistered"}  -- 要删除的对象名称
local killerNames = {"Jason"}  -- 要处理的杀手角色名称列表

-- 递归删除函数
local function recursiveDelete(parent)
    for _, child in ipairs(parent:GetChildren()) do
        -- 检查是否为目标对象
        if table.find(targetNames, child.Name) then
            child:Destroy()
            print("已删除: "..child:GetFullName())
        end
        
        -- 递归检查子对象
        recursiveDelete(child)
    end
end

-- 为单个杀手角色执行删除
local function deleteForKiller(killer)
    -- 主删除操作
    recursiveDelete(killer)
    
    -- 添加监听防止对象重新创建
    for _, name in ipairs(targetNames) do
        killer.DescendantAdded:Connect(function(descendant)
            if descendant.Name == name then
                task.wait(0)  -- 等待对象初始化
                descendant:Destroy()
                print("动态删除 "..killer.Name.." 的对象: "..descendant:GetFullName())
            end
        end)
    end
end

-- 主执行逻辑
local function main()
    -- 查找杀手文件夹
    local killersFolder = workspace
    for _, part in ipairs(killerFolder:split(".")) do
        killersFolder = killersFolder:FindFirstChild(part)
        if not killersFolder then
            warn("杀手文件夹不存在: "..killerFolder)
            return
        end
    end
    
    print("开始删除操作...")
    
    -- 处理所有符合条件的杀手角色
    for _, killerName in ipairs(killerNames) do
        local killer = killersFolder:FindFirstChild(killerName)
        if killer then
            print("处理杀手角色: "..killerName)
            deleteForKiller(killer)
        else
            warn("未找到杀手角色: "..killerName)
        end
    end
    
    print("删除完成!")
    
    -- 添加监听处理新创建的杀手角色
    killersFolder.ChildAdded:Connect(function(newKiller)
        if newKiller:IsA("Model") and table.find(killerNames, newKiller.Name) then
            task.wait(0.5)  -- 等待角色初始化
            print("处理新添加的杀手角色: "..newKiller.Name)
            deleteForKiller(newKiller)
        end
    end)
end

-- 启动任务
main()