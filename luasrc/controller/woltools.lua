module("luci.controller.woltools", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/woltools") then
        return
    end

    local page = entry({"admin", "services", "woltools"}, template("woltools"), _"局域网唤醒工具")
    page.dependent = true
    page.acl_depends = { "luci-app-woltools" }
    
    entry({"admin", "network", "woltools", "wake"}, call("action_wake"), nil).leaf = true
    entry({"admin", "network", "woltools", "add"}, call("action_add"), nil).leaf = true
    entry({"admin", "network", "woltools", "delete"}, call("action_delete"), nil).leaf = true
    entry({"admin", "network", "woltools", "update"}, call("action_update"), nil).leaf = true
end

function action_wake()
    local mac = luci.http.formvalue("mac")
    if mac then
        -- 获取设备配置的接口，如果没有则使用默认接口
        local uci = require "luci.model.uci".cursor()
        local port = "br-lan"
        
        -- 查找匹配的设备配置
        uci:foreach("woltools", "device", function(s)
            if s.mac == mac and s.port then
                port = s.port
                return false
            end
        end)
        
        -- 执行唤醒命令
        local result = os.execute(string.format("/usr/bin/etherwake -i %s %s", port, mac))
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = (result == 0) })
    else
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = false })
    end
end

function action_add()
    local hostname = luci.http.formvalue("hostname")
    local mac = luci.http.formvalue("mac")
    local interface = luci.http.formvalue("interface")
    
    if hostname and mac then
        local uci = require "luci.model.uci".cursor()
        local sid = uci:add("woltools", "device")
        
        uci:set("woltools", sid, "name", hostname)
        uci:set("woltools", sid, "mac", mac)
        if interface then
            uci:set("woltools", sid, "port", interface)
        end
        
        uci:commit("woltools")
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = true })
    else
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = false })
    end
end

function action_delete()
    local mac = luci.http.formvalue("mac")
    if mac then
        local uci = require "luci.model.uci".cursor()
        local deleted = false
        
        uci:foreach("woltools", "device", function(s)
            if s.mac == mac then
                uci:delete("woltools", s['.name'])
                deleted = true
                return false
            end
        end)
        
        if deleted then
            uci:commit("woltools")
        end
        
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = deleted })
    else
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = false })
    end
end

function action_update()
    local mac = luci.http.formvalue("mac")
    local interface = luci.http.formvalue("interface")
    
    if mac and interface then
        local uci = require "luci.model.uci".cursor()
        local updated = false
        
        uci:foreach("woltools", "device", function(s)
            if s.mac == mac then
                uci:set("woltools", s['.name'], "port", interface)
                updated = true
                return false
            end
        end)
        
        if updated then
            uci:commit("woltools")
        end
        
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = updated })
    else
        luci.http.prepare_content("application/json")
        luci.http.write_json({ result = false })
    end
end