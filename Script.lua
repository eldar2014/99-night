-- ============================================
-- ПОДКЛЮЧЕНИЕ БИБЛИОТЕКИ
-- ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================
-- СОЗДАНИЕ ГЛАВНОГО ОКНА
-- ============================================
local Window = Rayfield:CreateWindow({
    Name = "99 Ночей - Мой Хаб",
    LoadingTitle = "Загрузка...",
    ConfigurationSaving = {
       Enabled = true,
       FileName = "99NightsHub"
    }
})

-- ============================================
-- ВКЛАДКИ
-- ============================================
local MainTab = Window:CreateTab("Основное", 101)
local CombatTab = Window:CreateTab("Бой", 102)
local TeleportTab = Window:CreateTab("Телепорты", 103)

-- ============================================
-- ФУНКЦИИ
-- ============================================

-- Переменные для состояния
local flyEnabled = false
local godModeEnabled = false
local killAuraEnabled = false
local autoEatEnabled = false
local autoCampfireEnabled = false
local bringItemsEnabled = false
local currentSpeed = 16

-- ---------- ФЛАЙ ----------
local function toggleFly(state)
    flyEnabled = state
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if state then
        humanoid.PlatformStand = true
        while flyEnabled and wait(0.01) do
            pcall(function()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    else
        humanoid.PlatformStand = false
    end
end

-- ---------- СКОРОСТЬ ----------
local function setSpeed(value)
    currentSpeed = value
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

-- ---------- АУРА УБИЙСТВА ----------
local function toggleKillAura(state)
    killAuraEnabled = state
    while killAuraEnabled and wait(0.5) do
        pcall(function()
            for _, v in pairs(game:GetService("Workspace").Entities:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    local humanoid = v:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local root = v:FindFirstChild("HumanoidRootPart")
                        if root then
                            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, root, 0)
                            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, root, 1)
                        end
                    end
                end
            end
        end)
    end
end

-- ---------- БЕССМЕРТИЕ ----------
local function toggleGodMode(state)
    godModeEnabled = state
    if state then
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = 9e9
                    humanoid.Health = 9e9
                end
            end
        end)
    else
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = 100
                    humanoid.Health = 100
                end
            end
        end)
    end
end

-- ---------- ПРИТЯГИВАНИЕ ПРЕДМЕТОВ ----------
local function bringItems()
    pcall(function()
        local player = game.Players.LocalPlayer
        for _, item in pairs(game:GetService("Workspace"):GetChildren()) do
            if item:IsA("Tool") or item:IsA("Model") and item:FindFirstChild("Handle") then
                item:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
            end
        end
    end)
end

-- ---------- АВТОЕДА ----------
local function toggleAutoEat(state)
    autoEatEnabled = state
    while autoEatEnabled and wait(5) do
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health < 80 then
                    for _, item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") and item.Name:lower():find("food") then
                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(item)
                            wait(0.5)
                            game:GetService("ReplicatedStorage").Events.UseItem:FireServer(item)
                        end
                    end
                end
            end
        end)
    end
end

-- ---------- АВТОКОСТЁР ----------
local function toggleCampfire(state)
    autoCampfireEnabled = state
    while autoCampfireEnabled and wait(10) do
        pcall(function()
            local player = game.Players.LocalPlayer
            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find("campfire") then
                    if (v:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude < 10 then
                        fireclickdetector(v:FindFirstChild("ClickDetector"))
                    end
                end
            end
        end)
    end
end

-- ============================================
-- ИНТЕРФЕЙС
-- ============================================

-- ---------- ОСНОВНОЕ ----------
local MainSection = MainTab:CreateSection("Основные функции")

-- Флай
MainTab:CreateToggle({
    Name = "Флай",
    CurrentValue = false,
    Flag = "fly",
    Callback = function(Value)
        toggleFly(Value)
    end
})

-- Скорость
MainTab:CreateSlider({
    Name = "Скорость ходьбы",
    Range = {16, 300},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "speed",
    Callback = function(Value)
        setSpeed(Value)
    end
})

-- Притянуть предметы
MainTab:CreateButton({
    Name = "Притянуть предметы",
    Callback = function()
        bringItems()
    end
})

-- Аура убийства
CombatTab:CreateToggle({
    Name = "Аура убийства",
    CurrentValue = false,
    Flag = "killaura",
    Callback = function(Value)
        toggleKillAura(Value)
    end
})

-- Бессмертие
CombatTab:CreateToggle({
    Name = "Бессмертие",
    CurrentValue = false,
    Flag = "godmode",
    Callback = function(Value)
        toggleGodMode(Value)
    end
})

-- Автоеда
CombatTab:CreateToggle({
    Name = "Автоеда",
    CurrentValue = false,
    Flag = "autoeat",
    Callback = function(Value)
        toggleAutoEat(Value)
    end
})

-- Автокостёр
CombatTab:CreateToggle({
    Name = "Автокостёр",
    CurrentValue = false,
    Flag = "autocampfire",
    Callback = function(Value)
        toggleCampfire(Value)
    end
})

-- ---------- ТЕЛЕПОРТЫ ----------
local TeleportSection = TeleportTab:CreateSection("Телепорты")

-- Телепорт в лагерь
TeleportTab:CreateButton({
    Name = "Телепорт в лагерь",
    Callback = function()
        pcall(function()
            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find("camp") then
                    local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    if root then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 10, 0)
                    end
                end
            end
        end)
    end
})

-- Телепорт к торговцу
TeleportTab:CreateButton({
    Name = "Телепорт к торговцу",
    Callback = function()
        pcall(function()
            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find("trader") then
                    local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    if root then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 10, 0)
                    end
                end
            end
        end)
    end
})

-- Телепорт в крепость
TeleportTab:CreateButton({
    Name = "Телепорт в крепость",
    Callback = function()
        pcall(function()
            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find("stronghold") then
                    local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    if root then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 10, 0)
                    end
                end
            end
        end)
    end
})

-- ============================================
-- ЗАВЕРШЕНИЕ
-- ============================================
print("Скрипт загружен. Добро пожаловать, !")
