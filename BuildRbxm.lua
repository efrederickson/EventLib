local source = io.open("EventLib.lua", "rb"):read"*a"
source = source:gsub("&", "&amp;")
source = source:gsub("\"", "&quot;")
source = source:gsub("<", "&lt;")
source = source:gsub(">", "&gt;")
source = source:gsub("\t", "&#9;")

local source2 = [[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<External>null</External>
	<External>nil</External>
	<Item class="Script" referent="RBX0">
		<Properties>
			<bool name="Archivable">true</bool>
			<bool name="Disabled">false</bool>
			<Content name="LinkedSource"><null></null></Content>
			<string name="Name">EventLib</string>
			<ProtectedString name="Source">]] .. source .. [[</ProtectedString>
           			</Properties>
		</Item>
	</Item>
</roblox>]]

local f = io.open("EventLib.rbxm", "wb")
f:write(source2)
f:close()
