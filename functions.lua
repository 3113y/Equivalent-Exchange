function T_Isaac_less_than_8(player) --堕化以撒道具数检测
    local num = 0
---@diagnostic disable-next-line: undefined-field
    for col_i = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
        if ItemConfig.Config.IsValidCollectible(col_i) then
            for has_i = 1, player:GetCollectibleNum(col_i, true) do
                num = num + 1
            end
        end
    end
    if num < 8 then
        return true
    else
        return false
    end
end

function Mouse_Pos_But_Check(Mouse_Pos, Aim_pos, i) --检测鼠标位置（即在某小格）
    local mous_pos = Isaac.WorldToScreen(Mouse_Pos)
    if i == 1 then
        if mous_pos.X >= Aim_pos.X and mous_pos.X <= Aim_pos.X + 13 then
            if mous_pos.Y >= Aim_pos.Y and mous_pos.Y <= Aim_pos.Y + 16 then
                return true
            else
                return false
            end
        end
    elseif i == 2 then
        if mous_pos.X >= Aim_pos.X and mous_pos.X <= Aim_pos.X + 17 then
            if mous_pos.Y >= Aim_pos.Y and mous_pos.Y <= Aim_pos.Y + 17 then
                return true
            else
                return false
            end
        end
    elseif i == 3 then
        if mous_pos.X >= Aim_pos.X and mous_pos.X <= Aim_pos.X + 72 then
            if mous_pos.Y >= Aim_pos.Y and mous_pos.Y <= Aim_pos.Y + 20 then
                return true
            else
                return false
            end
        end
    elseif i == 4 then
        if mous_pos.X >= Aim_pos.X and mous_pos.X <= Aim_pos.X + 47 then
            if mous_pos.Y >= Aim_pos.Y and mous_pos.Y <= Aim_pos.Y + 14 then
                return true
            else
                return false
            end
        end
    end
end

function Mouse_Pos_Pos_Check(Mouse_Pos, table, i, pos) --检测鼠标位置（即在某区域）
    local stastic_pos = pos
    local mous_pos = Isaac.WorldToScreen(Mouse_Pos)
    local temp = 0
    for _, p in pairs(table) do
        if mous_pos.X >= (p.pos + stastic_pos).X and mous_pos.X <= (p.pos + stastic_pos).X + 17 then
            if mous_pos.Y >= (p.pos + stastic_pos).Y and mous_pos.Y <= (p.pos + stastic_pos).Y + 17 then
                temp = temp + 1
            else
                temp = temp
            end
        end
    end
    if temp > 0 then
        return i
    else
        return false
    end
end

function InferOriginalPrice(couponCount, discountedPrice) --原价计算函数
    local originalPrices = {}
    if type(couponCount) ~= "number" or type(discountedPrice) ~= "number"
        or couponCount < 1 or discountedPrice < 1
        or math.floor(couponCount) ~= couponCount
        or math.floor(discountedPrice) ~= discountedPrice then
        return originalPrices
    end

    if couponCount == 1 then
        local minP = 2 * discountedPrice
        local maxP = 2 * discountedPrice + 1
        for p = minP, maxP do
            table.insert(originalPrices, p)
        end
    else
        local divisor = couponCount + 1
        local minP = (discountedPrice - 1) * divisor + 1
        local maxP = discountedPrice * divisor
        minP = math.max(minP, 1)
        for p = minP, maxP do
            table.insert(originalPrices, p)
        end
    end

    return originalPrices
end

function RemoveAfterIndex(tbl, num) --取消订阅后初始化EMC
    local toRemove = {}
    for key, _ in pairs(tbl) do
        if type(key) == "number" and key > num then
            table.insert(toRemove, key)
        end
    end
    for _, key in pairs(toRemove) do
        tbl[key] = nil
    end

    return tbl
end

function MergeTables(t1, t2) --覆盖函数
    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

function IsIdInSwitchTable(id, switch_table)
    id = tonumber(id)
    for _, v in pairs(switch_table) do
        if v == id then
            return true
        end
    end
    return false
end
