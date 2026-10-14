-- ============================================================
-- GRAND MOBILE HACK - v2.1.0
-- + NORMAL KEY + PREMIUM KEY + TELEGRAM TRACKING
-- ============================================================
print("Lua version:", _VERSION)
local __tamper = debug.getinfo
if not __tamper then
    gg.alert("Protected Script")
    os.exit()
end

local EXPIRY_DAY, EXPIRY_MONTH, EXPIRY_YEAR = 25, 6, 2027

local function checkExpiry()
    local c = os.date("*t")
    local now = os.time({year=c.year, month=c.month, day=c.day})
    local exp = os.time({year=EXPIRY_YEAR, month=EXPIRY_MONTH, day=EXPIRY_DAY, hour=23, min=59, sec=59})
    if now > exp then
        gg.alert("[Script expired - @GRANDMOBILEHACK]")
        os.exit() gg.exit()
        return true
    end
    return false
end
if checkExpiry() then return end

-- ============================================================
-- 🔐 DUAL KEY SYSTEM (Normal + Premium)
-- ============================================================
local KEY_FILE_NORMAL  = "/storage/emulated/0/mainmenu_key.dat"
local KEY_FILE_PREMIUM = "/storage/emulated/0/premium_key.dat"

local BOT_TOKEN = "8926592344:AAGJ60jc3htbZ2CrBdcJP6-CtJBjsfwWMKA"
local CHAT_ID   = "8012099182"

local function getIST()
    local utc = os.time(os.date("!*t"))
    return utc + (5 * 3600) + (30 * 60)
end

local function makeIST(day, month, year, hour, min)
    hour = hour or 23
    min  = min  or 59
    local t = os.time({year=year, month=month, day=day, hour=hour, min=min, sec=59})
    local localOffset = os.difftime(os.time(), os.time(os.date("!*t")))
    return t - localOffset + (5 * 3600) + (30 * 60)
end

-- 🔑 Normal Key Database
local KEY_DB = {
    ["GRANDMOBILEHACK-DAY1-0001"]    = {day=12, month=10, year=2026},
    ["GRANDMOBILEHACK-DAY3-0001"]    = {day=14, month=10, year=2026},
    ["GRANDMOBILEHACK-WEEK-0001"]    = {day=18, month=10, year=2026},
    ["GRANDMOBILEHACK-DAY14-0001"]   = {day=25, month=10, year=2026},
    ["GRANDMOBILEHACK-MONTH1-0001"]  = {day=11, month=11, year=2026},
    ["GRANDMOBILEHACK-MONTH2-0001"]  = {day=11, month=12, year=2026},
    ["GRANDMOBILEHACK-MONTH3-0001"]  = {day=11, month=1,  year=2027},
    ["GRANDMOBILEHACK-MONTH6-0001"]  = {day=11, month=4,  year=2027},
    ["GRANDMOBILEHACK-YEAR1-0001"]   = {day=11, month=10, year=2027},
    ["GRANDMOBILEHACK-YEAR2-0001"]   = {day=11, month=10, year=2028},
    ["GRANDMOBILEHACK-YEAR3-0001"]   = {day=11, month=10, year=2029},
    ["GRANDMOBILEHACK-YEAR5-0001"]   = {day=11, month=10, year=2031},
    ["GRANDMOBILEHACK-YEAR10-0001"]  = {day=11, month=10, year=2036},
    ["GRANDMOBILEHACK-LIFETIME-0001"]= {day=11, month=10, year=2126},
}

-- 👑 Premium Key Database
local KEY_DB_PREMIUM = {
    ["GMHPREMIUM-DAY1-0001"]     = {day=12, month=10, year=2026},
    ["GMHPREMIUM-DAY3-0001"]     = {day=14, month=10, year=2026},
    ["GMHPREMIUM-WEEK-0001"]     = {day=18, month=10, year=2026},
    ["GMHPREMIUM-DAY14-0001"]    = {day=25, month=10, year=2026},
    ["GMHPREMIUM-MONTH1-0001"]   = {day=11, month=11, year=2026},
    ["GMHPREMIUM-MONTH2-0001"]   = {day=11, month=12, year=2026},
    ["GMHPREMIUM-MONTH3-0001"]   = {day=11, month=1,  year=2027},
    ["GMHPREMIUM-MONTH6-0001"]   = {day=11, month=4,  year=2027},
    ["GMHPREMIUM-YEAR1-0001"]    = {day=11, month=10, year=2027},
    ["GMHPREMIUM-YEAR2-0001"]    = {day=11, month=10, year=2028},
    ["GMHPREMIUM-YEAR3-0001"]    = {day=11, month=10, year=2029},
    ["GMHPREMIUM-YEAR5-0001"]    = {day=11, month=10, year=2031},
    ["GMHPREMIUM-YEAR10-0001"]   = {day=11, month=10, year=2036},
    ["GMHPREMIUM-LIFETIME-0001"] = {day=11, month=10, year=2126},
}

-- ============================================================
-- 📱 DEVICE INFO
-- ============================================================
local function getDeviceInfo()
    local info = gg.getTargetInfo()
    local model, android = "unknown", "unknown"
    local f = io.open("/system/build.prop", "r")
    if f then
        for line in f:lines() do
            local k, v = line:match("([^=]+)=(.+)")
            if k == "ro.product.model" then model = v end
            if k == "ro.build.version.release" then android = v end
        end
        f:close()
    end
    local hwidFile = "/storage/emulated/0/.gmh_hwid"
    local hwid = nil
    local hf = io.open(hwidFile, "r")
    if hf then hwid = hf:read("*l") hf:close() end
    if not hwid or hwid == "" then
        math.randomseed(os.time() + math.random(1000, 9999))
        hwid = string.format("%08X%08X",
            math.random(0, 0xFFFFFFFF),
            math.random(0, 0xFFFFFFFF))
        local hw = io.open(hwidFile, "w")
        if hw then hw:write(hwid) hw:close() end
    end
    local pkg = info and info.packageName or "?"
    return hwid, model, android, pkg
end

-- ============================================================
-- 📡 TELEGRAM
-- ============================================================
local function urlEncode(s)
    s = tostring(s)
    s = s:gsub("([^%w%-%._~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return s
end

local function sendTelegram(msg)
    local url = "https://api.telegram.org/bot" .. BOT_TOKEN ..
                "/sendMessage?chat_id=" .. CHAT_ID ..
                "&text=" .. urlEncode(msg) ..
                "&parse_mode=HTML"

    if gg.makeRequest then
        local ok = pcall(function() gg.makeRequest(url) end)
        if ok then return true end
    end
    pcall(function()
        os.execute("curl -s --max-time 8 '" .. url .. "' > /dev/null 2>&1")
    end)
    return false
end

local function formatRemaining(sec)
    if sec <= 0 then return "EXPIRED" end
    local d = math.floor(sec / 86400)
    local h = math.floor((sec % 86400) / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    return string.format("%dd %02dh %02dm %02ds", d, h, m, s)
end

-- ★ CHANGED: reportActivation — removed Phone/Android, added Expiry + Remaining
local function reportActivation(key, expiryStr, menuType, remainStr)
    local hwid, _, _, pkg = getDeviceInfo()
    local menuTag = (menuType == "PREMIUM") and "👑 PREMIUM" or "🎮 NORMAL"
    local remainLine = remainStr and ("⏳ Remaining : " .. remainStr .. "\n") or ""
    local msg = string.format(
        "🔔 <b>KEY ACTIVATED</b> [%s]\n" ..
        "━━━━━━━━━━━━━━━━━━\n" ..
        "🔑 Key     : <code>%s</code>\n" ..
        "📅 Expires : %s\n" ..
        "%s" ..
        "🆔 HWID    : <code>%s</code>\n" ..
        "📦 Package : %s\n" ..
        "🕐 Time    : %s IST\n" ..
        "━━━━━━━━━━━━━━━━━━",
        menuTag, key, expiryStr, remainLine, hwid, pkg,
        os.date("%d/%m/%Y %H:%M:%S")
    )
    sendTelegram(msg)
end

-- ★ CHANGED: reportStart — removed Phone, added Expiry (auto-looked up from DB)
local function reportStart(key, menuType)
    local hwid, _, _, _ = getDeviceInfo()
    local menuTag = (menuType == "PREMIUM") and "👑 PREMIUM" or "🎮 NORMAL"

    local db = (menuType == "PREMIUM") and KEY_DB_PREMIUM or KEY_DB
    local info = db[key]
    local expiryStr = "unknown"
    if info then
        expiryStr = string.format("%02d/%02d/%04d 23:59:59 IST", info.day, info.month, info.year)
    end

    local msg = string.format(
        "▶️ <b>SCRIPT STARTED</b> [%s]\n" ..
        "🔑 Key     : <code>%s</code>\n" ..
        "📅 Expires : %s\n" ..
        "🆔 HWID    : <code>%s</code>\n" ..
        "🕐 Time    : %s IST",
        menuTag, key, expiryStr, hwid, os.date("%d/%m/%Y %H:%M:%S")
    )
    sendTelegram(msg)
end

-- ★ NEW: reportFakeKey — sends alert when wrong/expired/empty key is entered
local function reportFakeKey(enteredKey, menuType, reason)
    local hwid, _, _, pkg = getDeviceInfo()
    local menuTag = (menuType == "PREMIUM") and "👑 PREMIUM" or "🎮 NORMAL"
    local msg = string.format(
        "🚨 <b>FAKE KEY ATTEMPT</b> [%s]\n" ..
        "━━━━━━━━━━━━━━━━━━\n" ..
        "❌ Entered : <code>%s</code>\n" ..
        "⚠️ Reason  : %s\n" ..
        "🆔 HWID    : <code>%s</code>\n" ..
        "📦 Package : %s\n" ..
        "🕐 Time    : %s IST\n" ..
        "━━━━━━━━━━━━━━━━━━",
        menuTag, enteredKey, reason, hwid, pkg,
        os.date("%d/%m/%Y %H:%M:%S")
    )
    sendTelegram(msg)
end

-- ============================================================
-- 💾 SAVE / LOAD
-- ============================================================
local function saveKeyFile_N(key)
    local f = io.open(KEY_FILE_NORMAL, "w")
    if not f then return false end
    f:write(key .. "\n") f:close()
    return true
end
local function loadKeyFile_N()
    local f = io.open(KEY_FILE_NORMAL, "r")
    if not f then return nil end
    local k = f:read("*l") f:close()
    return k
end
local function saveKeyFile_P(key)
    local f = io.open(KEY_FILE_PREMIUM, "w")
    if not f then return false end
    f:write(key .. "\n") f:close()
    return true
end
local function loadKeyFile_P()
    local f = io.open(KEY_FILE_PREMIUM, "r")
    if not f then return nil end
    local k = f:read("*l") f:close()
    return k
end

-- ============================================================
-- 🔐 VALIDATE NORMAL
-- ============================================================
local function validateKey_Normal()
    local nowIST = getIST()
    local savedKey = loadKeyFile_N()

    if savedKey then
        local info = KEY_DB[savedKey]
        if not info then
            gg.alert("❌ Saved key invalid!")
            os.remove(KEY_FILE_NORMAL)
            return false
        end
        local expireAt = makeIST(info.day, info.month, info.year)
        local expireStr = string.format("%02d/%02d/%04d 23:59:59 IST", info.day, info.month, info.year)
        if nowIST >= expireAt then
            gg.alert("⛔ KEY EXPIRED ⛔\n\nKey: " .. savedKey .. "\nExpiry: " .. expireStr .. "\n\nBuy: @GRANDMOBILEHACK")
            gg.copyText("https://t.me/GRANDMOBILEHACK")
            os.remove(KEY_FILE_NORMAL)
            os.exit() gg.exit()
            return false
        end
        local remain = expireAt - nowIST
        gg.toast("✅ KEY VALID\n⏳ " .. formatRemaining(remain) .. "\n📅 " .. expireStr)
        reportStart(savedKey, "NORMAL")
        return true
    end

    local input = gg.prompt({"🔐 ENTER NORMAL KEY:\n(COPY NORMAL KEY AND PASTE HERE)"}, {""}, {"text"})
    if not input or not input[1] or input[1] == "" then
        -- ★ CHANGED: log empty/cancel attempt
        reportFakeKey("(empty/cancelled)", "NORMAL", "Empty or cancelled input")
        gg.alert("❌ Key required!\nBuy from @GRANDMOBILEHACK")
        gg.copyText("https://t.me/GRANDMOBILEHACK")
        os.exit() gg.exit()
        return false
    end
    local key = input[1]:upper():gsub("%s", "")
    local info = KEY_DB[key]
    if not info then
        -- ★ CHANGED: log invalid key attempt
        reportFakeKey(key, "NORMAL", "INVALID KEY (not in database)")
        gg.alert("❌ INVALID KEY!\n\nKey: " .. key .. "\n\nBuy: @GRANDMOBILEHACK")
        gg.copyText("https://t.me/GRANDMOBILEHACK")
        os.exit() gg.exit()
        return false
    end
    local expireAt = makeIST(info.day, info.month, info.year)
    if nowIST >= expireAt then
        -- ★ CHANGED: log expired key attempt
        reportFakeKey(key, "NORMAL", "EXPIRED KEY used")
        gg.alert("⛔ THIS KEY IS ALREADY EXPIRED!")
        os.exit() gg.exit()
        return false
    end
    saveKeyFile_N(key)
    local expireStr = string.format("%02d/%02d/%04d 23:59:59 IST", info.day, info.month, info.year)
    local remain = expireAt - nowIST
    gg.alert("✅ KEY ACTIVATED! ✅\n\nKey: " .. key .. "\nExpires: " .. expireStr .. "\nRemaining: " .. formatRemaining(remain))
    -- ★ CHANGED: pass remaining string to activation report
    reportActivation(key, expireStr, "NORMAL", formatRemaining(remain))
    return true
end

-- ============================================================
-- 👑 VALIDATE PREMIUM (saved key check only)
-- ============================================================
local function validateKey_Premium()
    local nowIST = getIST()
    local savedKey = loadKeyFile_P()

    if savedKey then
        local info = KEY_DB_PREMIUM[savedKey]
        if not info then
            os.remove(KEY_FILE_PREMIUM)
            return false
        end
        local expireAt = makeIST(info.day, info.month, info.year)
        if nowIST >= expireAt then
            os.remove(KEY_FILE_PREMIUM)
            return false
        end
        reportStart(savedKey, "PREMIUM")
        return true
    end
    return false
end

if not validateKey_Normal() then return end

-- ============================================================
-- END KEY SYSTEM
-- ============================================================

local __sleep = gg.sleep
gg.sleep = function(ms)
    if checkExpiry() then return end
    return __sleep(ms)
end

function allah666()
    os.exit() gg.exit()
    local n=nil; _G=n; package=n; debug=n; string=n; table=n; math=n
    local s
    if gg and gg.sleep then s=gg.sleep end
    gg=n; os=n
    if s then while true do s(1e9) end end
    local f
    f=function() return f() end
    f()
end

function abc() gg.toast("[ 💚 ] ACTIVATED [ 💚 ]") end
function cba() gg.toast("[ 💤 ] DEACTIVATED [ 💤 ]") end
function qwea() gg.toast("[ 🔎 ] VALUE NOT FOUND [ 😯 ]") end

fg = {} Write = {} fg.clean = gg.clearResults
Z = {} ts = gg.toast alert = gg.alert
Result = nil data = {}

A=32 As=524288 B=131072 Xa=16384 Xs=32768
Ca=4 Cb=16 Cd=8 Ch=1
J=65536 Jh=2 O=-2080896 Ps=262144
S=64 V=1048576 F=16 D=4 E=64
Q=32 W=2 X=8 Byte=1

function setvalue(add, value, flags, dj)
    local WY = {{address=add, value=value, flags=flags}}
    if dj == true then WY[1].freeze = true gg.addListItems(WY)
    else gg.setValues(WY) end
end

function Z.S(num, ty, nc, mb, qs, zd)
    gg.clearResults()
    gg.setRanges(nc)
    gg.searchNumber(num, ty, false, gg.SIGN_EQUAL, qs or 1, zd or -1)
    if mb ~= nil and mb ~= false and mb then gg.refineAddress(mb) end
    Result = gg.getResults(gg.getResultCount())
end

function Z.C(num, C, ty)
    if (Result and #Result ~= 0) then
        local t = {}
        for i, v in ipairs(Result) do t[i] = {address=v.address+C, flags=ty} end
        t = gg.getValues(t)
        for i, v in ipairs(t) do if v.value ~= num then Result[i] = nil end end
        local Z2 = {}
        for i, v in pairs(Result) do Z2[#Z2+1] = v end
        Result = Z2
    end
end

function Z.bc()
    data = {}
    if Result == nil or #Result == 0 then gg.toast("VALUE NOT FOUND 😯")
    else
        for i, v in pairs(Result) do data[#data+1] = v.address end
        gg.loadResults(Result)
    end
    Result = nil
end

function Z.W(nn, off, ty, dj)
    if (Result) then Z.bc() end
    if #data > 0 then
        for i, v in ipairs(data) do
            local val = nn
            if val == "" then
                local t = {{address=v+off, flags=ty}}
                t = gg.getValues(t)
                val = t[1].value
            end
            setvalue(v+off, val, ty, dj or false)
        end
    end
end

function Z.pt(read, write, Memory, name)
    fg.clean()
    gg.setRanges(Memory)
    gg.searchNumber(read[1][1], read[1][2])
    if gg.getResultCount() == 0 then ts((name or "1").."lord_zerox") return false
    elseif read[1][4] then gg.refineAddress(read[1][4]) end
    if gg.getResultCount() == 0 then ts((name or "").."lord_zerox") return false
    else
        local R = gg.getResults(gg.getResultCount())
        fg.clean()
        local off = read[1][3]
        for i = 2, #read do
            local tmp = {}
            local offset = read[i][3] - off
            for k, v in ipairs(R) do tmp[#tmp+1] = {address=v.address+offset, flags=read[i][2]} end
            tmp = gg.getValues(tmp)
            for s, v in ipairs(tmp) do
                if (tostring(v.value) ~= tostring(read[i][1])) then R[s] = nil end
            end
            local Z2 = {}
            for _, Fv in pairs(R) do Z2[#Z2+1] = Fv end
            R = Z2
        end
        if #R > 0 then
            local MG = {}
            for i, v in ipairs(R) do MG[#MG+1] = v.address end
            for i, v in ipairs(MG) do
                for _, Wr in ipairs(write) do
                    setvalue(v+Wr[3], Wr[1], Wr[2], Wr[4] or false)
                end
            end
            ts((name or "").."lord_zerox")
        else ts((name or "lord_zerox").."lord_zerox") return false end
    end
end

function Z.A(varName, offset, baseAddr)
    if not baseAddr then
        local results = gg.getResults(9999)
        if #results == 0 then gg.clearResults() qwea() return end
        baseAddr = results[1].address
    end
    local targetAddr = baseAddr + (offset or 0)
    if varName and type(varName) == "string" then _G[varName] = targetAddr end
    return targetAddr
end

local target_packages = {"com.grand.cr"}
local function huetaq()
    local ti = gg.getTargetInfo()
    if ti == nil or ti.packageName == nil then return false end
    for i = 1, #target_packages do
        if ti.packageName == target_packages[i] then
            gg.alert("⚠️ WARNING ⚠️\n\nYou selected Grand Mobile process from website/store.")
            gg.copyText("https://play.google.com/store/apps/details?id=com.grand.launcher")
            return true
        end
    end
    return false
end
huetaq()

local __script = { version = "v2.1.0", build = "2025-01-20", author = "@GRANDMOBILEHACK", channel = "https://t.me/GRANDMOBILEHACK" }
local __startTime = os.time()

function __getSessionTime()
    local e = os.time() - __startTime
    local h = math.floor(e / 3600)
    local m = math.floor((e % 3600) / 60)
    local s = e % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local CONFIG_PATH = "/storage/emulated/0/GRANDMOBILE_config.txt"
local __cfg = { lang = "", watermark = true, watermarkColor = true, antiBan = true }

function __saveConfig()
    local f = io.open(CONFIG_PATH, "w")
    if not f then return false end
    for k, v in pairs(__cfg) do f:write(k .. "=" .. tostring(v) .. "\n") end
    f:close() return true
end

function __loadConfig()
    local f = io.open(CONFIG_PATH, "r")
    if not f then return false end
    for line in f:lines() do
        local k, v = line:match("([^=]+)=(.+)")
        if k and v then
            if v == "true" then __cfg[k] = true
            elseif v == "false" then __cfg[k] = false
            else __cfg[k] = v end
        end
    end
    f:close() return true
end

function __resetConfig()
    __cfg.lang = "" __cfg.watermark = true __cfg.watermarkColor = true __cfg.antiBan = true
    __saveConfig() gg.toast("⚙️ Config Reset!")
end

local __currentLang = "EN"
local __lang = { EN = { menu_title = "GRAND MOBILE HACK", wm_text = "MADE BY @GRANDMOBILEHACK", wm_on = "Watermark ON", wm_off = "Watermark OFF", cfg_saved = "Config Saved!", cfg_loaded = "Config Loaded!", shot_saved = "Screenshot Saved!" } }
function __t(key) return __lang.EN[key] or key end

local __wm_colors = {"🔴","🟠","🟡","🟢","🔵","🟣","⚫","⚪"}
local __wm = { lastTime=0, interval=4, enabled=true, colorIndex=1, colorMode=true }

function __showWatermark()
    if not __wm.enabled then return end
    local now = os.time()
    if now - __wm.lastTime >= __wm.interval then
        __wm.lastTime = now
        local txt = __t("wm_text")
        if __wm.colorMode then
            local c = __wm_colors[__wm.colorIndex]
            gg.toast(c .. "💧" .. txt .. "💧" .. c)
            __wm.colorIndex = __wm.colorIndex + 1
            if __wm.colorIndex > #__wm_colors then __wm.colorIndex = 1 end
        else gg.toast("🟢💧" .. txt .. "💧🟢") end
    end
end

function __toggleWatermark()
    __wm.enabled = not __wm.enabled
    __cfg.watermark = __wm.enabled
    __saveConfig()
    if __wm.enabled then __wm.lastTime=0 gg.toast("🟢💧"..__t("wm_on").."💧🟢")
    else gg.toast("🔴💧 "..__t("wm_off").." 💧🔴") end
    grndmenu()
end

function __antiBan()
    local paths = {"/data/local/tmp/gg.pid","/data/local/tmp/GameGuardian","/sdcard/GameGuardian","/data/data/com.grand.cr/files/gg_detect"}
    for _, p in ipairs(paths) do pcall(os.remove, p) end
    gg.sleep(100)
end

function __screenshot()
    local path = "/sdcard/GRANDMOBILE_" .. os.date("%Y%m%d_%H%M%S") .. ".png"
    os.execute("screencap -p " .. path)
    gg.toast("📸 " .. __t("shot_saved"))
end

function __showVersion()
    gg.alert("📋 SCRIPT INFO\n\nVersion: "..__script.version.."\nBuild: "..__script.build.."\nAuthor: "..__script.author.."\n\nSession: "..__getSessionTime())
end

function __configMenu()
    local c = gg.choice({"💾 Save Config","📂 Load Config","🔄 Reset Config","❌ Back"}, nil, "⚙️ CONFIG MENU")
    if c == 1 then __saveConfig() gg.toast("💾 Saved") __configMenu()
    elseif c == 2 then __loadConfig() gg.toast("📂 Loaded") __configMenu()
    elseif c == 3 then __resetConfig() __configMenu()
    else grndmenu() end
end

local __wmGuard = 0
function __guardWatermark()
    __wmGuard = __wmGuard + 1
    if __wmGuard >= 5000 then
        __wmGuard = 0
        if not __wm.enabled then __wm.enabled = true end
    end
end

__loadConfig()
if __cfg.antiBan then __antiBan() end
gg.toast("🟢 💧 " .. __t("wm_text") .. " 💧 🟢")

function hookPLAYER(q1w, w2e, e3r, r4t)
    Z.S("100.14399719238", F, Ca|O)
    if not Result or #Result == 0 then qwea() return false end
    local off = tonumber(q1w) or 0
    for i, v in ipairs(Result) do setvalue(v.address + off, e3r, w2e, r4t or false) end
    gg.clearResults()
    return true
end

function gm67()
    Z.S("4812096201845506048", Q, Ca|Cd|O)
    Z.W(1700, 0x5DC, F)
    gg.clearResults()
end

function doTeleport(x, y, z)
    Z.S("4575657250219098112", Q, Ca|O)
    if #Result ~= 0 then
        gg.setValues({
            {address=Z.A(nil, 132), flags=F, value=x},
            {address=Z.A(nil, 136), flags=F, value=y},
            {address=Z.A(nil, 140), flags=F, value=z}
        })
        abc()
    else return qwea() end
    gg.clearResults()
end

local function getTargetBit()
    local bit = 32
    local ok, ti = pcall(gg.getTargetInfo)
    if ok and type(ti) == "table" and ti.x64 ~= nil then return ti.x64 and 64 or 32 end
    local ranges = gg.getRangesList()
    if ranges and #ranges > 0 then return (ranges[1].start > 0xFFFFFFFF) and 64 or 32 end
    return bit
end
local bit = getTargetBit()
local bit64 = (bit == 64)

local v = gg.getTargetInfo()
L = v.label
V = v.processName
I = os.date()

menuuuvis = 1
gg.clearResults()
gg.clearList()

-- ============================================================
-- 👑 PREMIUM MENU WITH KEY CHECK
-- ============================================================
function premiumMenu()
    menuuuvis = 0

    if not _G.__premiumUnlocked then
        local savedKey = loadKeyFile_P()
        if not savedKey then
            local input = gg.prompt(
                {"👑 PREMIUM KEY REQUIRED\n\nFormat: COPY PREMIUM KEY PASTE HERE\n\n💡 Don't have one?\n👉 @GRANDMOBILEHACK"},
                {""},
                {"text"}
            )
            if not input or not input[1] or input[1] == "" then
                -- ★ CHANGED: log empty/cancel premium attempt
                reportFakeKey("(empty/cancelled)", "PREMIUM", "Empty or cancelled input")
                showPremiumBuyMenu()
                return
            end
            local key = input[1]:upper():gsub("%s", "")
            local info = KEY_DB_PREMIUM[key]
            if not info then
                -- ★ CHANGED: log invalid premium key attempt
                reportFakeKey(key, "PREMIUM", "INVALID PREMIUM KEY")
                local c = gg.choice({
                    "╔═══════════════════════╗\n  🔑  TRY AGAIN          \n╚═══════════════════════╝",
                    "╔═══════════════════════╗\n  🛒  BUY PREMIUM        \n╚═══════════════════════╝",
                    "  ╔═════════════════════╗\n     ↩️  BACK TO NORMAL   \n  ╚═════════════════════╝"
                }, nil, "❌ INVALID PREMIUM KEY")
                if c == 1 then premiumMenu()
                elseif c == 2 then openBuyPremium()
                else grndmenu() end
                return
            end
            local nowIST = getIST()
            local expireAt = makeIST(info.day, info.month, info.year)
            local expireStr = string.format("%02d/%02d/%04d 23:59:59 IST", info.day, info.month, info.year)
            if nowIST >= expireAt then
                -- ★ CHANGED: log expired premium key attempt
                reportFakeKey(key, "PREMIUM", "EXPIRED PREMIUM KEY")
                gg.alert("⛔ PREMIUM KEY EXPIRED ⛔\n\nKey: "..key.."\nExpired: "..expireStr.."\n\nBuy new: @GRANDMOBILEHACK")
                gg.copyText("https://t.me/GRANDMOBILEHACK")
                showPremiumBuyMenu()
                return
            end
            saveKeyFile_P(key)
            _G.__premiumUnlocked = true
            local remain = expireAt - nowIST
            gg.alert("👑 PREMIUM ACTIVATED! 👑\n\nKey: "..key.."\nExpires: "..expireStr.."\nRemaining: "..formatRemaining(remain))
            -- ★ CHANGED: pass remaining string
            reportActivation(key, expireStr, "PREMIUM", formatRemaining(remain))
        else
            _G.__premiumUnlocked = true
        end
    end

    local p = gg.choice({
        "╔═══════════════════════╗\n  🎯  AIMBOT             \n  └─ Legit • Ultra • Walls\n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚗  VEHICLE            \n  └─ Godmode • Speed     \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎨  GRAPHICS           \n  └─ Brightness • Weather\n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📸  SCREENSHOT         \n  └─ Capture Screen      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  👁️  ESP                \n  └─ FOV • ESP • Chams   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💰  GC / LEVEL         \n  └─ Edit GC • Edit Level\n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎮  FUN MENU           \n  └─ Troll & Fun Features\n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🤖  BOT MENU           \n  └─ Auto-Farm Bots      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💧  WATERMARK          \n  └─ Toggle On/Off       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⚙️  CONFIG             \n  └─ Save • Load • Reset \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📋  VERSION            \n  └─ "..__script.version.."              \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ↩️  BACK             \n  ╚═════════════════════╝"
    }, nil, "👑 PREMIUM HACK MENU")

    if p == 1 then aim() premiumMenu() end
    if p == 2 then car() premiumMenu() end
    if p == 3 then graphicsMenu() premiumMenu() end
    if p == 4 then __screenshot() premiumMenu() end
    if p == 5 then visualy() premiumMenu() end
    if p == 6 then gcinjector() premiumMenu() end
    if p == 7 then funMenu() premiumMenu() end
    if p == 8 then botMenu() premiumMenu() end
    if p == 9 then __toggleWatermark() premiumMenu() end
    if p == 10 then __configMenu() premiumMenu() end
    if p == 11 then __showVersion() premiumMenu() end
    if p == 12 or p == nil then grndmenu() end
end

function showPremiumBuyMenu()
    local c = gg.choice({
        "╔═══════════════════════╗\n  🔑  TRY AGAIN          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ✈️  TELEGRAM           \n  └─ @GRANDMOBILEHACK    \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💬  DISCORD            \n  └─ Join Server         \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ↩️  BACK TO NORMAL   \n  ╚═════════════════════╝"
    }, nil, "🛒 BUY PREMIUM")
    if c == 1 then premiumMenu()
    elseif c == 2 then openBuyPremium()
    elseif c == 3 then openDiscord()
    else grndmenu() end
end

function openBuyPremium()
    local contact = "https://t.me/GRANDMOBILEHACK"
    gg.copyText(contact)
    gg.alert("✈️ TELEGRAM\n\nLink copied!\n\nOpen: @GRANDMOBILEHACK")
    gg.goURL(contact)
    showPremiumBuyMenu()
end

function openDiscord()
    local discordUrl = "https://discord.gg/6CJj78qzw8"
    gg.copyText(discordUrl)
    gg.alert("💬 DISCORD\n\nLink copied!\n\nJoin server to buy premium.")
    gg.goURL(discordUrl)
    showPremiumBuyMenu()
end

-- ============================================================
function grndmenu()
    menuuuvis = 0
    local Grandmobilehack = gg.choice({
        "╔═══════════════════════╗\n  👑  PREMIUM H@CK MENU      \n  └─ All premium options \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🌍  TELEPORT MENU          \n  └─ Checkpoint • Marker \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  👤  PLAYER MENU             \n  └─ Godmode • Speed     \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  WEAPON MENU             \n  └─ Give Guns • No Reload\n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🛠️  DEVELOPER INFO         \n  └─ Contact • Socials   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🆘  SUPPORT  US          \n  └─ Donate • Help       \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  EXIT SCRIPT      \n  ╚═════════════════════╝"
    }, nil,
    "╔═══════════════════════════════════════╗\n" ..
    "              🎮  "..__t("menu_title").."  🎮 \n" ..
    "           ────────────────────────── \n" ..
    "  👑  DEV     : "..__script.author.."           \n" ..
    "  📅  DATE    : "..os.date("%d/%m/%Y").."              \n" ..
    "  📱  PROCESS : "..L.." ["..bit.."bit]        \n" ..
    "  🔥  STATUS  : 🟢 ACTIVE                     \n" ..
    "╚═══════════════════════════════════════╝")

    if Grandmobilehack == 1 then premiumMenu() end
    if Grandmobilehack == 2 then tp() end
    if Grandmobilehack == 3 then player() end
    if Grandmobilehack == 4 then gun() end
    if Grandmobilehack == 5 then dev() end
    if Grandmobilehack == 6 then helpq() end
    if Grandmobilehack == 7 then exit() end
    menuuuvis = -1
end

-- ============================================================
-- FUN MENU
-- ============================================================
local ultraJump="❌ " delTex="❌ " freezePos="❌ " carBoom="❌ " sharpTurn="❌ " gravLow="❌ " gravZero="❌ "

function funMenu()
    menuuuvis = 0
    local f = gg.choice({
        "╔═══════════════════════╗\n  🦘  ULTRA JUMP  "..ultraJump.."   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🗑️  DEL TEXTURE  "..delTex.."   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🧊  FREEZE POS  "..freezePos.."   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💥  CAR BOOM  "..carBoom.."     \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔄  SHARP TURN  "..sharpTurn.."   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🌌  GRAVITY LOW  "..gravLow.."   \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚀  GRAVITY ZERO  "..gravZero.."  \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🎮 FUN & TROLL MENU")
    if not f or f == 8 then return grndmenu() end
    if f == 1 then toggleUltraJump() end
    if f == 2 then toggleDelTex() end
    if f == 3 then toggleFreezePos() end
    if f == 4 then toggleCarBoom() end
    if f == 5 then toggleSharpTurn() end
    if f == 6 then toggleGravLow() end
    if f == 7 then toggleGravZero() end
    menuuuvis = -1
end

function toggleUltraJump()
    local s = ultraJump == "❌ "
    ultraJump = s and "✅ " or "❌ "
    Z.S("4798022456217645875", Q, Cd|O)
    Z.W(s and "-150" or "-0.10000000149", -0x4, F)
    gg.clearResults()
    if s then abc() else cba() end
    funMenu()
end

function toggleDelTex()
    local s = delTex == "❌ "
    delTex = s and "✅ " or "❌ "
    gg.clearResults()
    gg.setRanges(gg.REGION_C_DATA|gg.REGION_C_BSS)
    gg.searchNumber('60', gg.TYPE_FLOAT)
    gg.getResults(5000)
    gg.editAll(s and '18.9' or '60', gg.TYPE_FLOAT)
    gg.clearResults()
    if s then abc() else cba() end
    funMenu()
end

function toggleFreezePos()
    local s = freezePos == "❌ "
    freezePos = s and "✅ " or "❌ "
    gg.clearList() gg.clearResults()
    if s then
        Z.S("4575657250219098112", Q, Ca|O)
        Z.W("", 132, F, true)
        Z.W("", 136, F, true)
        Z.W("", 140, F, true)
        abc()
    else cba() end
    gg.clearResults() funMenu()
end

function toggleCarBoom()
    local s = carBoom == "❌ "
    carBoom = s and "✅ " or "❌ "
    gg.clearResults()
    gg.setRanges(gg.REGION_C_DATA|gg.REGION_C_BSS)
    gg.searchNumber(s and "1132068864" or "1148862464", gg.TYPE_DWORD)
    gg.getResults(9999)
    gg.editAll(s and "1148862464" or "1132068864", gg.TYPE_DWORD)
    gg.clearResults()
    if s then abc() else cba() end
    funMenu()
end

function toggleSharpTurn()
    local s = sharpTurn == "❌ "
    sharpTurn = s and "✅ " or "❌ "
    Z.S("100.14399719238", F, Ca|O)
    Z.W(s and "65" or "7.5", 28, F, s)
    gg.clearResults()
    if s then abc() else cba() end
    funMenu()
end

function toggleGravLow()
    local s = gravLow == "❌ "
    gravLow = s and "✅ " or "❌ "
    Z.S("-1140649361", Q, Cd|O|Cd)
    Z.W(s and "-1164854368" or "-1140649361", -0x4, D)
    gg.clearResults()
    if s then abc() else cba() end
    funMenu()
end

function toggleGravZero()
    local s = gravZero == "❌ "
    gravZero = s and "✅ " or "❌ "
    Z.S("-1140649361", Q, Cd|O|Cd)
    Z.W(s and "-1164859368" or "-1140649361", -0x4, D)
    gg.clearResults()
    if s then abc() else cba() end
    funMenu()
end

-- ============================================================
-- BOT MENU
-- ============================================================
function botMenu()
    menuuuvis = 0
    local b = gg.choice({
        "╔═══════════════════════╗\n  🏭  TWIX BOT          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🌾  FARM BOT          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📦  SORT BOT          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⛏️  MINE BOT          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎓  CAREER BOT        \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🤖 AUTO-FARM BOTS")
    if not b or b == 6 then return grndmenu() end
    if b == 1 then botTwix() end
    if b == 2 then botFarm() end
    if b == 3 then botSort() end
    if b == 4 then botMine() end
    if b == 5 then botCareer() end
    menuuuvis = -1
end

function botTwix()
    gg.alert("🤖 TWIX BOT\n\n1. Twix factory jao\n2. Job start karo\n3. Bot auto-farm karega")
    gg.sleep(3000)
    for i = 1, 10000 do
        if gg.isVisible() then gg.setVisible(false) return botMenu() end
        gg.clearResults() gg.setRanges(gg.REGION_C_ALLOC|gg.REGION_OTHER)
        gg.searchNumber("4575657250219098112", gg.TYPE_QWORD)
        local y = gg.getResults(1)
        if y and y[1] then
            local z = gg.getValues({{address=y[1].address+140, flags=F}})[1].value
            gg.setValues({{address=y[1].address+140, flags=F, value=z + 100}})
        end
        gg.sleep(2000)
    end
end

function botFarm()
    gg.alert("🤖 FARM BOT")
    gg.sleep(3000)
    for i = 1, 10000 do
        if gg.isVisible() then gg.setVisible(false) return botMenu() end
        Z.S("4575657250219098112", Q, Ca|O)
        if #Result > 0 then
            gg.setValues({
                {address=Result[1].address+132, flags=F, value=950},
                {address=Result[1].address+136, flags=F, value=-910},
                {address=Result[1].address+140, flags=F, value=39}
            })
        end
        gg.clearResults() gg.sleep(5000)
    end
end

function botSort()
    gg.alert("🤖 SORT CENTER BOT")
    gg.sleep(3000)
    for i = 1, 10000 do
        if gg.isVisible() then gg.setVisible(false) return botMenu() end
        Z.S("4575657250219098112", Q, Ca|O)
        if #Result > 0 then
            gg.setValues({
                {address=Result[1].address+132, flags=F, value=801},
                {address=Result[1].address+136, flags=F, value=1353},
                {address=Result[1].address+140, flags=F, value=14}
            })
        end
        gg.clearResults() gg.sleep(5000)
    end
end

function botMine()
    gg.alert("🤖 MINE BOT")
    gg.sleep(3000)
    for i = 1, 10000 do
        if gg.isVisible() then gg.setVisible(false) return botMenu() end
        Z.S("4575657250219098112", Q, Ca|O)
        if #Result > 0 then
            gg.setValues({
                {address=Result[1].address+132, flags=F, value=-1109},
                {address=Result[1].address+136, flags=F, value=1363},
                {address=Result[1].address+140, flags=F, value=31.5}
            })
        end
        gg.clearResults() gg.sleep(5000)
    end
end

function botCareer()
    gg.alert("🤖 CAREER BOT")
    gg.sleep(3000)
    for i = 1, 10000 do
        if gg.isVisible() then gg.setVisible(false) return botMenu() end
        Z.S("4575657250219098112", Q, Ca|O)
        if #Result > 0 then
            gg.setValues({
                {address=Result[1].address+132, flags=F, value=-611},
                {address=Result[1].address+136, flags=F, value=1433},
                {address=Result[1].address+140, flags=F, value=12.5}
            })
        end
        gg.clearResults() gg.sleep(5000)
    end
end

-- ============================================================
-- GRAPHICS
-- ============================================================
local rainToggle = "❌ "

function graphicsMenu()
    menuuuvis = 0
    local g = gg.choice({
        "╔═══════════════════════╗\n  🌧️  RAIN  "..rainToggle.."         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ☀️  BRIGHTNESS         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔭  DRAW DISTANCE      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📐  RESOLUTION         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔊  VOLUME             \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🎨 GRAPHICS MENU")
    if not g or g == 6 then return grndmenu() end
    if g == 1 then toggleRain() end
    if g == 2 then changeBrightness() end
    if g == 3 then changeDrawDist() end
    if g == 4 then changeResolution() end
    if g == 5 then changeVolume() end
    menuuuvis = -1
end

function toggleRain()
    local s = rainToggle == "❌ "
    rainToggle = s and "✅ " or "❌ "
    Z.S("4515609228984729600", Q, Cd)
    Z.A("xpos1", -16)
    gg.setValues({{address = xpos1, flags = F, value = s and -0.98383948 or 1.00283849937}})
    gg.clearResults()
    if s then abc() else cba() end
    graphicsMenu()
end

function changeBrightness()
    local p = gg.prompt({"Enter brightness [1;300]"}, {"100"}, {"number"})
    if not p then return graphicsMenu() end
    local x = gg.getRangesList("libgrand.so")
    if x and #x > 0 then
        for i, r in ipairs(x) do
            if r.state == "Cd" or r.state == "Cb" then
                gg.setValues({{address = r.start + 0x2EDC8, flags = D, value = tonumber(p[1])}})
                break
            end
        end
    end
    gg.toast("✅ Brightness: "..p[1])
    graphicsMenu()
end

function changeDrawDist()
    local p = gg.prompt({"Enter draw distance [1;500]"}, {"500"}, {"number"})
    if not p then return graphicsMenu() end
    local x = gg.getRangesList("libgrand.so")
    if x and #x > 0 then
        for i, r in ipairs(x) do
            if r.state == "Cd" or r.state == "Cb" then
                gg.setValues({{address = r.start + 0x2EB98, flags = D, value = tonumber(p[1])}})
                break
            end
        end
    end
    gg.toast("✅ Draw Distance: "..p[1])
    graphicsMenu()
end

function changeResolution()
    local p = gg.prompt({"Enter resolution [1;500]"}, {"100"}, {"number"})
    if not p then return graphicsMenu() end
    local x = gg.getRangesList("libgrand.so")
    if x and #x > 0 then
        for i, r in ipairs(x) do
            if r.state == "Cd" or r.state == "Cb" then
                gg.setValues({{address = r.start + 0x2EB70, flags = D, value = tonumber(p[1])}})
                break
            end
        end
    end
    gg.toast("✅ Resolution: "..p[1])
    graphicsMenu()
end

function changeVolume()
    local p = gg.prompt({"Enter volume [1;300]"}, {"100"}, {"number"})
    if not p then return graphicsMenu() end
    local x = gg.getRangesList("libgrand.so")
    if x and #x > 0 then
        for i, r in ipairs(x) do
            if r.state == "Cd" or r.state == "Cb" then
                gg.setValues({{address = r.start + 0x2ED00, flags = D, value = tonumber(p[1])}})
                break
            end
        end
    end
    gg.toast("✅ Volume: "..p[1])
    graphicsMenu()
end

-- ============================================================
-- GC / LEVEL
-- ============================================================
local gcmoney = "❌ " lvlexp = "❌ "

function gcinjector()
    menuuuvis = 0
    local gcinj = gg.choice({
        "╔═══════════════════════╗\n  💰  GIVE GC            \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📊  GIVE LEVEL         \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "💰 GC / LEVEL EDITOR")
    if not gcinj or gcinj == 3 then grndmenu() end
    if gcinj == 1 then givegc() end
    if gcinj == 2 then givelevel() end
    menuuuvis = -1
end

function givegc()
    if gcmoney == "❌ " then
        gcmoney = "✅ "
        gg.clearResults() gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC)
        local input = gg.prompt({'Current GC:','Desired GC:'}, {'0','999999'}, {'number','number'})
        if not input then gcinjector() return end
        local current = tonumber(input[1]) local desired = tonumber(input[2])
        if not current or not desired then gg.alert('Invalid!') gcinjector() return end
        gg.searchNumber(current, gg.TYPE_DWORD)
        gg.refineNumber(current, gg.TYPE_DWORD)
        gg.refineNumber(current, gg.TYPE_DWORD)
        gg.getResults(9999) gg.editAll(desired, gg.TYPE_DWORD)
        gg.clearResults() abc() gcinjector()
    else gcmoney = "❌ " cba() gcinjector() end
end

function givelevel()
    if lvlexp == "❌ " then
        lvlexp = "✅ "
        gg.clearResults() gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC)
        local input = gg.prompt({'Current level:','Desired level:'}, {'1','100'}, {'number','number'})
        if not input then gcinjector() return end
        local curLvl = tonumber(input[1]) local newLvl = tonumber(input[2])
        if not curLvl or not newLvl then gg.alert('Invalid!') gcinjector() return end
        gg.searchNumber(curLvl, gg.TYPE_DWORD)
        gg.refineNumber(curLvl, gg.TYPE_DWORD)
        gg.getResults(9999) gg.editAll(newLvl, gg.TYPE_DWORD)
        gg.clearResults() abc() gcinjector()
    else lvlexp = "❌ " cba() gcinjector() end
end

-- ============================================================
-- ESP
-- ============================================================
local chamsiwhite="❌ " chamsired="❌ " fovv="❌ " esplol="❌ " invwal="❌ "

function visualy()
    menuuuvis = 0
    local visuall = gg.choice({
        "╔═══════════════════════╗\n  👁️  ESP NICK  "..esplol.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⚪  WHITE CHAMS  "..chamsiwhite.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔴  RED CHAMS  "..chamsired.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔭  WIDE FOV  "..fovv.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔑  CHANGE LOGIN       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📝  CHANGE NICK        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚪  INVISIBLE WALL  "..invwal.."  \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "👁️ ESP MENU")
    if not visuall then grndmenu() end
    if visuall == 1 then esphack() end
    if visuall == 2 then chamsw() end
    if visuall == 3 then chamsr() end
    if visuall == 4 then fov() end
    if visuall == 5 then chanlog() end
    if visuall == 6 then channick() end
    if visuall == 7 then inviswall() end
    if visuall == 8 then grndmenu() end
    menuuuvis = -1
end

function chamsw()
    local s = chamsiwhite == "❌ "
    chamsiwhite = s and "✅ " or "❌ "
    Z.S("1132462073", Q, Cd|O)
    Z.W(s and 1.999111188 or 0.00392156886, -4, F)
    gg.clearResults()
    if s then abc() else cba() end
    visualy()
end

function chamsr()
    local s = chamsired == "❌ "
    chamsired = s and "✅ " or "❌ "
    Z.S("1132462073", Q, Cd|O)
    Z.W(s and -1.999111188 or 0.00392156886, -4, F)
    gg.clearResults()
    if s then abc() else cba() end
    visualy()
end

function fov()
    local s = fovv == "❌ "
    fovv = s and "✅ " or "❌ "
    Z.S("4252262742350898174", Q, Cd|O)
    Z.W(s and "90" or "70", 0xC, F)
    gg.clearResults()
    if s then abc() else cba() end
    visualy()
end

function esphack()
    local s = esplol == "❌ "
    esplol = s and "✅ " or "❌ "
    Z.S("5638878673340727297", Q, A|O)
    Z.W(s and "199.90909090909" or "30.0101010101", -60, F)
    Z.W(s and "199.90909090909" or "30.0101010101", -56, F)
    gg.clearResults()
    if s then abc() else cba() end
    visualy()
end

function inviswall()
    local s = invwal == "❌ "
    invwal = s and "✅ " or "❌ "
    Z.S("77190601328179", Q, Xa|O|Cd)
    Z.W(s and -4.99384990408 or 0.90375937, 0x14, F)
    gg.clearResults()
    if s then abc() else cba() end
    visualy()
end

function channick()
    local i1 = gg.prompt({"Current nick:"}, {"Nick"}, {"text"})
    if not i1 then return visualy() end
    local i2 = gg.prompt({"Desired nick:"}, {"Nick"}, {"text"})
    if not i2 then return visualy() end
    gg.clearResults() gg.setRanges(Jh|A)
    gg.searchNumber(":"..i1[1], Byte)
    if gg.getResultCount() > 0 then
        gg.getResults(99999) gg.editAll(":"..i2[1], Byte) abc()
    else qwea() end
    gg.clearResults() visualy()
end

function chanlog()
    local i1 = gg.prompt({"Current login:"}, {"login"}, {"text"})
    if not i1 then return visualy() end
    local i2 = gg.prompt({"Desired login:"}, {"login"}, {"text"})
    if not i2 then return visualy() end
    gg.clearResults() gg.setRanges(Jh|A)
    gg.searchNumber(":"..i1[1], Byte)
    if gg.getResultCount() > 0 then
        gg.getResults(99999) gg.editAll(":"..i2[1], Byte) abc()
    else qwea() end
    gg.clearResults() visualy()
end

-- ============================================================
-- VEHICLE
-- ============================================================
local frzcarcrd="❌ " gmcarchik="❌ " shcar="❌ " mopsh="❌ " nitr="❌ " gidraa="❌ " upmotor="❌ " perevorot1="❌ " carkoles1="❌ "

function car()
    menuuuvis = 0
    local mashinka = gg.choice({
        "╔═══════════════════════╗\n  🛡️  GODMODE CAR  "..gmcarchik.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ❤️  RESTORE HEALTH     \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💥  BREAK CAR          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⬆️  THROW UP           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⬇️  THROW DOWN         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📏  CHANGE HEIGHT      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🧊  FREEZE POS  "..frzcarcrd.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💨  GIVE NITRO  "..nitr.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔧  HYDRAULICS  "..gidraa.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⚡  SPEED HACK  "..shcar.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🛵  ACCEL MOPED  "..mopsh.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚀  LAUNCH TO SPACE    \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⚙️  ENGINE UPGRADE  "..upmotor.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎯  ANTI-ROLLOVER  "..perevorot1.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🛞  PUT ON WHEELS  "..carkoles1.."  \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🚗 VEHICLE MENU")
    if not mashinka or mashinka == 16 then grndmenu() end
    if mashinka == 1 then gmcarq() end
    if mashinka == 2 then hpcarq() end
    if mashinka == 3 then breakcar() end
    if mashinka == 4 then flipcarup() end
    if mashinka == 5 then flipcardown() end
    if mashinka == 6 then changevysot() end
    if mashinka == 7 then freezcordcar() end
    if mashinka == 8 then nitrolol() end
    if mashinka == 9 then gidra() end
    if mashinka == 10 then shcars() end
    if mashinka == 11 then mopedsh() end
    if mashinka == 12 then kosmos() end
    if mashinka == 13 then carupmotor() end
    if mashinka == 14 then perevorot() end
    if mashinka == 15 then carkoles() end
    menuuuvis = -1
end

function freezcordcar()
    if frzcarcrd == "❌ " then
        frzcarcrd = "✅ "
        gg.clearList() gg.clearResults()
        local a = getSimpleAddresses()
        if not a then frzcarcrd = "❌ " gg.toast("Not found") return car() end
        Z.bc()
        data = {a[3], a[2], a[1]}
        Z.W("", 0, F, true)
        gg.clearResults() abc()
    else frzcarcrd = "❌ " gg.clearList() cba() end
end

function changevysot()
    local a = getSimpleAddresses()
    if not a then gg.toast("Not found") return car() end
    local p = gg.prompt({'Height [-9999;9999]'}, {0}, {'number'})
    if not p then return car() end
    local val = tonumber(p[1])
    if not val then return car() end
    local c = gg.getValues({{address=a[1], flags=F}})
    gg.setValues({{address=a[1], flags=F, value=c[1].value+val}})
    abc() gg.clearResults()
end

function flipcarup()
    local a = getSimpleAddresses()
    if not a then gg.toast("Not found") return car() end
    local c = gg.getValues({{address=a[1], flags=F}})
    gg.setValues({{address=a[1], flags=F, value=c[1].value+7.0}})
    abc() gg.clearResults()
end

function flipcardown()
    local a = getSimpleAddresses()
    if not a then gg.toast("Not found") return car() end
    local c = gg.getValues({{address=a[1], flags=F}})
    gg.setValues({{address=a[1], flags=F, value=c[1].value-7.0}})
    abc() gg.clearResults()
end

function kosmos()
    Z.S("-0.00800000038", F, Cd|Ca|O)
    if #Result > 0 then
        gg.editAll("2.5", F)
        gg.sleep(100)
        gg.editAll("-0.00800000038", F)
        gg.clearResults() abc() car()
    end
end

function _car_logic(state_var, is_on)
    Z.S("4812096201845506048", Q, Ca|O|Cd)
    if is_on then
        Z.W("0", 0x1C, D, true) Z.W("0", 0x20, D, true) abc()
    else
        Z.W("861939648", 0x1C, D, false)
        Z.W("-1315709440", 0x20, D, false) cba()
    end
    gg.clearResults() car()
end

function carkoles()
    carkoles1 = (carkoles1 == "❌ ") and "✅ " or "❌ "
    if carkoles1 == "✅ " then gg.clearList() end
    _car_logic(carkoles1, carkoles1 == "✅ ")
end

function perevorot()
    perevorot1 = (perevorot1 == "❌ ") and "✅ " or "❌ "
    if perevorot1 == "✅ " then gg.clearList() end
    _car_logic(perevorot1, perevorot1 == "✅ ")
end

function shcars()
    local s = shcar == "❌ "
    shcar = s and "✅ " or "❌ "
    Z.S("4575243612898721792", Q, Cd|O)
    Z.W(s and 2.5 or 0.00001, -0x8, F)
    gg.clearResults()
    if s then abc() else cba() end
    car()
end

function gmcarq()
    local s = gmcarchik == "❌ "
    gmcarchik = s and "✅ " or "❌ "
    Z.S("4812096201845506048", Q, Ca|Cd|O)
    Z.W(s and 999999 or 1000, 0x5DC, F)
    gg.clearResults()
    if s then abc() else cba() end
    car()
end

function hpcarq()
    Z.S("4812096201845506048", Q, Ca|Cd|O)
    Z.W(1000, 0x5DC, F)
    gg.clearResults() abc() car()
end

function breakcar()
    Z.S("4812096201845506048", Q, Ca|Cd|O)
    Z.W(20, 0x5DC, F)
    gg.clearResults() abc() car()
end

function gidra()
    local s = gidraa == "❌ "
    gidraa = s and "✅ " or "❌ "
    Z.S("-4647714812178464768", Q, Cd|O|Ca)
    Z.W(s and 655361 or -16777215, 0x160, D, false)
    gg.clearResults()
    if s then abc() else cba() end
    car()
end

function nitrolol()
    local s = nitr == "❌ "
    nitr = s and "✅ " or "❌ "
    gg.clearList()
    Z.S("-4647714812178464768", Q, Cd|O|Ca)
    Z.W(24772608, 0x2C, D, s)
    Z.W(-2145353216, 0x634, D, s)
    if not s then gg.clearList() end
    gg.clearResults()
    if s then abc() else cba() end
    car()
end

function carupmotor()
    local s = upmotor == "❌ "
    upmotor = s and "✅ " or "❌ "
    Z.S("4812096201845506048", Q, Ca|O|Cd)
    Z.W(s and -0.00179999997 or 0.0013, 0x64, F)
    gg.clearResults()
    if s then abc() else cba() end
    car()
end

function mopedsh()
    local s = mopsh == "❌ "
    mopsh = s and "✅ " or "❌ "
    Z.S(s and "4539628425391341620" or "4539628427538825268", Q, Ca|O|Cd)
    gg.editAll(s and "4539628427538825268" or "4539628425391341620", Q)
    gg.clearResults()
    if s then gg.toast("Press brake") abc() else cba() end
    car()
end

-- ============================================================
-- TELEPORT
-- ============================================================
function tp()
    menuuuvis = 0
    local tepeshka = gg.choice({
        "╔═══════════════════════╗\n  📍  TP CHECKPOINT     \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📌  TP MARKER         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚶  TP ON FOOT        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚗  TP BY CAR         \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🌍 TELEPORT MENU")
    if not tepeshka then grndmenu() end
    if tepeshka == 1 then tpcheck() end
    if tepeshka == 2 then tpmetka() end
    if tepeshka == 3 then tpfoot() end
    if tepeshka == 4 then telepik() end
    if tepeshka == 5 then grndmenu() end
    menuuuvis = -1
end

function tpcheck()
    local info = gg.getTargetInfo()
    if info.packageName ~= 'com.grand.cr' then
        gg.alert("Need official launcher")
        gg.copyText("https://grand-mobile.servers4.pro/android/GrandMobile.apk")
        return tp()
    end
    Z.S("4575657250219098112", Q, Ca|O)
    if not Result or #Result == 0 then qwea() return tp() end
    local playerBase = Result[1].address
    local ranges = gg.getRangesList("libgrand.so")
    for i, r in ipairs(ranges) do
        if r.state == "Cd" or r.state == "Cb" then
            local vx = gg.getValues({{address=r.start + 0x136A280, flags=F}})[1].value
            local vy = gg.getValues({{address=r.start + 0x136A284, flags=F}})[1].value
            local vz = gg.getValues({{address=r.start + 0x136A288, flags=F}})[1].value
            gg.setValues({
                {address=playerBase+132, flags=F, value=vx},
                {address=playerBase+136, flags=F, value=vy},
                {address=playerBase+140, flags=F, value=vz+7}
            })
            break
        end
    end
    gg.clearResults() abc()
end

function tpmetka()
    hookPLAYER(-4, F, 350)
    local gV, sV, tI = gg.getValues, gg.setValues, table.insert
    while true do
        fg.clean()
        local C, M = {}, {}
        for _, q in ipairs({"13950255104","5360320512"}) do
            if #C == 0 then
                Z.S(q, Q, O)
                if Result then
                    for _, v in ipairs(Result) do
                        local c = gV({
                            {address=v.address+32, flags=F},
                            {address=v.address+36, flags=F},
                            {address=v.address+40, flags=F},
                            {address=v.address+48, flags=F}
                        })
                        local x, y, z, o = c[1].value, c[2].value, c[3].value, c[4].value
                        if x ~= 0 and y ~= 0 and x > -3000 and x < 3000 and y > -3000 and y < 3000 and z == 0 and o == 1 then
                            tI(C, {x, y})
                            tI(M, string.format("📍 [%d]. X:%.1f Y:%.1f", #C, x, y))
                        end
                    end
                end
            end
        end
        if #C == 0 then qwea() fg.clean() hookPLAYER(-4, F, 100) return tp() end
        tI(M, "Refresh") tI(M, "Back")
        local s = gg.choice(M, nil, "🧭 TP MARKER")
        if not s then
            gg.setVisible(false)
            while not gg.isVisible() do gg.sleep(200) end
        elseif M[s] == "Back" then
            fg.clean() hookPLAYER(-4, F, 100) return tp()
        elseif M[s] == "Refresh" then
        else
            Z.S("4575657250219098112", Q, Ca|O)
            if Result and #Result > 0 then
                local t = {}
                for i, v in ipairs(Result) do t[i] = {address=v.address+140, flags=F} end
                t = gV(t)
                for i, v in ipairs(t) do v.value = v.value + 50 end
                sV(t)
                Z.W(C[s][1], 132, F)
                Z.W(C[s][2], 136, F)
                abc() fg.clean() break
            else qwea() end
        end
    end
end

function tpfoot()
    menuuuvis = 0
    local Grandmobilehack5 = gg.choice({
        "╔═══════════════════════╗\n  🏛️  PUBLIC PLACES      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚉  STATIONS           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🅿️  PARKINGS           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🏛️  GOVERNMENT         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💀  CRIMINAL ORGS      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔰  STARTER JOBS       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💼  JOBS               \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎉  ENTERTAINMENT      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚁  HELI CLUBS         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🛒  BUYERS             \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🏢  BUSINESSES         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎓  CAREERS            \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⭐  MY SPOTS           \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🚶 TELEPORT ON FOOT")
    if not Grandmobilehack5 then tp() end
    if Grandmobilehack5 == 1 then obj() end
    if Grandmobilehack5 == 2 then vokz() end
    if Grandmobilehack5 == 3 then avtos() end
    if Grandmobilehack5 == 4 then goska() end
    if Grandmobilehack5 == 5 then criminal() end
    if Grandmobilehack5 == 6 then rab1() end
    if Grandmobilehack5 == 7 then rab() end
    if Grandmobilehack5 == 8 then funny() end
    if Grandmobilehack5 == 9 then vertclub() end
    if Grandmobilehack5 == 10 then skup() end
    if Grandmobilehack5 == 11 then bizn() end
    if Grandmobilehack5 == 12 then kariery() end
    if Grandmobilehack5 == 13 then prochie() end
    if Grandmobilehack5 == 14 then tp() end
    menuuuvis = -1
end

local karyers = {
    {name='🎓 ARZAMAS', x=-611, y=1433, z=12.50},
    {name='🎓 BATYREVO', x=2605, y=2556, z=12.40},
    {name='🎓 SOUTH', x=2053, y=-700, z=12.40},
}
function kariery()
    local n = {}
    for i, v in ipairs(karyers) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🎓 CAREERS")
    if q == nil or q == #n then return tpfoot() end
    local s = karyers[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local obj_loc = {
    {name='🚗 AUTO SCHOOL', x=486, y=2276, z=12},
    {name='🎖️ MILITARY', x=1915, y=2302, z=15},
    {name='🏦 BANK SOUTH', x=2372, y=-2142, z=23},
    {name='🏦 BANK ARZAMAS', x=-143, y=593, z=12},
    {name='🏦 BANK BATYREVO', x=1850, y=2042, z=16},
    {name='⛘ CHURCH', x=1877, y=1166, z=31},
    {name='🚘 CAR MARKET', x=878, y=2236, z=19},
    {name='📮 POST OFFICE', x=801, y=1349, z=15},
}
function obj()
    local n = {}
    for i, v in ipairs(obj_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🏛️ PUBLIC PLACES")
    if q == nil or q == #n then return tpfoot() end
    local s = obj_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local vokz_loc = {
    {name='🚌 ARZAMAS', x=-561, y=931, z=12},
    {name='🚌 SOUTH', x=2734, y=-2447, z=22},
    {name='🚌 BATYREVO', x=1813, y=2513, z=15},
    {name='🚌 YEDOVO', x=-2478, y=2840, z=37},
    {name='🚆 RAILWAY SOUTH', x=2499, y=-2145, z=22},
    {name='⛴️ SEA ARZAMAS', x=12.8, y=3.4, z=10.2},
}
function vokz()
    local n = {}
    for i, v in ipairs(vokz_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🚉 STATIONS")
    if q == nil or q == #n then return tpfoot() end
    local s = vokz_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local avtos_loc = {
    {name='🅿️ ECONOMY', x=2323, y=-1800, z=22},
    {name='🅿️ COMFORT', x=2217, y=2991, z=14},
    {name='🅿️ PREMIUM', x=602, y=998, z=12},
    {name='🏍️ MOTO', x=340, y=479, z=12.3},
    {name='🅿️ ARZAMAS', x=420, y=584, z=12},
    {name='🅿️ BATYREVO', x=1748, y=2464, z=15},
    {name='🅿️ SOUTH', x=2441, y=-1734, z=23},
    {name='🅿️ YEDOVO', x=-2390, y=2686, z=39.1},
    {name='🔧 STO REACTOR', x=711, y=525, z=13},
}
function avtos()
    local n = {}
    for i, v in ipairs(avtos_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🅿️ PARKINGS")
    if q == nil or q == #n then return tpfoot() end
    local s = avtos_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local goska_loc = {
    {name='🏛️ GOVERNMENT', x=-79, y=839, z=17},
    {name='🎖️ MILITARY', x=1872, y=1723, z=15},
    {name='🏥 HOSPITAL ARZ', x=361, y=1332, z=13},
    {name='🏥 HOSPITAL S', x=2118, y=-2386, z=23},
    {name='📰 NEWS', x=2139, y=-1950, z=20},
    {name='👮 POLICE ARZ', x=153, y=1265, z=12},
    {name='👮 POLICE S', x=2582, y=-2421, z=23},
    {name='🕵️ FSB', x=1896, y=-1995, z=31},
}
function goska()
    local n = {}
    for i, v in ipairs(goska_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🏛️ GOVERNMENT")
    if q == nil or q == #n then return tpfoot() end
    local s = goska_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local criminal_loc = {
    {name='💀 TAMBOV', x=2425, y=-1922, z=22},
    {name='💀 KURGAN', x=2285, y=1369, z=11},
    {name='💀 OREKHOV', x=484, y=747.6, z=12},
    {name='💀 CAUCASUS', x=-2334, y=25, z=21},
    {name='🛒 BLACK MARKET', x=-2249, y=245, z=24.5},
}
function criminal()
    local n = {}
    for i, v in ipairs(criminal_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "💀 CRIMINAL ORGS")
    if q == nil or q == #n then return tpfoot() end
    local s = criminal_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local rab1_loc = {
    {name='🏭 TESLA', x=-2547, y=534, z=9},
    {name='🏭 TWIX', x=2242, y=2146, z=16.2},
    {name='⛏️ MINE', x=-1109, y=1363, z=31.5},
    {name='🌾 FARM', x=950, y=-910, z=39},
    {name='📦 SORT', x=801, y=1353, z=14},
}
function rab1()
    local n = {}
    for i, v in ipairs(rab1_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🔰 STARTER JOBS")
    if q == nil or q == #n then return tpfoot() end
    local s = rab1_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local rab_loc = {
    {name='🚕 TAXI', x=757, y=757, z=11},
    {name='🚌 BUS', x=786, y=750, z=12},
    {name='📮 POSTMAN', x=801, y=1349, z=15},
    {name='🔧 MECHANIC', x=2132, y=-1847, z=20},
    {name='🚛 TRUCKER', sub=true},
    {name='💵 INCASSATOR', x=1775, y=-2285, z=12},
    {name='🛣️ ROAD S', x=2648, y=-1902, z=22},
    {name='🛣️ ROAD ARZ', x=636, y=897, z=12},
    {name='🗑️ GARBAGE', x=-1660, y=-950, z=50},
}
local dalno_loc = {
    {name='📦 CARGO', x=164, y=-464, z=10},
    {name='🚛 TC GRUZKONNEKT', x=-412, y=262, z=13},
    {name='🚛 TC VEKTORGRUZ', x=-1523, y=2481, z=42},
    {name='🚛 TC TRANSGRUZLIZ', x=1847, y=2918, z=12},
    {name='🚛 STATE TC 1', x=2200, y=-862, z=15},
}
function dalnoboi()
    local n = {}
    for i, v in ipairs(dalno_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🚛 TRUCKER")
    if q == nil or q == #n then return rab() end
    local s = dalno_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end
function rab()
    local n = {}
    for i, v in ipairs(rab_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "💼 JOBS")
    if q == nil or q == #n then return tpfoot() end
    local s = rab_loc[q]
    if s.sub then dalnoboi() else doTeleport(s.x, s.y, s.z) end
end

local vert_loc = {
    {name='🚁 SOUTH', x=-2691, y=-1647, z=23},
    {name='🚁 ARZAMAS', x=528, y=1761, z=12},
}
function vertclub()
    local n = {}
    for i, v in ipairs(vert_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🚁 HELI CLUBS")
    if q == nil or q == #n then return tpfoot() end
    local s = vert_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local skup_loc = {
    {name='🛒 SOUTH', x=2331, y=-1989, z=22},
    {name='🛒 ARZAMAS', x=-89, y=961, z=12},
}
function skup()
    local n = {}
    for i, v in ipairs(skup_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🛒 BUYERS")
    if q == nil or q == #n then return tpfoot() end
    local s = skup_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local funny_loc = {
    {name='🎰 CASINO', x=327, y=2762, z=8},
    {name='📦 AUCTION', x=443, y=-393, z=9},
    {name='🎲 BOOKMAKER', x=280, y=2717, z=8},
    {name='🏎️ DRIFT', x=2333, y=1182, z=20},
    {name='🌳 PARK', x=330, y=2670, z=8},
    {name='📜 NOTARY', x=-186, y=636, z=12},
}
function funny()
    local n = {}
    for i, v in ipairs(funny_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🎉 ENTERTAINMENT")
    if q == nil or q == #n then return tpfoot() end
    local s = funny_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local bizn_loc = {
    {name='🏪 24/7 STORE', x=-356, y=-1926.2, z=41.2},
    {name='🏪 24/7 NEAR ARZ', x=16.1, y=264.9, z=41.2},
    {name='🍽️ RESTAURANT', x=-280, y=-1765.3, z=41},
    {name='🔫 WEAPON STORE', x=112.51, y=574.09, z=13.26},
    {name='👕 CLOTHING', x=1945, y=2066, z=15.7},
    {name='⛽ GAS STATION', x=2328, y=-762, z=14},
}
function bizn()
    local n = {}
    for i, v in ipairs(bizn_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "🏢 BUSINESSES")
    if q == nil or q == #n then return tpfoot() end
    local s = bizn_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end

local prochie_loc = {
    {name='⚔️ FAMWAR', sub=true},
    {name='🛡️ ADMIN ZONE', x=-700, y=-2450, z=1201},
    {name='🚔 PRISON', x=-1830, y=-2870, z=45},
    {name='🌲 BV FOREST 1', x=-1092.7, y=-2539.2, z=28.6},
    {name='🌲 BV FOREST 2', x=-1002.8, y=-2497.4, z=28.1},
    {name='📡 TV TOWER', x=2130, y=-1968, z=270},
    {name='🏥 HOSPITAL ROOF', x=382, y=1332, z=128},
    {name='🏛️ GOV ROOF', x=-102, y=817, z=79},
    {name='🎰 CASINO ROOF', x=331, y=2800, z=33},
    {name='🎖️ MIL ROOF', x=1816, y=1792, z=34},
    {name='🏰 KREMLIN', x=-2480, y=1675, z=53},
}
local famwar_loc = {
    {name='🚪 MAIN', x=1501.1, y=-301.6, z=7.3},
    {name='📍 #1', x=1484.3, y=-119.9, z=10.3},
    {name='📍 #2', x=1564.3, y=7.0, z=7.3},
    {name='📍 #3', x=1620.5, y=-144, z=7.3},
    {name='📍 #4', x=1564.2, y=-131.7, z=7.3},
    {name='🏢 ROOF', x=1566.5, y=-200.9, z=25.6},
}
function famwar()
    local n = {}
    for i, v in ipairs(famwar_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "⚔️ FAMWAR")
    if q == nil or q == #n then return prochie() end
    local s = famwar_loc[q]
    if s then doTeleport(s.x, s.y, s.z) end
end
function prochie()
    local n = {}
    for i, v in ipairs(prochie_loc) do n[i] = v.name end
    n[#n+1] = '◀️ BACK'
    local q = gg.choice(n, nil, "⭐ MY SPOTS")
    if q == nil or q == #n then return tpfoot() end
    local s = prochie_loc[q]
    if s.sub then famwar() else doTeleport(s.x, s.y, s.z) end
end

-- CAR POINTS
local file_path = "/storage/emulated/0/cordcar.txt"
function getSimpleAddresses()
    local ti = gg.getTargetInfo()
    if not ti then return nil end
    local file = io.open(file_path, "r")
    if not file then return nil end
    local pid = tonumber(file:read("*l"))
    if pid ~= ti.pid then file:close() return nil end
    local a1 = tonumber(file:read("*l"))
    local a2 = tonumber(file:read("*l"))
    local a3 = tonumber(file:read("*l"))
    file:close()
    if not a1 or not a2 or not a3 then return nil end
    return {a1, a2, a3}
end
function saveAddressesSimple(addr1, addr2, addr3)
    local ti = gg.getTargetInfo()
    if not ti then gg.toast("PID not found") return false end
    if not addr1 or not addr2 or not addr3 then gg.toast("Not found") return false end
    local file = io.open(file_path, "w")
    if not file then gg.toast("Error") return telepik() end
    file:write(ti.pid.."\n"..addr1.."\n"..addr2.."\n"..addr3.."\n")
    file:close()
    gg.toast("Config saved 😘")
    return true
end
function telepik()
    menuuuvis = 0
    local tpcarlol = gg.choice({
        "╔═══════════════════════╗\n  🔍  FIND COORDS        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📍  TP BY COORDS       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📌  TP BY MARKER       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚩  TP CHECKPOINT      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚗  TP CAR TO ME       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚶  TP ME TO CAR       \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🚗 TP BY CAR")
    if not tpcarlol or tpcarlol == 7 then tp() end
    if tpcarlol == 1 then findcarcord() end
    if tpcarlol == 2 then tpcarcord() end
    if tpcarlol == 3 then tpmetkacar() end
    if tpcarlol == 4 then tpcheckpointcar() end
    if tpcarlol == 5 then tpcartoplayer() end
    if tpcarlol == 6 then tpplayertocar() end
end
function tpcarcord()
    local a = getSimpleAddresses()
    if not a then gg.toast("Not found") return telepik() end
    gm67()
    local cur = gg.getValues({{address=a[3], flags=F},{address=a[2], flags=F},{address=a[1], flags=F}})
    local c = gg.prompt({"X:","Y:","Z:"}, {tostring(cur[1].value), tostring(cur[2].value), tostring(cur[3].value)}, {"number","number","number"})
    if not c then return telepik() end
    local x, y, z = tonumber(c[1]), tonumber(c[2]), tonumber(c[3])
    if not x or not y or not z then gg.toast("Invalid") return tpcarcord() end
    local t = {{address=a[3], flags=F},{address=a[2], flags=F},{address=a[1], flags=F}}
    gg.toast("Exit map in 3s")
    gg.sleep(3000)
    t[1].value, t[2].value, t[3].value = 1306.921143, 911.432861, -13.037830
    gg.setValues(t)
    gg.sleep(3700)
    t[1].value, t[2].value, t[3].value = x, y, z
    gg.setValues(t)
    gg.toast("💚 Success 💚")
end
function tpcheckpointcar()
    local a = getSimpleAddresses()
    if not a then gg.toast("Not found") return telepik() end
    local ranges = gg.getRangesList("libgrand.so")
    for i, r in ipairs(ranges) do
        if r.state == "Cd" or r.state == "Cb" then
            local vx = gg.getValues({{address=r.start + 0x136A280, flags=F}})[1].value
            local vy = gg.getValues({{address=r.start + 0x136A284, flags=F}})[1].value
            local vz = gg.getValues({{address=r.start + 0x136A288, flags=F}})[1].value
            local t = {{address=a[3],flags=F},{address=a[2],flags=F},{address=a[1],flags=F}}
            gg.toast("Exit map in 3s")
            gg.sleep(3000)
            t[1].value, t[2].value, t[3].value = 1306.921143, 911.432861, -13.037830
            gg.setValues(t)
            gg.sleep(3500)
            t[1].value, t[2].value, t[3].value = vx, vy, vz
            gg.setValues(t)
            abc()
            break
        end
    end
end
function tpplayertocar()
    local carAddrs = getSimpleAddresses()
    if not carAddrs then gg.toast("Not found!") return telepik() end
    local carCoords = gg.getValues({{address=carAddrs[3], flags=F},{address=carAddrs[2], flags=F},{address=carAddrs[1], flags=F}})
    Z.S("4575657250219098112", Q, Ca|O)
    if not Result or #Result == 0 then gg.clearResults() return qwea() end
    local playerBase = Result[1].address
    gg.setValues({
        {address=playerBase+132, flags=F, value=carCoords[1].value},
        {address=playerBase+136, flags=F, value=carCoords[2].value},
        {address=playerBase+140, flags=F, value=carCoords[3].value}
    })
    gg.clearResults() abc()
end
function tpcartoplayer()
    local carAddrs = getSimpleAddresses()
    if not carAddrs then gg.toast("Not found!") return telepik() end
    Z.S("4575657250219098112", Q, Ca|O)
    if not Result or #Result == 0 then gg.clearResults() return qwea() end
    local playerBase = Result[1].address
    local playerCoords = gg.getValues({
        {address=playerBase+132, flags=F},
        {address=playerBase+136, flags=F},
        {address=playerBase+140, flags=F}
    })
    gg.setValues({
        {address=carAddrs[3], flags=F, value=playerCoords[1].value},
        {address=carAddrs[2], flags=F, value=playerCoords[2].value},
        {address=carAddrs[1], flags=F, value=playerCoords[3].value}
    })
    gg.clearResults() abc()
end
function tpmetkacar()
    local a = getSimpleAddresses()
    if not a then gg.toast("Not found") return telepik() end
    gm67()
    local gV, sV, tI = gg.getValues, gg.setValues, table.insert
    while true do
        gg.clearResults()
        local C, M = {}, {}
        for _, q in ipairs({"13950255104","5360320512"}) do
            if #C == 0 then
                Z.S(q, Q, O)
                if Result then
                    for _, v in ipairs(Result) do
                        local c = gV({
                            {address=v.address+32, flags=F},
                            {address=v.address+36, flags=F},
                            {address=v.address+40, flags=F},
                            {address=v.address+48, flags=F}
                        })
                        local x, y, z, o = c[1].value, c[2].value, c[3].value, c[4].value
                        if x ~= 0 and y ~= 0 and x > -3000 and x < 3000 and y > -3000 and y < 3000 and z == 0 and o == 1 then
                            tI(C, {x, y})
                            tI(M, string.format("📍 [%d]. X:%.1f Y:%.1f", #C, x, y))
                        end
                    end
                end
            end
        end
        if #C == 0 then qwea() gg.clearResults() gm67(1000) return telepik() end
        tI(M, "Refresh") tI(M, "Back")
        local s = gg.choice(M, nil, "🧭 TP MARKER")
        if not s then
            gg.setVisible(false)
            while not gg.isVisible() do gg.sleep(200) end
        elseif M[s] == "Back" then
            gg.clearResults() gm67(1000) return telepik()
        elseif M[s] == "Refresh" then
        else
            local cur = gV({{address=a[1], flags=F}})
            local z = cur[1].value + 50.0
            local t = {{address=a[3],flags=F},{address=a[2],flags=F},{address=a[1],flags=F}}
            gg.toast("Exit map in 3s")
            gg.sleep(3000)
            t[1].value, t[2].value, t[3].value = 1306.921143, 911.432861, -13.037830
            sV(t)
            gg.sleep(3700)
            t[1].value, t[2].value, t[3].value = C[s][1], C[s][2], z
            sV(t)
            gg.toast("💚 Success 💚")
            gg.clearResults() break
        end
    end
end
function findcarcord()
    Z.S("4575657250219098112", Q, Ca|O)
    local baseRes = Result[1]
    if not baseRes then gg.clearResults() qwea() return telepik() end
    local fv = gg.getValues({{address=baseRes.address+140, flags=F}})[1].value
    Z.S((fv-3).."~"..(fv+3), F, Ca|O, false, baseRes.address, baseRes.address+0xCCCCC)
    local allRes = Result
    if #allRes == 0 then qwea() return telepik() end
    gg.toast("Move up or down (7s)")
    gg.sleep(7000)
    local dir1 = gg.choice({"⬆️ UP","⬇️ DOWN"}, nil, "Direction?")
    if not dir1 then gg.clearResults() gg.toast("Canceled") return telepik() end
    local req1 = {}
    for i, v in ipairs(allRes) do req1[i] = {address=v.address, flags=F} end
    local val1 = gg.getValues(req1)
    local f1 = {}
    for i, v in ipairs(allRes) do
        local cur = val1[i].value
        if (dir1 == 1 and cur > v.value) or (dir1 == 2 and cur < v.value) then
            v.value = cur
            table.insert(f1, v)
        end
    end
    if #f1 == 0 then gg.toast("Empty") return telepik() end
    gg.toast("Move again (7s)")
    gg.sleep(7000)
    local dir2 = gg.choice({"⬆️ UP","⬇️ DOWN"}, nil, "Direction?")
    if not dir2 then gg.clearResults() gg.toast("Canceled") return telepik() end
    local req2 = {}
    for i, v in ipairs(f1) do req2[i] = {address=v.address, flags=F} end
    local val2 = gg.getValues(req2)
    local f2 = {}
    for i, v in ipairs(f1) do
        local cur = val2[i].value
        if (dir2 == 1 and cur > v.value) or (dir2 == 2 and cur < v.value) then
            table.insert(f2, v.address)
        end
    end
    if #f2 == 0 then qwea() return telepik() end
    local total = #f2
    local offset = 1
    local finished = false
    while not finished do
        local batchEnd = math.min(offset+9, total)
        local batch = {}
        for i = offset, batchEnd do batch[#batch+1] = f2[i] end
        for idx, addr in ipairs(batch) do
            local oldVal = gg.getValues({{address=addr, flags=F}})[1].value
            gg.setValues({{address=addr, flags=F, value=oldVal+4}})
            gg.toast(string.format("Variant: #%d of %d", idx, #batch))
            gg.sleep(2000)
            batch[idx] = {address=addr, old=oldVal}
        end
        local menu = {}
        for idx, _ in ipairs(batch) do menu[idx] = string.format("%d) Variant", idx) end
        menu[#menu+1] = "Repeat"
        local nextKey = #menu+1
        if batchEnd < total then menu[nextKey] = "Next" end
        local pick = gg.choice(menu, nil, "Choose variant")
        if not pick then
            for _, item in ipairs(batch) do gg.setValues({{address=item.address, flags=F, value=item.old}}) end
            gg.toast("Canceled")
            return telepik()
        end
        if pick <= #batch then
            local sel = batch[pick]
            saveAddressesSimple(sel.address, sel.address-4, sel.address-8)
            abc() finished = true
        elseif pick == nextKey then
            offset = offset + #batch
            if offset > total then gg.toast("End") finished = true end
        end
        for _, item in ipairs(batch) do gg.setValues({{address=item.address, flags=F, value=item.old}}) end
    end
    gg.clearResults()
end

-- ============================================================
-- PLAYER
-- ============================================================
local shv222="❌ " mbq="❌ " gm4="❌ " gm9="❌ " gm5="❌ " suic="❌ " walg="❌ " fastkil="❌ " hjj="❌ " whh="❌ " graviq="❌ " graviqq="❌ "

function player()
    menuuuvis = 0
    local Grandmobilehack2 = gg.choice({
        "╔═══════════════════════╗\n  💨  SPEED HACK  "..shv222.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⚡  SPEED V2  "..mbq.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🛡️  GODMODE  "..gm4.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  💪  GODMODE V2  "..gm9.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🦾  ARMOR NULL  "..gm5.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ❤️  RESTORE HP         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ☠️  SUICIDE  "..suic.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🧱  WALK THRU  "..walg.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⬆️  FLIP UP             \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⬇️  FLIP DOWN           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  👊  FAST KILL  "..fastkil.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🦘  HIGH JUMP  "..hjj.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔄  SHARP TURN  "..whh.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🌌  GRAVITY  "..graviq.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🚀  GRAVITY V2  "..graviqq.."  \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "👤 PLAYER MENU")
    if not Grandmobilehack2 or Grandmobilehack2 == 16 then grndmenu() end
    if Grandmobilehack2 == 1 then shv22() end
    if Grandmobilehack2 == 2 then fovqqq() end
    if Grandmobilehack2 == 3 then gm2() end
    if Grandmobilehack2 == 4 then gm8() end
    if Grandmobilehack2 == 5 then gm3() end
    if Grandmobilehack2 == 6 then hpq() end
    if Grandmobilehack2 == 7 then suicc() end
    if Grandmobilehack2 == 8 then walgh() end
    if Grandmobilehack2 == 9 then flpp() end
    if Grandmobilehack2 == 10 then flpp1() end
    if Grandmobilehack2 == 11 then fastk() end
    if Grandmobilehack2 == 12 then hj() end
    if Grandmobilehack2 == 13 then wh() end
    if Grandmobilehack2 == 14 then gravity() end
    if Grandmobilehack2 == 15 then gravityv2() end
    menuuuvis = -1
end
function gm2()
    local _m = (gm4 == "❌ ")
    if hookPLAYER(-4, F, _m and 505050 or 100) then
        gm4 = _m and "✅ " or "❌ "
        if _m then abc() else cba() end
    end
    gg.clearResults() player()
end
function hj()
    local s = hjj == "❌ "
    hjj = s and "✅ " or "❌ "
    Z.S("4798022456217645875", Q, Cd|O)
    Z.W(s and "-150" or "-0.10000000149", -0x4, F)
    gg.clearResults()
    if s then abc() else cba() end
    player()
end
function fovqqq()
    local _m = (mbq == "❌ ")
    Z.S(_m and "4489188110487257088" or "4489188110498131456", Q, Ca|Cd|O)
    if #Result ~= 0 then
        gg.editAll(_m and "4489188110498131456" or "4489188110487257088", Q)
        mbq = _m and "✅ " or "❌ "
        if _m then abc() else cba() end
    else qwea() end
    gg.clearResults() player()
end
function walgh()
    local _w = (walg == "❌ ")
    Z.S(_w and "1114636288" or "1114767360", Q, Ca|O|Cd)
    if #Result ~= 0 then
        gg.editAll(_w and "1114767360" or "1114636288", Q)
        walg = _w and "✅ " or "❌ "
        if _w then abc() else cba() end
    else qwea() end
    gg.clearResults() player()
end
function fastk()
    local _f = (fastkil == "❌ ")
    Z.S(_f and "9187343240761165228" or "4489188110505082880", Q, Ca|O|Cd)
    if #Result ~= 0 then
        gg.editAll(_f and "4489188110505082880" or "9187343240761165228", Q)
        Z.S(_f and "4489188110487257088" or "4489188110499840000", Q, Ca|O|Cd)
        if #Result ~= 0 then gg.editAll(_f and "4489188110499840000" or "4489188110487257088", Q) end
        fastkil = _f and "✅ " or "❌ "
        if _f then abc() else cba() end
    else qwea() end
    gg.clearResults() player()
end
function gravityv2()
    local s = graviqq == "❌ "
    graviqq = s and "✅ " or "❌ "
    Z.S("-1140649361", Q, Cd|O|Cd)
    Z.W(s and "-1164859368" or "-1140649361", -0x4, D)
    gg.clearResults()
    if s then abc() else cba() end
    player()
end
function gravity()
    local s = graviq == "❌ "
    graviq = s and "✅ " or "❌ "
    Z.S("-1140649361", Q, Cd|O|Cd)
    Z.W(s and "-1164854368" or "-1140649361", -0x4, D)
    gg.clearResults()
    if s then abc() else cba() end
    player()
end
function shv22()
    local s = shv222 == "❌ "
    shv222 = s and "✅ " or "❌ "
    Z.S("4647714816510698455", Q, Cd|O|Ca)
    Z.W(s and "4489188112626352128" or "4489188110482223923", 0x18, Q)
    gg.clearResults()
    if s then abc() else cba() end
    player()
end
function flpp1()
    Z.S("4575657250219098112", Q, Ca|O)
    if #Result ~= 0 then
        local t = {}
        for i, v in ipairs(Result) do t[i] = {address=v.address+140, flags=F} end
        t = gg.getValues(t)
        for i, v in ipairs(t) do v.value = v.value - 7 end
        gg.setValues(t) abc()
    else qwea() end
    gg.clearResults() player()
end
function flpp()
    Z.S("4575657250219098112", Q, Ca|O)
    if #Result ~= 0 then
        local t = {}
        for i, v in ipairs(Result) do t[i] = {address=v.address+140, flags=F} end
        t = gg.getValues(t)
        for i, v in ipairs(t) do v.value = v.value + 7 end
        gg.setValues(t) abc()
    else qwea() end
    gg.clearResults() player()
end
function gm3()
    if gm5 == "❌ " then
        if hookPLAYER(4, F, "9990", true) then gm5 = "✅ " abc() end
    else gm5 = "❌ " gg.clearList() cba() end
    gg.clearResults() player()
end
function gm8()
    local _m = (gm9 == "❌ ")
    if not _m then gg.clearList() end
    if hookPLAYER(-4, F, _m and "9999989.0" or "100", _m) then
        gm9 = _m and "✅ " or "❌ "
        if _m then abc() else cba() end
    end
    player()
end
function hpq() if hookPLAYER(-4, F, 100) then abc() end player() end
function suicc() if hookPLAYER(-4, F, 0) then abc() end player() end
function wh()
    local _w = (whh == "❌ ")
    if not _w then gg.clearList() end
    if hookPLAYER(28, F, _w and "65" or "7.5", _w) then
        whh = _w and "✅ " or "❌ "
        if _w then abc() else cba() end
    end
    player()
end

-- ============================================================
-- WEAPON MENU
-- ============================================================
local shshq="❌ " sc="❌ " fsk="❌ " avty="❌ " alertr="❌ "

function gun()
    menuuuvis = 0
    local Grandmobilehackgun = gg.choice({
        "╔═══════════════════════╗\n  🔫  GIVE WEAPON        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  📦  GIVE AMMO          \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🧹  CLEAR SLOTS        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ❄️  FREEZE SLOTS       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔄  ANTI-RELOAD        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ♾️  INFINITE AMMO      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  ⚡  FIRE RATE +        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎯  AIM SPEED  "..shshq.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🎪  NO SPREAD  "..sc.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🏶  FARM SKILLS  "..fsk.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🤖  ASSIST +C  "..avty.."  \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔥  FIRE + SPEED  "..alertr.."  \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🔫 WEAPON MENU")
    if not Grandmobilehackgun or Grandmobilehackgun == 13 then grndmenu() end
    if Grandmobilehackgun == 1 then givegun() end
    if Grandmobilehackgun == 2 then dupept() end
    if Grandmobilehackgun == 3 then cleanslot() end
    if Grandmobilehackgun == 4 then freezeslot() end
    if Grandmobilehackgun == 5 then antirelo() end
    if Grandmobilehackgun == 6 then besk() end
    if Grandmobilehackgun == 7 then rapidik() end
    if Grandmobilehackgun == 8 then shlool() end
    if Grandmobilehackgun == 9 then scat() end
    if Grandmobilehackgun == 10 then farmsk() end
    if Grandmobilehackgun == 11 then avtoq() end
    if Grandmobilehackgun == 12 then scor2() end
    menuuuvis = -1
end
function rapidik()
    local p = gg.prompt({"Speed [0.3;0.9]"}, nil, {"number"})
    if not p then return gun() end
    Z.S("4584664420663165927", Q, Ca|O|Cd)
    if #Result > 0 then
        local offs = {16, 28, 240, 252}
        for _, o in ipairs(offs) do Z.W(p[1], o, F) end
        abc()
    else qwea() end
    fg.clean() gun()
end
function shlool()
    if shshq == "❌ " then
        shshq = "✅ "
        local p = gg.prompt({"Speed [1;100]"}, nil, {"number"})
        if not p then return gun() end
        Z.S("4584664420663165927", Q, Ca|O|Cd)
        Z.W(p[1], 8, F)
        Z.W(p[1], 232, F)
        abc()
    else
        shshq = "❌ "
        Z.S("4584664420663165927", Q, Ca|O|Cd)
        Z.W(1.2, 8, F) Z.W(1.2, 232, F) cba()
    end
    fg.clean() gun()
end
function scat()
    local _c = (sc == "❌ ")
    local _o, _m = "1120403456", "1119748096"
    Z.S(_c and _o or _m, D, Ca|O|Cd)
    if #Result ~= 0 then
        gg.editAll(_c and _m or _o, D)
        if _c then sc = "✅ " gg.clearResults() abc() else sc = "❌ " gg.clearResults() cba() end
    else gg.clearResults() qwea() end
    gun()
end
function farmsk()
    local _f = (fsk == "❌ ")
    local _o, _m = "4 489 188 110 487 257 088", "4 489 188 110 535 131 456"
    Z.S(_f and _o or _m, Q, Ca|O|Cd)
    if #Result ~= 0 then
        gg.editAll(_f and _m or _o, Q)
        if _f then fsk = "✅ " gg.clearResults() abc() else fsk = "❌ " gg.clearResults() cba() end
    else gg.clearResults() qwea() end
    gun()
end
function avtoq()
    local _a = (avty == "❌ ")
    local _o, _m = "4 489 188 110 487 257 088", "4 489 188 110 489 300 000"
    Z.S(_a and _o or _m, Q, Ca|O|Cd)
    if #Result ~= 0 then
        gg.editAll(_a and _m or _o, Q)
        if _a then avty = "✅ " gg.clearResults() abc() else avty = "❌ " gg.clearResults() cba() end
    else gg.clearResults() qwea() end
    gun()
end
function scor2()
    local _s = (alertr == "❌ ")
    local _o, _m = "4 489 188 110 487 257 088", "4 489 188 110 516 131 456"
    Z.S(_s and _o or _m, Q, Ca|O|Cd)
    if #Result ~= 0 then
        gg.editAll(_s and _m or _o, Q)
        if _s then alertr = "✅ " gg.clearResults() abc() else alertr = "❌ " gg.clearResults() cba() end
    else gg.clearResults() qwea() end
    gun()
end
function cleanslot()
    if not hookPLAYER("+192", D, 0, false) then return gun() end
    hookPLAYER("+256", D, 0, false)
    hookPLAYER("+288", D, 0, false)
    hookPLAYER("+224", D, 0, false)
    hookPLAYER("+320", D, 0, false)
    hookPLAYER("+352", D, 0, false)
    abc() gun()
end

local relodgper="❌ " relom4per="❌ " reloakper="❌ " relompper="❌ "

function antirelo()
    menuuuvis = 0
    local Grandmobilehack66666 = gg.choice({
        "╔═══════════════════════╗\n  🔫  DEAGLE  "..relodgper.."       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  M4  "..relom4per.."           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  AK-47  "..reloakper.."        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  MP5  "..relompper.."          \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🔄 ANTI-RELOAD")
    if not Grandmobilehack66666 or Grandmobilehack66666 == 5 then gun() end
    if Grandmobilehack66666 == 1 then antirelodg() end
    if Grandmobilehack66666 == 2 then antirelom4() end
    if Grandmobilehack66666 == 3 then antireloak() end
    if Grandmobilehack66666 == 4 then antirelomp() end
    menuuuvis = -1
end
function antirelomp()
    if relompper == "❌ " then
        gg.clearList()
        if not hookPLAYER("+264", D, 67, true) then return gun() end
        relompper = "✅ " abc()
    else relompper = "❌ " gg.clearList() cba() end
    gun()
end
function antireloak()
    if reloakper == "❌ " then
        gg.clearList()
        if not hookPLAYER("+296", D, 67, true) then return gun() end
        reloakper = "✅ " abc()
    else reloakper = "❌ " gg.clearList() cba() end
    gun()
end
function antirelom4()
    if relom4per == "❌ " then
        gg.clearList()
        if not hookPLAYER("+296", D, 67, true) then return gun() end
        relom4per = "✅ " abc()
    else relom4per = "❌ " gg.clearList() cba() end
    gun()
end
function antirelodg()
    if relodgper == "❌ " then
        gg.clearList()
        if not hookPLAYER("+200", D, 67, true) then return gun() end
        relodgper = "✅ " abc()
    else relodgper = "❌ " gg.clearList() cba() end
    gun()
end

local bdg="❌ " bmka="❌ " bkal="❌ " bdrobq="❌ " bmp5q="❌ "

function besk()
    menuuuvis = 0
    local Grandmobilehack313 = gg.choice({
        "╔═══════════════════════╗\n  🔫  DEAGLE  "..bdg.."        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  M4  "..bmka.."            \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  AK-47  "..bkal.."         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SHOTGUN  "..bdrobq.."      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  MP5  "..bmp5q.."          \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "♾️ INFINITE AMMO")
    if not Grandmobilehack313 or Grandmobilehack313 == 6 then gun() end
    if Grandmobilehack313 == 1 then bdgq() end
    if Grandmobilehack313 == 2 then bmkk() end
    if Grandmobilehack313 == 3 then bkalq() end
    if Grandmobilehack313 == 4 then bdrobe() end
    if Grandmobilehack313 == 5 then bmpsh() end
    menuuuvis = -1
end
function bdgq()
    if bdg == "❌ " then
        gg.clearList()
        if not hookPLAYER("+204", D, "", true) then return gun() end
        bdg = "✅ " abc()
    else bdg = "❌ " gg.clearList() cba() end
    gun()
end
function bmkk()
    if bmka == "❌ " then
        gg.clearList()
        if not hookPLAYER("+300", D, "", true) then return gun() end
        bmka = "✅ " abc()
    else bmka = "❌ " gg.clearList() cba() end
    gun()
end
function bkalq()
    if bkal == "❌ " then
        gg.clearList()
        if not hookPLAYER("+300", D, "", true) then return gun() end
        bkal = "✅ " abc()
    else bkal = "❌ " gg.clearList() cba() end
    gun()
end
function bmpsh()
    if bmp5q == "❌ " then
        gg.clearList()
        if not hookPLAYER("+268", D, "", true) then return gun() end
        bmp5q = "✅ " abc()
    else bmp5q = "❌ " gg.clearList() cba() end
    gun()
end
function bdrobe()
    if bdrobq == "❌ " then
        gg.clearList()
        if not hookPLAYER("+224", D, "", true) then return gun() end
        bdrobq = "✅ " abc()
    else bdrobq = "❌ " gg.clearList() cba() end
    gun()
end

function dupept()
    menuuuvis = 0
    local Grandmobilehack6666 = gg.choice({
        "╔═══════════════════════╗\n  🔫  DEAGLE             \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  GLOCK              \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  M4                 \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  AK-47              \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  MP5                \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SNIPER             \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SHOTGUN            \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "📦 GIVE AMMO")
    if not Grandmobilehack6666 or Grandmobilehack6666 == 8 then gun() end
    if Grandmobilehack6666 == 1 then dupedg() end
    if Grandmobilehack6666 == 2 then dupeglock() end
    if Grandmobilehack6666 == 3 then dupem4() end
    if Grandmobilehack6666 == 4 then dupeak() end
    if Grandmobilehack6666 == 5 then dupemp() end
    if Grandmobilehack6666 == 6 then dupevint() end
    if Grandmobilehack6666 == 7 then dupeshotik() end
    menuuuvis = -1
end
function dupevint()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+332", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end
function dupeshotik()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+236", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end
function dupeglock()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+204", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end
function dupemp()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+268", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end
function dupem4()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+300", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end
function dupeak()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+300", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end
function dupedg()
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return dupept() end
    if not hookPLAYER("+204", D, g[1], false) then gg.clearResults() return dupept() end
    abc() dupept()
end

frzsl1="❌ " frzsl2="❌ " frzsl3="❌ " frzsl4="❌ " frzsl5="❌ " frzsl6="❌ " frzsl7="❌ "

function freezeslot()
    menuuuvis = 0
    local Grandmobilehackqoq = gg.choice({
        "╔═══════════════════════╗\n  🔫  DEAGLE  "..frzsl1.."       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  GLOCK  "..frzsl2.."        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  M4  "..frzsl3.."            \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  AK-47  "..frzsl4.."         \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  MP5  "..frzsl5.."           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SNIPER  "..frzsl6.."        \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SHOTGUN  "..frzsl7.."       \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "❄️ FREEZE SLOTS")
    if not Grandmobilehackqoq or Grandmobilehackqoq == 8 then gun() end
    if Grandmobilehackqoq == 1 then freezeslotq1() end
    if Grandmobilehackqoq == 2 then freezeslotq2() end
    if Grandmobilehackqoq == 3 then freezeslotq3() end
    if Grandmobilehackqoq == 4 then freezeslotq4() end
    if Grandmobilehackqoq == 5 then freezeslotq5() end
    if Grandmobilehackqoq == 6 then freezeslotq6() end
    if Grandmobilehackqoq == 7 then freezeslotq7() end
    menuuuvis = -1
end
function _frz(n, o1, v1, o2)
    if _G[n] == nil then _G[n] = "❌ " end
    local _f = (_G[n] == "❌ ")
    gg.clearList()
    if _f then
        if not hookPLAYER(o1, D, v1, true) or not hookPLAYER(o2, D, "", true) then
            gg.clearResults() return freezeslot()
        end
        _G[n] = "✅ " abc()
    else
        _G[n] = "❌ " gg.clearList() gg.clearResults() cba()
    end
    gg.clearResults() freezeslot()
end
function freezeslotq7() _frz("frzsl7", "+224", 25, "+236") end
function freezeslotq6() _frz("frzsl6", "+320", 34, "+332") end
function freezeslotq5() _frz("frzsl5", "+256", 29, "+268") end
function freezeslotq4() _frz("frzsl4", "+288", 30, "+300") end
function freezeslotq3() _frz("frzsl3", "+288", 31, "+300") end
function freezeslotq2() _frz("frzsl2", "+192", 22, "+204") end
function freezeslotq1() _frz("frzsl1", "+192", 24, "+204") end

function givegun()
    menuuuvis = 0
    local GrandmobilehackGun1 = gg.choice({
        "╔═══════════════════════╗\n  🔫  DEAGLE             \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  M4                 \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  AK-47              \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SHOTGUN            \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  MP5                \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  GLOCK              \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SNIPER NO SCOPE    \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  SNIPER SCOPE       \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  MINIGUN            \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  RPG                \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  RPG AUTO           \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  OTHER WEAPONS      \n╚═══════════════════════╝",
        "╔═══════════════════════╗\n  🔫  WEAPON IDs         \n╚═══════════════════════╝",
        "  ╔═════════════════════╗\n     ❌  BACK         \n  ╚═════════════════════╝"
    }, nil, "🔫 GIVE WEAPON")
    if not GrandmobilehackGun1 or GrandmobilehackGun1 == 14 then gun() end
    if GrandmobilehackGun1 == 1 then gv11dg() end
    if GrandmobilehackGun1 == 2 then gv22m4() end
    if GrandmobilehackGun1 == 3 then gv33ak() end
    if GrandmobilehackGun1 == 4 then gv44shot() end
    if GrandmobilehackGun1 == 5 then gv55mp() end
    if GrandmobilehackGun1 == 6 then gv66gl() end
    if GrandmobilehackGun1 == 7 then gv77snap() end
    if GrandmobilehackGun1 == 8 then gv77snappr() end
    if GrandmobilehackGun1 == 9 then gv88minig() end
    if GrandmobilehackGun1 == 10 then gv99rpg() end
    if GrandmobilehackGun1 == 11 then gv111rpgauto() end
    if GrandmobilehackGun1 == 12 then givegun14() end
    if GrandmobilehackGun1 == 13 then givegun1488() end
end
function gv77snappr()
    if not hookPLAYER("+320", D, 34, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+332", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv11dg()
    if not hookPLAYER("+192", D, 24, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+204", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv22m4()
    if not hookPLAYER("+288", D, 31, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+300", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv33ak()
    if not hookPLAYER("+288", D, 30, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+300", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv44shot()
    if not hookPLAYER("+224", D, 25, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+236", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv55mp()
    if not hookPLAYER("+256", D, 29, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+268", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv66gl()
    if not hookPLAYER("+192", D, 22, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+204", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv77snap()
    if not hookPLAYER("+320", D, 33, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+332", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv88minig()
    if not hookPLAYER("+352", D, 38, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+364", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv99rpg()
    if not hookPLAYER("+352", D, 35, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+364", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function gv111rpgauto()
    if not hookPLAYER("+352", D, 36, false) then gg.clearResults() return givegun() end
    local g = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+364", D, g[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function givegun14()
    local g = gg.prompt({"Weapon ID [1;46]"}, nil, {[1]="number"})
    if not g then return givegun() end
    if not hookPLAYER("+192", D, g[1], false) then gg.clearResults() return givegun() end
    local g2 = gg.prompt({"Ammo [1;9900]"}, nil, {[1]="number"})
    if not g2 then return givegun() end
    if not hookPLAYER("+204", D, g2[1], false) then gg.clearResults() return givegun() end
    abc() givegun()
end
function givegun1488()
    gg.alert("ALL WEAPON IDs 🔫\n\n1 KNUCKLES\n2 KEY\n3 BATON\n4 KNIFE\n5 BAT\n6 SHOVEL\n7 CUE\n8 KATANA\n9 GAS CAN\n24 DEAGLE\n25 SHOTGUN\n26 SAWED-OFF\n27 AUTO SHOTGUN\n28 UZI\n29 MP5\n30 AK-47\n31 M4\n32 TEC-9\n33 HUNTING\n34 SNIPER\n35 RPG\n36 ROCKET\n37 FLAMETHROWER\n38 MINIGUN\n46 PARACHUTE")
    givegun()
end

-- AIM MENU
local aim_st = {
    {n='🎯 ULTRA LEGIT', v="1055999999", s="❌ "},
    {n='🎯 LEGIT', v="1055999999", s="❌ "},
    {n='🎯 MEDIUM', v="1076999999", s="❌ "},
    {n='🎯 ULTRA', v="1080099999", s="❌ "},
    {n='🎯 HVH', v="1089999999", s="❌ "},
}
function aim()
    menuuuvis = 0
    local l = {}
    for i, v in ipairs(aim_st) do table.insert(l, v.n .. " " .. v.s) end
    l[#l+1] = '◀️ BACK'
    local r = gg.choice(l, nil, "🎯 AIM MENU")
    if not r or r == #l then return grndmenu() end
    local it = aim_st[r]
    local old = "1042536202"
    if it.s == "❌ " then
        it.s = "✅ "
        Z.S(old, D, Ca|O)
        if #Result > 0 then gg.editAll(it.v, D) abc() else qwea() end
    else
        it.s = "❌ "
        Z.S(it.v, D, Ca|O)
        if #Result > 0 then gg.editAll(old, D) cba() else qwea() end
    end
    gg.clearResults()
    aim()
end

-- DEV / SUPPORT
function dev()
    local d_menu = gg.choice({
        "✈️ TELEGRAM",
        "💬 CHAT",
        "❌ BACK"
    }, nil, "🛠️ DEVELOPER")
    if not d_menu or d_menu == 3 then return grndmenu() end
    if d_menu == 1 then
        gg.copyText("https://t.me/GRANDMOBILEHACK")
        gg.goURL("https://t.me/GRANDMOBILEHACK")
    elseif d_menu == 2 then
        gg.copyText("https://t.me/GRANDMOBILEHACKBOT")
        gg.goURL("https://t.me/GRANDMOBILEHACKBOT")
    end
    return dev()
end

function helpq()
    local h_menu = gg.choice({
        "💳 UPI",
        "❌ BACK"
    }, nil, "🆘 SUPPORT")
    if not h_menu or h_menu == 2 then return grndmenu() end
    if h_menu == 1 then
        gg.copyText("azarkhan1401@upi")
        gg.goURL("upi://pay?pa=azarkhan1401@upi&pn=GRANDMOBILEHACK&cu=INR")
    end
    return helpq()
end

function exit()
    __saveConfig()
    print("╔═══════════════════════════════════════╗\n  👑  SCRIPT BY @GRANDMOBILEHACK  👑    \n╚═══════════════════════════════════════╝")
    gg.setVisible(true)
    allah666()
end

-- MAIN LOOP
while true do
    if gg.isVisible(true) then
        menuuuvis = 1
        gg.setVisible(false)
    end
    if menuuuvis == 1 then
        grndmenu()
    end
    __showWatermark()
    __guardWatermark()
    gg.sleep(100)
end