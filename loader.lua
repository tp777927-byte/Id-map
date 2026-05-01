-- 🔑 HayateX Loader (Stable)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local userId = player.UserId

-- 🔧 ตั้งค่า
local KEY = _G.key or ""
local DOMAIN = "https://id-map.onrender.com"

-- 🔔 Notify กันพัง
local function Notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "HayateX",
            Text = msg,
            Duration = 4
        })
    end)
end

-- ❌ ไม่มีคีย์
if KEY == "" then
    Notify("❌ กรุณาใส่คีย์ก่อน")
    return
end

-- 🔗 API
local url = DOMAIN.."/api/validate?key="..KEY.."&userid="..userId

-- 🔍 ยิง API
local response
local ok = pcall(function()
    response = game:HttpGet(url)
end)

if not ok or not response then
    Notify("❌ เชื่อม API ไม่ได้")
    return
end

-- 📦 แปลง JSON
local data
local success = pcall(function()
    data = HttpService:JSONDecode(response)
end)

if not success or not data then
    Notify("❌ API ส่งค่าผิด")
    return
end

-- ✅ ผ่าน
if data.valid == true then
    Notify("✔ Key ถูกต้อง")

    -- 🔥 โหลดสคริปหลัก
    local MAIN_URL = "https://raw.githubusercontent.com/tp777927-byte/Id-map/main/HayateX.lua"

    local scriptData
    local loaded = pcall(function()
        scriptData = game:HttpGet(MAIN_URL)
    end)

    if loaded and scriptData then
        (loadstring or load)(scriptData)()
    else
        Notify("❌ โหลดสคริปไม่สำเร็จ")
    end

else
    Notify("❌ Key ไม่ถูกต้อง")
    player:Kick("Invalid Key")
end
