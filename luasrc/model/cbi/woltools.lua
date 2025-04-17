local m, s, o
local sys = require "luci.sys"
local util = require "luci.util"
-- local net = require "luci.sys.net"  -- 移除此行

m = Map("woltools", translate("局域网唤醒工具"),
    translate("配置和管理局域网唤醒设备"))

s = m:section(TypedSection, "woltools", translate("全局设置"))
s.anonymous = true

o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

s = m:section(TypedSection, "device", translate("设备列表"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

o = s:option(Value, "name", translate("名称"))
o.rmempty = false

o = s:option(Value, "mac", translate("MAC地址"))
o.rmempty = false
o.datatype = "macaddr"

o = s:option(ListValue, "port", translate("网络接口"))
o.rmempty = false
-- 只保留物理网络接口
for _, iface in ipairs(luci.sys.net.devices()) do
    -- 过滤掉非物理接口，只保留eth*、wlan*等物理接口
    if string.match(iface, "^eth%d") or string.match(iface, "^wlan%d") then
        o:value(iface, iface)
    end
end
-- 添加br-lan作为默认选项
o:value("br-lan", "br-lan")
o.default = "br-lan"

o = s:option(Button, "wake", translate("唤醒"))
o.inputtitle = translate("唤醒")
o.inputstyle = "apply"
function o.write(self, section)
    local mac = m.uci:get("woltools", section, "mac")
    local port = m.uci:get("woltools", section, "port") or "9"
    luci.sys.call(string.format("/usr/bin/etherwake -i %s %s", port, mac))
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "woltools"))
end

function o.render(self, section)
    local mac = m.uci:get("woltools", section, "mac")
    if not mac or mac == "" then
        -- 不显示错误提示，只渲染按钮
        Button.render(self, section)
        return
    end
    Button.render(self, section)
end



return m