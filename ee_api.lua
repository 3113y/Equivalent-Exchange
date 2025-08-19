---@diagnostic disable: lowercase-global
---comment
---@param table table --eg:{[114]=514,[799]=147}
function EE:Set_Item_EMC_By_Id(table)
    mod_emc_table_init = table
    -- 确保 emc_table 存在
    if not emc_table then
        emc_table = {}
    end
    -- 直接赋值/覆盖
    for k, v in pairs(table) do
        emc_table[k] = v
    end
end
