-- 要删除的对象名称列表
local targetNames = {"SlowedStatus", "BeheadAbility", "HitRegistered"}

-- 起始路径
local startPath = "Workspace.Players.Killers.Jason"

-- 查找起始对象
local startObj = workspace:FindFirstChild("Players") and 
                workspace.Players:FindFirstChild("Killers") and 
                workspace.Players.Killers:FindFirstChild("Jason")

if not startObj then
    warn("起始路径不存在: "..startPath)
    return
end

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

-- 主执行逻辑
print("开始删除操作...")
recursiveDelete(startObj)
print("删除完成!")

-- 添加监听防止对象重新创建
for _, name in ipairs(targetNames) do
    startObj.DescendantAdded:Connect(function(descendant)
        if descendant.Name == name then
            task.wait(0)  -- 等待对象初始化
            descendant:Destroy()
            print("动态删除重新创建的对象: "..descendant:GetFullName())
        end
    end)
end