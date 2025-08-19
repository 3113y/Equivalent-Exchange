---@diagnostic disable: undefined-field, lowercase-global
EE = RegisterMod("Equivalent Exchange", 1)
include("table")
include("ee_api")
include("functions")
local json = require("json")
local trans_table = Isaac.GetItemIdByName("Transmutation Tablet")
local bag_ui = Sprite()
local setting_ui = Sprite()
local switch_item = Sprite()
local bag_item = Sprite()
local setting_button = Sprite()
local writing_spark = Sprite()
local font = Font()
local font_cn = Font()
local btn_pre = false
local Tab_Confirm = false
local anm_load = true
local load = true
local setting_ui_open = false
local EID_Render = false
local input_check
local numberString = { [1] = "", [2] = "", }
local setting_index         --设置按键的索引
local switch_page_index = 1 --当前转换桌页索引
local switch_page_num = 1   --最多转换桌页
local bag_page_index = 1    --当前背包页索引
local bag_page_num = 1      --最多背包页
local bag_item_index = 1    -- 背包道具索引
local current_num           -- 当前选中道具索引
local current_sprite        -- 当前选中道具精灵
local current_emc           -- 当前选中道具EMC值
local current_item_id       -- 当前选中道具ID
local chose_type            -- 0-- 当前选中类型（1：背包道具，2：转换桌道具，3：按钮 ，4：设置键）
local emc_num = 100
local temp_fire_delay
local stastic_pos
local items_table = {}                     --背包道具表
local switch_table = {}                    --桌中有的道具
emc_table = {}                       --EMC值表
local settings = {
    switch_table_permenent_memory = false, --转换桌道具是否永久记忆
    tab_confirm_key = Keyboard.KEY_TAB,    --Tab键位
    EID_connect_confirm = true,            --是否在搜索/选择物品时联动EID
    switch_table_spawn = true              --是否开局生成转换桌
}
local Data = {}


function EE:TAB_Switch() --TAB模式切换
    stastic_pos = Vector(Isaac.GetScreenWidth() / 2 - 114, Isaac.GetScreenHeight() / 2 - 67)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Game():GetPlayer(i)
        if player:HasCollectible(trans_table) then
            if Input.IsButtonTriggered(settings.tab_confirm_key, player.ControllerIndex) and not Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, player.ControllerIndex) then
                Tab_Confirm = not Tab_Confirm
                if Tab_Confirm then
                    player:AddControlsCooldown(1000)
                else
                    player:AddControlsCooldown(-1000)
                end
                anm_load = true
                if not Tab_Confirm then
                    if EID and settings.EID_connect_confirm then
                        EID:hidePermanentText()
                    end
                end
            end
        end
    end
end

EE:AddCallback(ModCallbacks.MC_POST_RENDER, EE.TAB_Switch)

function EE:TAB_UI_Render() --按下Tab后UI渲染
    if Tab_Confirm then
        if not setting_ui_open then
            bag_ui:Render(stastic_pos)
            for i, p in pairs(button_render) do
                p.sprite:Render(p.pos + stastic_pos)
            end
            for i, p in pairs(item_render) do
                if items_table[i + (bag_page_index - 1) * 27] then
                    p.sprite:Render(p.pos + stastic_pos)
                end
            end
            for i, p in pairs(switch_render) do
                if switch_table[i + (switch_page_index - 1) * 17] then
                    p.sprite:Render(p.pos + stastic_pos)
                end
            end
            setting_button:Render(Vector(230, 0) + stastic_pos)
            font:DrawStringUTF8("EMC:" .. emc_num, stastic_pos.X + 25 + #tostring(emc_num) * 3, stastic_pos.Y + 100,
            KColor.White, 1, true)
        elseif setting_ui_open then
            setting_ui:Render(stastic_pos)
            for i, o in pairs(numberString) do
                font:DrawStringUTF8(o, (stastic_pos + setting_input_pos[i]).X + #o * 3,
                    (stastic_pos + setting_input_pos[i]).Y + 2, KColor.White, 1, true)
            end
            for i, p in pairs(settings_render) do
                p.sprite:Render(p.pos + stastic_pos)
            end
            if Options.Language == "zh" then
                if settings.switch_table_permenent_memory then
                    font_cn:DrawStringUTF8("转换桌道具记忆：永久", (stastic_pos + settings_render[4].pos).X + 67,
                        (stastic_pos + settings_render[4].pos).Y, KColor.White, 1, true)
                else
                    font_cn:DrawStringUTF8("转换桌道具记忆：本局", (stastic_pos + settings_render[4].pos).X + 67,
                        (stastic_pos + settings_render[4].pos).Y, KColor.White, 1, true)
                end
                if settings.EID_connect_confirm then
                    font_cn:DrawStringUTF8("EID联动：开启", (stastic_pos + settings_render[5].pos).X + 48,
                        (stastic_pos + settings_render[5].pos).Y, KColor.White, 1, true)
                else
                    font_cn:DrawStringUTF8("EID联动：关闭", (stastic_pos + settings_render[5].pos).X + 48,
                        (stastic_pos + settings_render[5].pos).Y, KColor.White, 1, true)
                end
                if settings.tab_confirm_key == Keyboard.KEY_TAB then
                    font_cn:DrawStringUTF8("背包开启键位：Tab", (stastic_pos + settings_render[6].pos).X + 60,
                        (stastic_pos + settings_render[6].pos).Y, KColor.White, 1, true)
                elseif settings.tab_confirm_key == Keyboard.KEY_RIGHT_CONTROL then
                    font_cn:DrawStringUTF8("背包开启键位：右Ctrl", (stastic_pos + settings_render[6].pos).X + 65,
                        (stastic_pos + settings_render[6].pos).Y, KColor.White, 1, true)
                end
                if settings.switch_table_spawn then
                    font_cn:DrawStringUTF8("开局生成转换桌：是", (stastic_pos + settings_render[7].pos).X + 62,
                        (stastic_pos + settings_render[7].pos).Y, KColor.White, 1, true)
                else
                    font_cn:DrawStringUTF8("开局生成转换桌：否", (stastic_pos + settings_render[7].pos).X + 62,
                        (stastic_pos + settings_render[7].pos).Y, KColor.White, 1, true)
                end
            else
                if settings.switch_table_permenent_memory then
                    font:DrawStringUTF8("Switch Table Memory: Permanent", (stastic_pos + settings_render[4].pos).X + 109,
                        (stastic_pos + settings_render[4].pos).Y + 1, KColor.White, 1, true)
                else
                    font:DrawStringUTF8("Switch Table Memory: This Game", (stastic_pos + settings_render[4].pos).X + 109,
                        (stastic_pos + settings_render[4].pos).Y + 1, KColor.White, 1, true)
                end
                if settings.EID_connect_confirm then
                    font:DrawStringUTF8("EID Connection:on", (stastic_pos + settings_render[5].pos).X + 70,
                        (stastic_pos + settings_render[5].pos).Y + 1, KColor.White, 1, true)
                else
                    font:DrawStringUTF8("EID Connection:off", (stastic_pos + settings_render[5].pos).X + 73,
                        (stastic_pos + settings_render[5].pos).Y + 1, KColor.White, 1, true)
                end
                if settings.tab_confirm_key == Keyboard.KEY_TAB then
                    font:DrawStringUTF8("Keyboard to open bag :Tab", (stastic_pos + settings_render[6].pos).X + 94,
                        (stastic_pos + settings_render[6].pos).Y + 1, KColor.White, 1, true)
                elseif settings.tab_confirm_key == Keyboard.KEY_RIGHT_CONTROL then
                    font:DrawStringUTF8("Keyboard to open bag :Right Ctrl",
                        (stastic_pos + settings_render[6].pos).X + 115,
                        (stastic_pos + settings_render[6].pos).Y + 1, KColor.White, 1, true)
                end
                if settings.switch_table_spawn then
                    font:DrawStringUTF8("Spawn Trans Tablet in begin: Yes",
                        (stastic_pos + settings_render[7].pos).X + 114,
                        (stastic_pos + settings_render[7].pos).Y + 1, KColor.White, 1, true)
                else
                    font:DrawStringUTF8("Spawn Trans Tablet in begin: No", (stastic_pos + settings_render[7].pos).X + 111,
                        (stastic_pos + settings_render[7].pos).Y + 1, KColor.White, 1, true)
                end
            end
        end
    end
end

EE:AddCallback(ModCallbacks.MC_POST_RENDER, EE.TAB_UI_Render)
function EE:Remove_Add() --道具买卖/UI交互
    if Tab_Confirm then
        for pl = 0, Game():GetNumPlayers() - 1 do
            local player = Game():GetPlayer(pl)
            if not setting_ui_open then
                if Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and btn_pre == false then
                    if Mouse_Pos_Pos_Check(Input.GetMousePosition(true), item_render, 1) then
                        chose_type = 1
                    elseif Mouse_Pos_Pos_Check(Input.GetMousePosition(true), switch_render, 2) then
                        chose_type = 2
                    elseif Mouse_Pos_Pos_Check(Input.GetMousePosition(true), button_render, 3) then
                        chose_type = 3
                    elseif Mouse_Pos_But_Check(Input.GetMousePosition(true), Vector(230, 0) + stastic_pos, 2) then
                        chose_type = 4
                    else
                        chose_type = 0
                    end
                end
                if chose_type == 1 then
                    for i, p in pairs(item_render) do
                        if Mouse_Pos_But_Check(Input.GetMousePosition(true), p.pos + stastic_pos, 1) and items_table[i + (bag_page_index - 1) * 27] and emc_table[items_table[i + (bag_page_index - 1) * 27]] ~= 0 and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and not btn_pre then --拿起背包道具
                            current_num = i
                            current_emc = emc_table[items_table[current_num + (bag_page_index - 1) * 27]]
                            current_item_id = items_table[current_num + (bag_page_index - 1) * 27]
                            current_sprite = p.sprite
                            btn_pre = true
                            if EID and settings.EID_connect_confirm then
                                EID:displayPermanentText(EID:getDescriptionObj(5, 100,
                                    items_table[current_num + (bag_page_index - 1) * 27], nil, true))
                            end
                        elseif Mouse_Pos_But_Check(Input.GetMousePosition(true), sell_pos + stastic_pos, 2) and btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then --卖掉背包道具
                            player:RemoveCollectible(items_table[current_num + (bag_page_index - 1) * 27], true)
                            emc_num = emc_table[items_table[current_num + (bag_page_index - 1) * 27]] + emc_num
                            if emc_num >= 2147483647 then
                                emc_num = 2147483647
                            end
                            if EID and settings.EID_connect_confirm then
                                EID:hidePermanentText()
                            end
                            AddIfNotExists(switch_table, items_table[current_num + (bag_page_index - 1) * 27])
                            btn_pre = false
                            anm_load = true
                        elseif not Mouse_Pos_Pos_Check(Input.GetMousePosition(true), item_render, 1) and btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then --无效果
                            if EID and settings.EID_connect_confirm then
                                EID:hidePermanentText()
                            end
                            btn_pre = false
                        end
                    end
                    anm_load = true
                elseif chose_type == 2 then
                    for i, p in pairs(switch_render) do
                        if Mouse_Pos_But_Check(Input.GetMousePosition(true), p.pos + stastic_pos, 2) and switch_table[i + (switch_page_index - 1) * 17] and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and not btn_pre then --拿起转换台上道具
                            current_num = i
                            current_emc = emc_table[switch_table[current_num + (switch_page_index - 1) * 17]]
                            current_item_id = switch_table[current_num + (switch_page_index - 1) * 17]
                            current_sprite = p.sprite
                            btn_pre = true
                            if EID and settings.EID_connect_confirm then
                                EID:displayPermanentText(EID:getDescriptionObj(5, 100,
                                    switch_table[current_num + (switch_page_index - 1) * 17], nil, true))
                            end
                        elseif Mouse_Pos_Pos_Check(Input.GetMousePosition(true), item_render, 1) and btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then --买出成功
                            if emc_num >= emc_table[switch_table[current_num + (switch_page_index - 1) * 17]] then
                                if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
                                    if T_Isaac_less_than_8(player) then
                                        emc_num = emc_num -
                                            emc_table[switch_table[current_num + (switch_page_index - 1) * 17]]
                                        player:AddCollectible(switch_table[current_num + (switch_page_index - 1) * 17], 6,
                                            false)
                                    end
                                else
                                    emc_num = emc_num -
                                        emc_table[switch_table[current_num + (switch_page_index - 1) * 17]]
                                    player:AddCollectible(switch_table[current_num + (switch_page_index - 1) * 17], 6,
                                        false)
                                end
                            end
                            if EID and settings.EID_connect_confirm then
                                EID:hidePermanentText()
                            end
                            btn_pre = false
                        elseif not Mouse_Pos_Pos_Check(Input.GetMousePosition(true), switch_render, 2) and btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then --买出失败
                            if EID and settings.EID_connect_confirm then
                                EID:hidePermanentText()
                            end
                            btn_pre = false
                        end
                    end
                    anm_load = true
                elseif chose_type == 3 then
                    for i, anm in pairs(button_render) do
                        if Mouse_Pos_But_Check(Input.GetMousePosition(true), anm.pos + stastic_pos, 1) and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and not btn_pre then
                            anm.sprite:Play("Press", true)
                            current_num = i
                            btn_pre = true
                        elseif btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then
                            button_render[current_num].sprite:Play("Idle", true)
                            btn_pre = false
                            Page_Switch()
                        end
                    end
                    anm_load = true
                elseif chose_type == 4 then
                    if Mouse_Pos_But_Check(Input.GetMousePosition(true), Vector(230, 0) + stastic_pos, 1) and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and not btn_pre then
                        setting_button:Play("Press", true)
                        btn_pre = true
                    elseif btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then
                        setting_ui_open = true
                        setting_button:Play("Idle", true)
                        btn_pre = false
                    end
                end
                anm_load = true
                if btn_pre and (chose_type == 1 or chose_type == 2) then
                    font:DrawStringUTF8("Id:" .. current_item_id, Isaac.WorldToScreen(Input.GetMousePosition(true)).X,
                        Isaac.WorldToScreen(Input.GetMousePosition(true)).Y + 20, KColor.White, 1, true)
                    font:DrawStringUTF8("EMC:" .. current_emc, Isaac.WorldToScreen(Input.GetMousePosition(true)).X,
                        Isaac.WorldToScreen(Input.GetMousePosition(true)).Y + 10, KColor.White, 1,
                        true)
                    current_sprite:Render(Isaac.WorldToScreen(Input.GetMousePosition(true)))
                end
            elseif setting_ui_open then
                for i, p in pairs(setting_input_pos) do
                    if Mouse_Pos_But_Check(Input.GetMousePosition(true), p + stastic_pos - Vector(2, 2), 3) and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and not btn_pre then
                        input_check = i
                        IsReading = true
                        btn_pre = true
                        setting_index = 1
                    elseif btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and setting_index == 1 then
                        btn_pre = false
                    end
                end
                if input_check then
                    writing_spark:Play("Idle")
                    writing_spark:Render(setting_input_pos[input_check] + stastic_pos +
                        Vector(#numberString[input_check] * 6, 0))
                    if IsReading then
                        for i = 0, 9 do
                            local keyName = "KEY_" .. i
                            if Input.IsButtonTriggered(Keyboard[keyName], player.ControllerIndex) then
                                numberString[input_check] = numberString[input_check] .. tostring(i)
                            end
                        end
                        if Input.IsButtonTriggered(Keyboard.KEY_BACKSPACE, player.ControllerIndex) then
                            numberString[input_check] = numberString[input_check]:sub(1, -2)
                        end
                    end
                end
                for i, p in pairs(settings_render) do
                    if Mouse_Pos_But_Check(Input.GetMousePosition(true), p.pos + stastic_pos, 1) and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and not btn_pre then
                        p.sprite:Play("Press", true)
                        current_num = i
                        btn_pre = true
                        setting_index = 2
                    elseif btn_pre and not Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and setting_index == 2 then
                        settings_render[current_num].sprite:Play("Idle", true)
                        if current_num == 3 then
                            setting_ui_open = false
                            EID_Render = false
                            if EID and settings.EID_connect_confirm then
                                EID:hidePermanentText()
                            end
                        elseif current_num == 1 then
                            if emc_table[tonumber(numberString[1])] then
                                IsReading = false
                                EID_Render = true
                                anm_load = true
                            end
                        elseif current_num == 2 then
                            if numberString[2] ~= "" then
                                if tonumber(numberString[2]) >= 2147483647 then
                                    numberString[2] = "2147483647"
                                end
                                emc_table[tonumber(numberString[1])] = tonumber(numberString[2])
                                EID_Render = false
                                EID:hidePermanentText()
                                numberString = { [1] = "", [2] = "", }
                            end
                        elseif current_num == 4 then
                            settings.switch_table_permenent_memory = not settings.switch_table_permenent_memory
                        elseif current_num == 5 then
                            settings.EID_connect_confirm = not settings.EID_connect_confirm
                        elseif current_num == 6 then
                            if settings.tab_confirm_key == Keyboard.KEY_TAB then
                                settings.tab_confirm_key = Keyboard.KEY_RIGHT_CONTROL
                            else
                                settings.tab_confirm_key = Keyboard.KEY_TAB
                            end
                        elseif current_num == 7 then
                            settings.switch_table_spawn = not settings.switch_table_spawn
                        end
                        btn_pre = false
                    end
                end
            end
        end
    end
end

EE:AddCallback(ModCallbacks.MC_POST_RENDER, EE.Remove_Add)
function EE:EID() --EID兼容
    if EID then
        if settings.EID_connect_confirm then
            if EID_Render then
                EID:displayPermanentText(EID:getDescriptionObj(5, 100, tonumber(numberString[1]), nil, true),
                    "collectibles", "5.100." .. tonumber(numberString[1]))
            end
        end
    end
end

EE:AddCallback(ModCallbacks.MC_POST_RENDER, EE.EID)
function EE:Anm2Load() --anm2 sheet的替换
    if anm_load then
        bag_item_index = 1
        items_table = {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            ---@diagnostic disable-next-line: undefined-field
            for col_i = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
                if ItemConfig.Config.IsValidCollectible(col_i) then
                    for has_i = 1, player:GetCollectibleNum(col_i, true) do
                        items_table[bag_item_index] = col_i
                        bag_item_index = bag_item_index + 1
                    end
                end
            end
        end
        bag_page_num = math.floor(#items_table / 27) + 1
        switch_page_num = math.floor(#switch_table / 17) + 1
        for i, anm in pairs(item_render) do
            if items_table[i + (bag_page_index - 1) * 27] then
                anm.sprite:ReplaceSpritesheet(0,
                    Isaac.GetItemConfig():GetCollectible(items_table[i + (bag_page_index - 1) * 27])
                    .GfxFileName, true)
            end
        end
        for i, anm in pairs(switch_render) do
            if switch_table[i + (switch_page_index - 1) * 17] then
                anm.sprite:ReplaceSpritesheet(0,
                    Isaac.GetItemConfig():GetCollectible(switch_table[i + (switch_page_index - 1) * 17]).GfxFileName,
                    true)
            end
        end
        anm_load = false
    end
end

EE:AddCallback(ModCallbacks.MC_POST_UPDATE, EE.Anm2Load)

function EE:Begining_Load() --常用sprite加载
    if load then
        font:Load("font/terminus8.fnt")
        font_cn:Load("font/cjk/lanapixel.fnt")
        bag_ui:Load("gfx/ui/transmutation_table.anm2", true)
        switch_item:Load("gfx/ui/Item_ID.anm2", true)
        bag_item:Load("gfx/ui/Item_ID.anm2", true)
        setting_button:Load("gfx/ui/button_settings.anm2", true)
        setting_ui:Load("gfx/ui/settings.anm2", true)
        writing_spark:Load("gfx/ui/writing_spark.anm2", true)
        bag_ui:Play("Idle", true)
        switch_item:Play("Icon", true)
        bag_item:Play("Icon", true)
        setting_button:Play("Idle", true)
        setting_ui:Play("Idle", true)
        for _, anm in pairs(item_render) do
            anm.sprite:Load("gfx/ui/Item_ID.anm2", true)
            anm.sprite:Play("Icon", true)
        end
        for _, anm in pairs(switch_render) do
            anm.sprite:Load("gfx/ui/Item_ID.anm2", true)
            anm.sprite:Play("Icon", true)
        end
        for _, anm in pairs(button_render) do
            anm.sprite:Load("gfx/ui/button_" .. anm.aim .. ".anm2", true)
            anm.sprite:Play("Idle", true)
        end
        for _, anm in pairs(settings_render) do
            anm.sprite:Load("gfx/ui/button_" .. anm.name .. ".anm2", true)
            anm.sprite:Play("Idle", true)
        end
        load = false
    end
end

EE:AddCallback(ModCallbacks.MC_POST_UPDATE, EE.Begining_Load)
function Data_Load(_, isContinued) --数据加载
    if EE:HasData() then
        Data = json.decode(EE:LoadData())
        settings = Data.settings or settings_init
    end
    if isContinued then
        emc_table = Data.emc_table
        emc_num = Data.emc_num
        switch_table = Data.switch_table
    else
        emc_num = 0
        emc_table = Data.emc_table or emc_table_init
        if settings.switch_table_permenent_memory then
            switch_table = Data.switch_table
        else
            switch_table = {}
        end
    end
    ---@diagnostic disable-next-line: undefined-field
    for col_i = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
        if ItemConfig.Config.IsValidCollectible(col_i) and col_i > 732 then
            emc_table[col_i] = (Isaac.GetItemConfig():GetCollectible(col_i).Quality + 1) * 20
        end
    end
end

EE:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 0.01, Data_Load)
function EE:Replace_EMC_For_Mod()
    emc_table = MergeTables(emc_table, mod_emc_table_init)
end

EE:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 100, EE.Replace_EMC_For_Mod)

function EE:Data_Save() --数据保存
    Data.emc_table = emc_table
    Data.emc_num = emc_num
    Data.switch_table = switch_table
    Data.settings = settings
    EE:SaveData(json.encode(Data))
end

EE:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, EE.Data_Save, true)
function EE:Mod_EMC_Refresh() --取消订阅后刷新数据
    switch_table = {}
    emc_table = RemoveAfterIndex(emc_table, 732)
    Data.emc_table = emc_table
    Data.emc_num = emc_num
    Data.switch_table = switch_table
    Data.settings = settings
    EE:SaveData(json.encode(Data))
end

EE:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, EE.Mod_EMC_Refresh)

EE:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup) --不受steam sale影响
    if pickup:IsShopItem() then
        if pickup.SubType == trans_table then
            for index = 0, Game():GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(index)
                local price = pickup.Price
                if pickup.SubType == trans_table then
                    if price >= 0 and player:HasCollectible(64) then
                        local itemnum = player:GetCollectibleNum(64)
                        local ori_price = InferOriginalPrice(itemnum, price)
                        pickup.Price = ori_price[1]
                    end
                end
            end
        end
    end
end)
function EE:ST_Beginning(_, bool) --开局生成转换桌
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Game():GetPlayer(i)
        if not bool and settings.switch_table_spawn then
            if not player:HasCollectible(trans_table) then
                Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
                    (Game():GetRoom():GetCenterPos() + Vector(-100, 0)),
                    Vector(0, 0), nil, trans_table, Game():GetRoom():GetSpawnSeed())
                break
            end
        end
    end
    Tab_Confirm = false
end

EE:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, EE.ST_Beginning)
function T_Isaac_less_than_8(player) --堕化以撒道具数检测
    local num = 0
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
    end
end

function Mouse_Pos_Pos_Check(Mouse_Pos, table, i) --检测鼠标位置（即在某区域）
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

function Page_Switch() --背包/转换桌切换
    if current_num == 1 then
        if switch_page_index <= 1 then
            switch_page_index = 1
        else
            switch_page_index = switch_page_index - 1
        end
    elseif current_num == 2 then
        if switch_page_index < switch_page_num then
            switch_page_index = switch_page_index + 1
        else
            switch_page_index = switch_page_index
        end
    elseif current_num == 3 then
        if bag_page_index <= 1 then
            bag_page_index = 1
        else
            bag_page_index = bag_page_index - 1
        end
    elseif current_num == 4 then
        if bag_page_index < bag_page_num then
            bag_page_index = bag_page_index + 1
        else
            bag_page_index = bag_page_index
        end
    end
end

function AddIfNotExists(tbl, num) --向表中加入不存在元素
    for _, value in pairs(tbl) do
        if value == num then
            return
        end
    end
    table.insert(tbl, num)
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

if EID then
    EID:addCollectible(trans_table, "神秘炼金学的产物，比里该隐的袋子强多了", "转换桌", "zh_cn")
end

EE:Set_Item_EMC_By_Id({[trans_table]=0})