#!/bin/lua
<<<<<<< HEAD
----  CMDFetch v.5.0.0
----  See "cmdfetch --help" or "cmdfetch -h" for documentation
----  Made by Hal in Lua 5.2 for Windows 7 or 8 with or without Cygwin
----  Thanks to Zanthas and the rest of the original CMDFetch team
----  Thanks to KittyKatt and the makers of screenfo

xpcall(function() require("socket/socket") end,nil)
xpcall(function() require("socket") end,nil)





local help = (
[[Write an OS logo to the output with relevant information.

  -0, --nocolor         Force the use of zero colors
  -1, --18color         Force the use of 18 colors
  -2, --256color        Force the use of 256 colors
  -a, --align           Align the information into columns
  -b, --block [#>0]     Use a stripe step as high and as wide as the argument
  -c, --color color     Change the color of the logo
                            See --help color for formatting help
  -h, --help            
  -l, --logo logo       Change the logo
                            windows8, windows7, linux, mac (defaults to 7 or 8)
  -L, --lefty           Toggle the switching of logo and information
  -s, --stripe [dir]    Stripe the colors for the logo à la screenfo
                            vertical, horizontal, none
  -v, --vert alignment  Align the shorter column vertically
                            center,top,bottom (defaults to center)
  -m, --margin #,#      Set the padding around the logo

v.5.0.0 by Hal, Zanthas, tested (and approved) by KittyKatt, other people]])

local colorhelp = (
[[The following patterns are acceptable:

  16-255:
      Ex. ←[38;5;87m87←[0m; ←[1;31m9←[0m
  black,red,green,yellow,blue,magenta,cyan,white:
      Ex. ←[0;33myel←[1;33mlow←[0m; ←[0;34mbl←[1;34mue←[0m
  List:
      Ex. ←[1;30m8←[0m,←[38;5;52m52←[0m,←[0;31mred←[0m,←[1;31mlightred←[0m
  none:
      Ex. none
  rainbow:
      Ex. ←[1;31mr←[1;33ma←[1;32mi←[1;36mn←[1;34mb←[1;35mo←[1;31mw←[0m

If you are seeing arrows followed by brackets, numbers, and semicolons
you have no color support in your terminal.]])





local fhost,fport = "localhost","3333"
local mhost,mport = "localhost","6600"

local options = {
	align = true,
	lefty = true,
	bars = true,
	bright = false,
	dull = false,
	vert = "center",
	logo = true,
	info = true,
	margins = {1,2},
	stripe = 0,
	block = 1,
}

local order = {
	"Name","OS","Uptime","Kernel","Now Playing","Visual Style","Memory",
	"Disk Space","CPU","GPU"
}




local logos = {
	windows8 = {	"                         ....::::",
					"                 ....::::::::::::",
					"        ....:::: ::::::::::::::::",
					"....:::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					"................ ................",
					":::::::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					":::::::::::::::: ::::::::::::::::",
					"'''':::::::::::: ::::::::::::::::",
					"        '''':::: ::::::::::::::::",
					"                 ''''::::::::::::",
					"                         ''''::::"},
	windows7 = {	'        ,.=:!!t3Z3z.,               ',
					'       :tt:::tt333EE3               ',
					'       Et:::ztt33EEEL @Ee.,      ..,',
					'      ;tt:::tt333EE7 ;EEEEEEttttt33#',
					'     :Et:::zt333EEQ. $EEEEEttttt33QL',
					'     it::::tt333EEF @EEEEEEttttt33F ',
					'    ;3=*^```"*4EEV :EEEEEEttttt33@. ',
					'    ,.=::::!t=., ` @EEEEEEtttz33QF  ',
					'   ;::::::::zt33)   "4EEEtttji3P*   ',
					'  :t::::::::tt33.:Z3z..  `` ,..g.   ',
					'  i::::::::zt33F AEEEtttt::::ztF    ',
					' ;:::::::::t33V ;EEEttttt::::t3     ',
					' E::::::::zt33L @EEEtttt::::z3F     ',
					'{3=*^```"*4E3) ;EEEtttt:::::tZ`     ',
					'             ` :EEEEtttt::::z7      ',
					'                 "VEzjt:;;z>*`      '},
	linux = {		"  #################  ",
					"#####################",
					"#####################",
					"  #################  ",
					"   ################  ",
					"   ###############   ",
					"    #############    ",
					"     ###########     ",
					"       #######       ",
					"       ##O#O##       ",
					"       #######       ",
					"        #####        "},
	mac = {			[[     ,:+oo+\:-''-:\+o+\-     ]],
					[[    :ooooooooooooooooooo+'   ]],
					[[  ,ossssssssssssssssssssss\  ]],
					[[ ,syyyyyyyyyyyyyyyyyyyyyyyy+,]],
					[[ osssssssssssssssssssssssso\,]],
					[[:ssssssssssssssssssssssss-   ]],
					[[\sssssssssssssssssssssss'    ]],
					[[\++++++++++++++++++++++\     ]],
					[[-+++++++++++++++++++++++,    ]],
					[[ \\\\\\\\\\\\\\\\\\\\\\\\,   ]],
					[[ .:\\\\\\\\\\\\\\\\\\\\\\\:, ]],
					[[   ':\++++++\::::\++++++\:,  ]],
					[[      ':-::- '+\:-,,.::-     ]],
					[[              \+++\'         ]],
					[[               :++++'        ]],
					[[                -\+:'        ]]},
	none = {		""}}

local colormaps = {
	windows8 = {
		{{1,33}},{{1,33}},{{1,33}},{{1,33}},{{1,33}},{{1,33}},{{1,33}},
		{{1,33}},{{1,33}},{{1,33}},{{1,33}},{{1,33}},{{1,33}},{{1,33}},
		{{1,33}},{{1,33}},{{1,33}}
	},
	windows7 = {
		{{1,36}},{{1,36}},{{1,21},{2,15}},{{1,20},{2,16}},{{1,20},{2,16}},
		{{1,19},{2,17}},{{1,18},{2,18}},{{4,16},{1,2},{2,18}},{{4,17},{2,19}},
		{{4,17},{3,6},{2,4},{3,9}},{{4,16},{3,20}},{{4,15},{3,21}},
		{{4,15},{3,21}},{{4,14},{3,22}},{{4,14},{3,22}},{{4,16},{3,20}},
	},
	linux = {
		{{1,7},{2,7},{1,7}},{{1,7},{2,1},{3,5},{2,1},{1,7}},
		{{1,6},{2,1},{3,7},{2,1},{1,6}},{{1,4},{2,1},{3,11},{2,2},{1,3}},
		{{2,4},{3,12},{2,5}},{{2,4},{3,12},{2,5}},{{2,5},{3,10},{2,6}},
		{{2,7},{3,2},{1,3},{3,2},{2,7}},{{2,8},{1,5},{2,8}},
		{{2,9},{3,1},{2,1},{3,1},{2,9}},{{2,21}},{{2,21}}
	},
	mac = {
		{{6,29}},{{6,29}},{{6,29}},{{5,29}},{{5,29}},{{4,29}},{{4,29}},
		{{3,29}},{{3,29}},{{2,29}},{{2,29}},{{1,29}},{{1,29}},{{1,29}},
		{{1,29}},{{1,29}}},
	none = {
		{{1,1}}}
}

local colornames = {
	windows8 = {"lightcyan"},
	windows7 = {"red","green","yellow","blue"},
	linux = {"yellow","lightblack","white"},
	mac = {"green","yellow","lightred","red","magenta","blue"},
	none = {}
}

local colors = {
	"black","red","green","yellow","magenta","blue","cyan","white"
}






local function getwmic(alias,key)
	for line in io.popen(("wmic %s get %s"):format(alias,key)):lines() do
		if not line:lower():match(key) then
			return (line:gsub("%s"," "))
		end
	end
end





local ostype,depth = os.getenv("TERM") and "cygwin" or "windows"

do
	--  Automatic color depth tests
	if ostype == "cygwin" then
		depth = "16" --os.getenv("TERM") == "cygwin" and "16" or "256"
	else
		depth = os.getenv("ANSICON") and "16" or "0"
	end
end

local reset = depth == "0" and "" or "\027[0m"

local logo = getwmic("os","caption"):match("7") and "windows7" or "windows8"





local function getcolor(x)
	if type(x) == "number" then
		return x < 16 and (
			"\027[%s;3%sm"
		):format(x<8 and 0 or 1,x%8) or (
			"\027[38;5;%sm"
		):format(x)
	elseif type(x) == "string" then
		for _,color in pairs(colors) do
			if x == color or x == "light"..color then
				return depth ~= "0" and ("\027[%s;3%sm"):format(
					x:match("light") and 1 or 0,({
						["black"]=0,["red"]=1,["green"]=2,["yellow"]=3,
						["blue"]=4,["magenta"]=5,["cyan"]=6,["white"]=7
					})[(x:gsub("light",""))]
				) or ""
			end
		end
	elseif x == nil then
		return ""
	end
	return nil
end





do
	local flags = {{_,{}}}
	for i = 1,#arg do
		if arg[i]:sub(1,1) == "-" then
			table.insert(flags,{arg[i],{}})
		else
			table.insert(flags[#flags][2],arg[i])
		end
	end
	for _,args in pairs(flags) do
		if args[1] == "-h" or args[1] == "--help" then
			if args[2][1] == "color" then
				print((colorhelp:gsub("←","\027")))
			elseif not args[2][1] then
				print(help)
			else
				print(("Invalid argument for %s: %s"):format(args[1],args[2]))
			end
			os.exit()
		elseif args[1] == "-0" or args[1] == "--nocolor" then
			depth = "0"
		elseif args[1] == "-1" or args[1] == "--18color" then
			depth = "16"
		elseif args[1] == "-2" or args[1] == "--256color" then
			depth = "256"
		elseif args[1] == "-l" or args[1] == "--logo" then
			if colornames[string.lower(args[2][1])] then
				logo = string.lower(args[2][1])
			end
		elseif args[1] == "-v" or args[1] == "--vert" then
			if args[2][1] == "center" or args[2][1] == "top" or args[2][1] == "bottom" then
				options.vert = args[2][1]
			end
		elseif args[1] == "-c" or args[1] == "--color" then
			local args = table.concat(args[2]," ")
			if args:match(",") then
				for i,_ in pairs(colornames) do
					colornames[i] = {}
				end
				args = args:gsub("%s","")
				for color in args:gmatch("[^,]+") do
					color = tonumber(color) or color
					if getcolor(color) then
						for i,_ in pairs(colornames) do
							table.insert(colornames[i],color)
						end
					else
						print(("Invalid color: %s"):format(color))
						os.exit()
					end
				end
			elseif args == "none" then
				for i,_ in pairs(colornames) do
					colornames[i] = {}
				end
			elseif args == "rainbow" then
				for i,_ in pairs(colornames) do
					colornames[i] = {
						"lightred","lightyellow","lightgreen","lightcyan",
						"lightblue","lightmagenta"
					}
				end	
			else
				local done
				for _,color in pairs(colors) do
					if string.lower(args) == color then
						for i,_ in pairs(colornames) do
							colornames[i] = {color,"light"..color}
						end
						done = true
					end
				end
				if not done then
					print(("Invalid color: %s"):format(args))
					os.exit()
				end
			end
		elseif args[1] == "-m" or args[1] == "--margin" then
			if (args[2][1] or ""):match("%d,%d") == args[2][1] and args[2][1] then
				local l,r = args[2][1]:match("(%d),(%d)")
				options.margins = {tonumber(l),tonumber(r)}
			else
				print(("Invalid margin format: %s"):format(args[2][1]))
				os.exit()
			end
		elseif args[1] == "-s" or args[1] == "--stripe" then
			local tab = {vertical=1,horizontal=2,none=0}
			if tab[args[2][1]] then
				options.stripe = tab[args[2][1]]
			else
				print(("Invalid stripe format: "):format(args[2][1]))
				os.exit()
			end
		elseif args[1] == "-b" or args[1] == "--block" then
			if tonumber(args[2][1]) and (tonumber(args[2][1]) or 0) > 0 then
				options.block = tonumber(args[2][1])
			else
				print(("Invalid block format: "):format(args[2][1]))
				os.exit()
			end
		elseif args[1] == "-a" or args[1] == "--align" then
			options.align = not options.align
		elseif args[1] == "-L" or args[1] == "--lefty" then
			options.lefty = not options.lefty
=======
--//--    Constants/Configuration    --//--
--[[
local                 usedLines = {"Name","Kernel","OS","Memory","Uptime",
                                   "Visual Style","Resolution","CPU","GPU","Disk Space",
                                   "bbLean Theme","Users","Now Playing","Terminal",
                                   "MoBo","Font","WM","Shell","Processes",
                                   "Music Player","IRC Client"}
]]
                      usedLines = {"Name","Kernel","OS","Memory","Uptime",
                                   "Visual Style","Resolution","CPU","GPU","Disk Space",
                                   "bbLean Theme","Now Playing","Terminal","Font",
                                   "WM","Shell","Music Player","IRC Client"}
local               fhost,fport = "localhost","3333"  --  Host and port for foobar
local               mhost,mport = "localhost","6600"  --  Host and port for MPD
local            dominantPlayer = "foobar"  --  Change to "mpd" to check for MPD first
local                 fancyData = true --  Use a more decorative format for numeric data
local              data256Color = false  --  Use 256 colors for data highlighting
local              auto256Color = false  --  Automatically use 256 color data if possible
local             excludedUsers = {}  --  A table of names to exclude from the Users list
local                resetColor = "\027[0m"  -- \027[0;37m is the default in Windows
local               brightColor = "\027[1;37m"  --  \027[1m is usable in a Cygwin PTY
local                      logo = "windows7"  --  Default logo
local                    bright = false  --  default state of the "bright" flag
local                      dull = false  --  default state of the "dull" flag
local                     align = false  --  default state of the "align"  flag
local                     lefty = false  --  default state of the "lefty" flag
local                      down = false  --  default state of the "down" flag 
local                    center = false  --  default state of the "center" flag
local                noNotFound = true  --  Don't show information when it isn't found
local               useCPUUsage = false  -- Show CPU usage
local                    stripe = 0  --  default state of the "stripe" flag
local                     block = 1  -- default state of the block size
local                     logos = {}
local                    colors = {}
                colors["black"] = {"\027[0;30m","\027[1;30m"}
                  colors["red"] = {"\027[0;31m","\027[1;31m"}
               colors["yellow"] = {"\027[0;33m","\027[1;33m"}
                colors["green"] = {"\027[0;32m","\027[1;32m"}
                 colors["blue"] = {"\027[0;34m","\027[1;34m"}
               colors["violet"] = {"\027[0;35m","\027[1;35m"}
                 colors["cyan"] = {"\027[0;36m","\027[1;36m"}
                colors["white"] = {"\027[0;37m","\027[1;37m"}
                colors["white"] = {"\027[0;37m","\027[1;37m"}
              colors["rainbow"] = {"\027[1;35m","\027[1;31m","\027[1;33m",
                                   "\027[1;32m","\027[0;36m","\027[1;34m"}
                 colors["none"] = {"\027[0m"}
local                colorNames = {"blue","yellow","red","green","violet",
                                   "cyan","black","white","none","rainbow"}
local             lineFunctions = {}
              logos["windows7"] = {}
              logos["windows8"] = {}
          logos["windows7"][01] = "${c1}        ,.=:!!t3Z3z.,               "
          logos["windows7"][02] = "${c1}       :tt:::tt333EE3               "
          logos["windows7"][03] = "${c1}       Et:::ztt33EEEL${c2} @Ee.,      ..,"
          logos["windows7"][04] = "${c1}      ;tt:::tt333EE7${c2} ;EEEEEEttttt33#"
          logos["windows7"][05] = "${c1}     :Et:::zt333EEQ.${c2} $EEEEEttttt33QL"
          logos["windows7"][06] = "${c1}     it::::tt333EEF${c2} @EEEEEEttttt33F "
          logos["windows7"][07] = "${c1}    ;3=*^```\"*4EEV${c2} :EEEEEEttttt33@. "
          logos["windows7"][08] = "${c4}    ,.=::::!t=., ${c1}`${c2} @EEEEEEtttz33QF  "
          logos["windows7"][09] = "${c4}   ;::::::::zt33)${c2}   \"4EEEtttji3P*   "
          logos["windows7"][10] = "${c4}  :t::::::::tt33.${c3}:Z3z..${c2}  ``${c3} ,..g.   "
          logos["windows7"][11] = "${c4}  i::::::::zt33F${c3} AEEEtttt::::ztF    "
          logos["windows7"][12] = "${c4} ;:::::::::t33V${c3} ;EEEttttt::::t3     "
          logos["windows7"][13] = "${c4} E::::::::zt33L${c3} @EEEtttt::::z3F     "
          logos["windows7"][14] = "${c4}{3=*^```\"*4E3)${c3} ;EEEtttt:::::tZ`     "
          logos["windows7"][15] = "${c4}             `${c3} :EEEEtttt::::z7      "
          logos["windows7"][16] = "${c3}                 \"VEzjt:;;z>*`      "
    logos["windows7"]["colors"] = {"\027[1;31m","\027[1;32m","\027[1;33m","\027[1;36m"}
          logos["windows8"][01] = "${c1}                         ....::::"
          logos["windows8"][02] = "${c1}                 ....::::::::::::"
          logos["windows8"][03] = "${c1}        ....:::: ::::::::::::::::"
          logos["windows8"][04] = "${c1}....:::::::::::: ::::::::::::::::"
          logos["windows8"][05] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][06] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][07] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][08] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][09] = "${c1}................ ................"
          logos["windows8"][10] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][11] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][12] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][13] = "${c1}:::::::::::::::: ::::::::::::::::"
          logos["windows8"][14] = "${c1}'''':::::::::::: ::::::::::::::::"
          logos["windows8"][15] = "${c1}        '''':::: ::::::::::::::::"
          logos["windows8"][16] = "${c1}                 ''''::::::::::::"
          logos["windows8"][17] = "${c1}                         ''''::::"
    logos["windows8"]["colors"] = {"\027[1;34m"}
                  logos["none"] = {""}
        logos["none"]["colors"] = {resetColor}
local                     color
local                 logoNames = {"windows7","windows8","none"}

--//    Functions    //--

local function CamelCase(phrase)
    for word in phrase:gmatch("[^%s]+") do
        phrase = phrase:gsub(word,string.upper(word:sub(1,1))..word:sub(2))
    end
    return phrase
end

local function errorString(str)
    if canColor then
        print(lightRed.."Error: "..str.."\nSee --help"..resetColor)
    else
        print("Error: "..str.."\nSee --help")
    end
end

local function lineFromFile(file,num)
    it=1
    for line in file:lines() do
        if num == it then
            return line
        end
        it = it+1
    end
end

local function receive(connection,player)
    if player == dominantPlayer then
        local lines = ""
        while true do
            local line = connection:receive()
            if line:sub(1,3) ~= "999" then
                return line
            end
            if not line then
                break
            end
        end
    else
        local lines = ""
        while true do
            local line,err = connection:receive()
            if not line then return false,err end
            lines = lines..line
            if line == "OK" or line:match("ACK") then break end
            lines = lines.."\n"
        end
        return lines
    end
end

local function warning()
    print("This version of CMDFetch uses Ansi escape codes.")
    print("Various Cygwin PTY's provide these, you can use Ansicon to get them")
    print("in Windows CMD.")
    print("  [ Ansicon can be found here:       ]")
    print("  [ http://adoxa.3eeweb.com/ansicon/ ]")
    print("Windows 8 Users should use Ansicon x86 even if they use x64 Windows")
    print("You can try it out with \"-c none\"\n")
    return
end

local function getGood(words)
    local word = io.popen(words)
    for line in word:lines() do
        if not line:lower():find(string.lower(words:match("get (%w+)"))) then
            local out = line:match("[\032%w%p_]+"):gsub("%s*$","")
            return out
        end
    end
end

local function colorCap(a,b) 
    if b == 0 then
        return "\027[0m"
    end
    if data256Color then
        slider = {46,82,118,154,190,226,220,214,208,202,198}
        for i = 1,#slider do
            slider[i] = "\027[38;5;"..slider[i].."m"
        end
    else
        slider = {"\027[1;32m","\027[0;32m","\027[0;33m","\027[0;31m","\027[1;31m"}
    end
    slider[0] = slider[1]
    return slider[math.floor((a/b*(#slider))+0.5)]
end

local currentColor = 1
local function toggleColor()
    currentColor = currentColor + 1
    if currentColor > #logos[logo]["colors"] then
        currentColor = 1
    end
    return currentColor
end

--//    Test for Lua Socket    //--

local tests = {"socket/socket","socket"}
local works = false
for i = 1,#tests do
	xpcall(
		function()
			require(tests[i])
		end,
		function(err)
			if not err then
				works = tests[i]
			end
		end
	)
end

if not socket then
	for a = 1,#usedLines do
		if usedLines[a] == "Now Playing" then
			for b = a+1,#usedLines do
				usedLines[b-1] = usedLines[b]
				usedLines[b] = nil
			end
>>>>>>> a9d68a46d9331341072428e602de4427424c0a59
		end
	end
end

<<<<<<< HEAD




local function caps(str)
	return string.upper(str:sub(1,1))..string.lower(str:sub(2))
end

local function ctrim(str)
	return ((str or ""):gsub("\027%[[%d;]+m",""))
end

local function maplogo(logo)
	local len,out = logos[logo][1]:len(),{}
	for i,line in pairs(logos[logo]) do
		local d = 1
		for _,pair in pairs(colormaps[logo][i]) do
			local w = pair[2]
			local color = colornames[logo][pair[1]]
			if not color then
				local n,a = colornames[logo],pair[1]
				color = colornames[logo][a%#n == 0 and #n or a%#n]
			end
			out[i] = (out[i] or "")..getcolor(color)..line:sub(d,d+w-1)
			d = d + w
		end
	end
	return out
end

--11223344
--abcdefgh

local function stripelogo(logo)
	local stripe,block,log = options.stripe,options.block,logos[logo]
	local lc = colornames[logo]
	local out = {}
	if stripe == 1 then
		for x = 1,math.ceil(log[1]:len()/block) do
			for y = 1,#log do
				local color = getcolor(lc[x%#lc == 0 and #lc or x%#lc])
				out[y] = (out[y] or "")..color..log[y]:sub(x*block-(block-1),x*block)
			end
		end
	elseif stripe == 2 then
		for y = 0,math.ceil(#log/block) do
			for yo = 1,block do
				local color = getcolor(lc[(y+1)%#lc == 0 and #lc or (y+1)%#lc])
				if log[y*block+yo] then
					out[y*block+yo] = (out[y*block+yo] or "")..color..log[y*block+yo]
				end
			end
		end
	end
	return out
end

local function trim(str,len)
	return (str:len() <= len) and str or str:sub(0,len-3).."..."
end

local function colorscale(value,max)
	if depth == "256" then
		local scale = math.min(math.floor(value/(max/11))+1,11)
		return getcolor(16+math.min(scale-1,5)*36+math.min(11-scale,5)*6)
	elseif depth == "16" then
		return getcolor(({
			"lightgreen","green","yellow","red","lightred"
		})[math.min(math.floor(value/(max/5))+1,5)])
	else
		return ""
	end
end

local function bar(percent)
	local barwidth = math.floor(10*percent/100+0.5)
	return ("[%s%s%s%s]"):format(
		colorscale(percent,100),("="):rep(barwidth),reset,
		("-"):rep(10-barwidth)
	)
end

local function tn(...)
	local out = {...}
	for i,v in pairs(out) do out[i] = tonumber(v) end
	return unpack(out)
end

local function uptime()
	local lastBootUp = getwmic("os","lastbootuptime")
	local pattern="(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)"
	local y,m,d,h,mi,s=tn((lastBootUp):match(pattern))
	local up = {}
	up.days,up.hours,up.mins,up.secs = os.date("!%j %H %M %S",os.time()-os.time{
		year=y,month=m,day=d,hour=h,minu=mi,sec=s
	}):match("(.+)%s(.+)%s(.+)%s(.+)")
	up.days = up.days - 1
	for a,b in pairs(up) do
		up[a] = tonumber(b)
	end
	return up
end

local function plural(n)
	return n ~= 1 and "s" or ""
end

local function getos()
	return getwmic("os","caption")
end

local function getkernel()
	return ostype == "windows" and (
		os.getenv("OS").." "..getwmic("os","version")
	) or (
		io.popen("uname -sr"):read()
	)
end

local function getname()
	local name = os.getenv(ostype == "cygwin" and "USER" or "USERNAME")
	local domain = os.getenv(ostype == "cygwin" and "HOSTNAME" or "USERDOMAIN")
	if depth == "256" then
		return ("\027[38;5;178m%s\027[1;37m@\027[38;5;240m%s"):format(
			name,domain..reset
		)
	elseif depth == "16" then
		return ("\027[1;33m%s\027[1;37m@\027[1;30m%s"):format(
			name,domain..reset
		)
	else
		return ("%s@%s"):format(name,domain)
	end
end

local function getfoobar()
	local foobar = socket.connect(fhost,fport)
	if foobar then
		local out
		repeat out = foobar:receive() until out:match("111")
		foobar:close()
		return out:match(".+|.+|.+|.+|.+|.+|(.+)|.+|.+|.+|.+|(.+)|")
	end
end

local function getmpd()
	local mpd = socket.connect(mhost,mport)
	if mpd then
		mpd:send("currentsong\r\n")
		local artist,track
		repeat
			local line,err = mpd:receive()
			local tag,value = line:match("(.-): (.+)")
			artist = artist or (tag == "Artist" and value)
			track = track or (tag == "Title" and value)
		until line == "OK" or line:match("ACK") or (not line)
		mpd:close()
		return artist,track
	end
end

local function getsong()
	if not socket then return "N/A - N/A" end
	foobar,mpd = {getfoobar()},{getmpd()}
	local artist = foobar[1] or mpd[1] or "N/A"
	local track = foobar[2] or mpd[2] or "N/A"
	return ("%s - %s"):format(artist,track)
end

local function getmemory()
	local ram = getwmic("os","totalvisiblememorysize")
	local freeram = getwmic("os","freephysicalmemory")
	local usedram = math.floor(((ram - freeram)/1024)+.5)
	local ram = math.floor((tonumber(ram)/1024)+.5)
	local percentage = math.floor((usedram/ram*100)*10+0.5)/10
	
	local width = (usedram..ram..percentage):len()+8
	local bar = bar(usedram/ram*100)
	local space = (" "):rep(24-width)
	
	local color = colorscale(usedram,ram) or ""
	local format = "%s%s%s/%s MB (%s%s%%%s) %s"
	
	return format:format(color,usedram,reset,ram,color,percentage,reset,space..bar)
end

local function getuptime()
	local uptime = uptime()
	local out = "%s day%s %s hour%s %s min%s %s second%s"
	local days,hours,mins,secs
	days,hours,mins,secs = uptime.days,uptime.hours,uptime.mins,uptime.secs
	return out:format(
		getcolor("lightwhite")..days..reset,plural(days),
		(colorscale(uptime.hours,24) or "")..hours..reset,plural(hours),
		(colorscale(uptime.mins,60) or "")..mins..reset,plural(mins),
		(colorscale(uptime.secs,60) or "")..secs..reset,plural(secs)
	)
end

local function getspace()
	local space,out = io.popen("wmic logicaldisk get freespace,size"),{}
	local drives,max = {},0
	for line in space:lines() do
		if line:match("%d") then
			local freespace,size = line:match("(%d+)%s+(%d+)")
			local usedspace = size-freespace
			local total = math.floor(size/1024^3*10+0.5)/10
			local used = math.floor(usedspace/1024^3*10+0.5)/10
			local percent = math.floor(used/total*1000+0.5)/10
			local color = colorscale(used,total) or ""
			
			local width = (used..total..percent):len()+8
			local bar = bar(used/total*100)
			local space = (" "):rep(24-width)
			local format = "%s%s%s/%s GB (%s%s%%%s) %s"
			
			table.insert(out,format:format(
				color,used,reset,total,color,percent,reset,space..bar
			))
		end
	end
	return unpack(out)
end

local function getcpu()
	for line in io.popen("wmic cpu get loadpercentage,name"):lines() do
		if line:match("%d") then
			local usage,name = line:match("(%d+)%s+(.+)")
			name = name:gsub("%s+"," "):gsub("%([RTM]+%)","")
			
			local color = colorscale(tonumber(usage),100) or ""
			local usage = tonumber(usage)
			local space,bar = (" "):rep(17-string.len(usage)),bar(usage)
			
			local format = "Usage: %s%s%%%s%s%s"
			return format:format(color,usage,reset,space,bar),name
		end
	end
end

local function getgpu()
	local gpu,gpulines = io.popen("wmic path Win32_VideoController get caption"),{}
	for line in gpu:lines() do
		if line and not line:lower():find("caption") and line:find("%w") then
			table.insert(gpulines,(line:gsub("%s+"," "):gsub("%([RTM]+%)","")))
		end
	end
	return unpack(gpulines)
end

function getvs()
    local theme,dir1,dir2
    dir1 = [[HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager]]
	dir2 = [[HKCU\Software\Microsoft\Windows\CurrentVersion\Themes]]
	local key = 'cmd /c "2>nul reg query '..dir1..' /v DllName"'
	for line in io.popen(key):lines() do
		if line:match("DllName") then
			return line:match("([%w%s]+)%.msstyles")
		end
	end
	--  There isn't a visual style found
	--  This is often the case when using Windows Classic
	local key = 'cmd /c "2>nul reg query '..dir2..' /v CurrentTheme"'
	for line in io.popen(key):lines() do
		if line:match("CurrentTheme") then
			--  This is more difficult
			--  Reads the .theme file to determine the theme
			return caps(line:match("(%w+)%.theme"))
		end
	end
end





local format = {
	["Name"] = getname,	["OS"] = getos,	["Uptime"] = getuptime,
	["Kernel"] = getkernel,	["Now Playing"] = getsong,
	["Memory"] = getmemory,	["Disk Space"] = getspace, ["CPU"] = getcpu,
	["Visual Style"] = getvs, ["GPU"] = getgpu
}





local infocolor = colornames[logo][1]

local information,info = {},{}

for _,v in pairs(order) do
	table.insert(information,{v..":",{format[v]()}})
end

if options.align then
	local longest = 0
	for _,l in pairs(order) do
		longest = math.max(longest,string.len(l))
	end
	for _,v in pairs(information) do
		v[1] =  (" "):rep((longest+1)-v[1]:len())..v[1]
	end
end

for _,e in pairs(information) do
	table.insert(info,getcolor(infocolor)..e[1]..reset.." "..e[2][1])
	for i = 2,#e[2] do
		table.insert(info,(" "):rep(e[1]:len())..reset.." "..e[2][i])
	end
end

local c1,c2 = _,info

if options.stripe == 0 then
	c1 = maplogo(logo)
else
	c1 = stripelogo(logo)
end

if options.lefty then
	c2,c1 = c1,c2
	local max = 0
	for i = 1,#c1 do
		max = math.max(max,ctrim(c1[i]):len())
	end
	for i = 1,#c1 do
		c1[i] = c1[i]..(" "):rep(max-ctrim(c1[i]):len())
	end
end

if options.vert ~= "top" then
	local unit
	if options.vert == "center" then
		unit = math.floor((math.max(#c1,#c2)-math.min(#c1,#c2))/2)
	elseif options.vert == "bottom" then
		unit = math.max(#c1,#c2)-math.min(#c1,#c2)
	end
	local smaller = ({[#c1]=c1,[#c2]=c2})[math.min(#c1,#c2)]
	if unit ~= 0 then
		for i = #smaller,1,-1 do
			smaller[i+unit] = smaller[i]
			smaller[i] = nil
		end
	end
end

for i = 1,math.max(#c1,#c2) do
	local m1,m2 = unpack(options.margins)
	m1,m2 = (" "):rep(m1),(" "):rep(m2)
	print(m1..(c1[i] or (" "):rep(ctrim(c1[#c1]):len()))..m2..(c2[i] or ""))
end
=======
--//    Default logo to Windows 8 logo if the user is using Windows 8    //--

local OS = getGood("wmic os get caption")
if OS:find("2012") or OS:find("8") then
    logo = "windows8"
end

--//    Test for Ansi escape codes by terminal emulator    //--

local failedCygwinTest
local failedAnsiconTest
local terminal = os.getenv("TERM")
failedCygwinTest = (terminal == nil)
failedAnsiconTest = (io.popen("cmd /c echo %ANSICON%"):read():match("%d") == nil)
local canColor = not (failedCygwinTest and failedAnsiconTest)
if auto256Color and not failedCygwinTest then
    data256Color = true
end

--//    Functions for lines    //--

lineFunctions["Now Playing"] = function()
    local foobar = socket.connect(fhost,fport)
    local mpd = socket.connect(mhost,mport)
    local artist,track
    if foobar then
        local out = receive(foobar,"foobar")
        artist,track = out:match(".+|.+|.+|.+|.+|.+|(.+)|.+|.+|.+|.+|(.+)|")
        foobar:close()
    elseif mpd then
        mpd:send("currentsong\r\n")
        np = receive(mpd,"mpd")
        for match in np:gmatch("([^\n]+)") do
            local tag,value = match:match("(.-): (.+)")
            if tag and value then
                if tag == "Artist" then
                    artist = value
                elseif tag == "Title" then
                    track = value
                end
            end
        end
        mpd:close()
    end
    if not artist and not track then
        if data256Color then
            return "\027[38;5;240mNot found"
        else
            return "\027[1;30mNot found"
        end
    end
    if fancyData then
        return artist.." "..brightColor.."-\027[0m "..track
    else
        return artist.." - "..track
    end
end

lineFunctions["Name"] = function()
    local nameColor,atColor,hostColor,name,host
    if fancyData and not data256Color then
        nameColor = "\027[0;33m"
        atColor = "\027[0;37m"
        hostColor = "\027[1;30m"
    elseif fancyData and data256Color then
        nameColor = "\027[38;5;178m"
        atColor = brightColor
        hostColor = "\027[38;5;240m"
    else
        nameColor = ""
        atColor =  brightColor
        hostColor = resetColor
    end
    if failedCygwinTest then
        name = os.getenv("USERNAME")
        host = os.getenv("USERDOMAIN")
    else
        name = os.getenv("USER")
        host = os.getenv("HOSTNAME")
    end
    return nameColor..name..atColor.."@"..hostColor..host
end

lineFunctions["OS"] = function()
    architecture = getGood("wmic OS get OSArchitecture")
    local out = OS.." "..architecture
    if fancyData then
        for i = 1,3 do
            out = out:gsub("%"..("_.-"):sub(i,i),brightColor..("_.-"):sub(i,i)..resetColor)
        end
    end
    return out
end

lineFunctions["Kernel"] = function()
    kernelOS = os.getenv("OS")
    kernel = getGood("wmic os get version")
    local out = kernelOS.." "..kernel
    if fancyData then
        for i = 1,3 do
            out = out:gsub("%"..("_.-"):sub(i,i),brightColor..("_.-"):sub(i,i)..resetColor)
        end
    end
    return out
end

lineFunctions["Uptime"] = function()
    local lastBootUp = lineFromFile(io.popen("wmic os get lastbootuptime"),2)
    local pattern="(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)"
    local year,month,day,hour,min,sec=(lastBootUp):match(pattern)
    time1 = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    })
    local seconds = os.difftime(os.time(),time1)
    local hours = (seconds-(seconds%3600))/3600
    local remainingSeconds = (seconds-(hours*3600))
    local minutes = (remainingSeconds-(remainingSeconds%60))/60
    local seconds = seconds-(hours*3600+minutes*60)
    local nhours = hours%24
    local days = (hours-nhours)/24
    local hours = nhours
    days = brightColor .. days .. "\027[0m"
    hours = colorCap(hours,23)..hours.."\027[0m"
    minutes = colorCap(minutes,60)..minutes.."\027[0m"
    seconds = colorCap(seconds,60)..seconds.."\027[0m"
    out = ("%s days %s hours %s mins %s secs"):format(days,hours,minutes,seconds)
    local pattern = "[^%d]1\027%[0m %a+[s]"
    repeat
        if out:match(pattern) then
            out = out:gsub(pattern,out:match(pattern):gsub("s",""),1):gsub(1,1)
            out = out:gsub("[%s]ec"," sec")  --  If one second, fix issue with matching "1 s"
        end
    until not out:match(pattern)
    return out
end

lineFunctions["Memory"] = function()
    local ramSize = getGood("wmic os get totalvisiblememorysize")
    local ramFree = getGood("wmic os get freephysicalmemory")
    ramUsed = ramSize - ramFree
    ramUsed = math.floor((tonumber(ramUsed)/1024)+.5)
    ramSize = math.floor((tonumber(ramSize)/1024)+.5)
    local color = colorCap(ramUsed,ramSize)
    usedPercentage = math.floor((ramUsed/ramSize*100)*10+0.5)/10
    if fancyData then
        out = "["..color..ramUsed.."\027[0m/"..brightColor..ramSize
        out = out.."\027[0m] MB ("..color..usedPercentage.."%\027[0m)"
        return out
    else
        return color..ramUsed.."\027[0m/"..ramSize.." \027[0mMB"
    end
end

local slider


lineFunctions["Visual Style"] = function()
    local theme
    local dir = {"HKCU","Software","Microsoft","Windows","CurrentVersion","ThemeManager"}
    local stringToMatch1 = "[%w%_]+%s+[%w%_]+%s+([%w%_%-%s%%%p]+)"
    local stringToMatch2 = "([%:%p%w%s%\\]+%\\)([%w%_%-%s%%%p]+)"
    local regKey = "reg query "..table.concat(dir,"\\").." /v DllName"
    local themeFileName = lineFromFile(io.popen("cmd /c \"2>nul "..regKey.."\""),3)
    if not themeFileName then
        --  There isn't a visual style found, just use the theme file
        --  Often in the case of Windows Classic
        dir[6] = "Themes"
        local regKey = "reg query "..table.concat(dir,"\\").." /v CurrentTheme"
        local themeName = lineFromFile(io.popen("cmd /c \"2>nul "..regKey.."\""),3)
        themeName = themeName:match(stringToMatch1)
        pathToTheme,themeName = themeName:match(stringToMatch2)
        --  This is more difficult, currently reads the .theme file, if it is
        --  determined that it is Windows Classic, use "Windows Classic",
        --  otherwise trim the file extension from the theme file and use that.
        local command = "cmd /c type \""..pathToTheme..themeName.."\""
        for line in io.popen(command):lines() do
            found,result = line:find("ColorStyle")
            if found then
                if line:find("Classic") then
                    theme = "Windows Classic"
                else
                    theme = themeName:match("([%s%w]+)")
                    if theme:lower() == "classic" then
                        theme = "Windows Classic"
                    end
                end
            end
        end
    else
        local themeFileName = themeFileName:match(stringToMatch1)
        pathToTheme,themeName = themeFileName:match(stringToMatch2)
        theme = themeName:match("([%p%w%s%_%$-]+).msstyle")
        --  Trimming the file extension should be fine for this.
    end
    return theme
end

lineFunctions["bbLean Theme"] = function()
    local bbLeanTheme
    local tasks = io.popen("tasklist") -- Get task list
    for line in tasks:lines() do
        task = line:match("(%w+)%.exe")
        if task == "blackbox" then
            --  Check for bbLean
            local drive = os.getenv("HOMEDRIVE")
            local dir = "2>&1 cmd /c dir /b "..drive.."\\bbLean "
            if os.getenv("TERM") == "cygwin" then
                dir = dir:gsub("\\","\\\\")
            end
            local dir = io.popen(dir):read()
            if not dir:find("File Not Found") then
                for line in io.open(drive.."/bbLean/blackbox.rc","r"):lines() do
                    key, val = line:match("([%w%.]+): (.+)")
                    if key == "session.styleFile" then
                        bbLeanTheme = val:match("[\\/](.+)")
                    end
                end
            end
        end
    end
    if not bbLeanTheme then
        if data256Color then
            return "\027[38;5;240mNot found"
        else
            return "\027[1;30mNot found"
        end
    end
    bbLeanTheme = bbLeanTheme:gsub("[^\032%w%p_]","")
    return CamelCase(bbLeanTheme)
end

lineFunctions["Resolution"] = function()
    local height,heightLines = io.popen("wmic desktopmonitor get screenheight"),{}
    local width,widthLines = io.popen("wmic desktopmonitor get screenwidth"),{}
    local monitorHeights,monitorWidths = {},{}
    for line in height:lines() do
        table.insert(heightLines,line)
    end
    for line in width:lines() do
        table.insert(widthLines,line)
    end
    for i = 1,math.max(#heightLines,#widthLines) do
        if heightLines[i]:match("%d+") then
            table.insert(monitorHeights,heightLines[i]:match("%d+"))
        end
        if widthLines[i]:match("%d+") then
            table.insert(monitorWidths,widthLines[i]:match("%d+"))
        end
    end
    local out = ""
    for i = 1,#monitorHeights do
        if fancyData then
            out = out..monitorWidths[i]..brightColor.."x\027[0m"..monitorHeights[i].."\n"
        else
            out = out..monitorWidths[i].."x"..monitorHeights[i].."\n"
        end
    end
    return out
end

lineFunctions["CPU"] = function()
    local cpu,cpuLine = io.popen("wmic cpu get name"),""
    for line in cpu:lines() do
        if line and not line:lower():find("name") and line:find("%w") then
            cpuLine = cpuLine..line:gsub("%s+"," "):gsub("%([RTM]+%)","").."\n"
        end
    end
    if useCPUUsage then
        local usage = io.popen("wmic cpu get loadpercentage")
        for line in usage:lines() do
            if line:match("%d+") then
                local usage = colorCap(tonumber(line:match("%d+")),100)..line:match("%d+").."%"
                if not fancyData then
                    return cpuLine.."\027[0mLoad = "..usage
                else
                    return cpuLine.."\027[0mLoad "..brightColor.."= "..usage
                end
            end
        end
    else
        return cpuLine
    end
end

lineFunctions["GPU"] = function()
    local gpu,gpuLine = io.popen("wmic path Win32_VideoController get caption"),""
    for line in gpu:lines() do
        if line and not line:lower():find("caption") and line:find("%w") then
            gpuLine = gpuLine .. line:gsub("%s+"," "):gsub("%([RTM]+%)","") .. "\n"
        end
    end
    return gpuLine:sub(1,-1)
end

lineFunctions["Disk Space"] = function()
    local space = io.popen("wmic logicaldisk get freespace")
    local size = io.popen("wmic logicaldisk get size")
    local spaceLines,sizeLines = {},{}
    local line = ""
    for line in space:lines() do
        if line:find("%d") then
            table.insert(spaceLines,line:match("%d+"))
        end
    end
    for line in size:lines() do
        if line:find("%d") then
            table.insert(sizeLines,line:match("%d+"))
        end
    end
    for i = 1,#sizeLines do
        local used = tonumber(sizeLines[i]) - tonumber(spaceLines[i])
        if not fancyData then
            local usedGB = math.floor(used/1024^3+0.5)
            local spaceGB = math.floor(tonumber(sizeLines[i])/1024^3+0.5)
            local color = colorCap(usedGB,spaceGB)
            line = line..color..usedGB.."\027[0m/"..spaceGB.."GB\n"
        else
            local usedGB = math.floor(used*10/1024^3+0.5)/10
            local spaceGB = math.floor(tonumber(sizeLines[i])*10/1024^3+0.5)/10
            local color = colorCap(usedGB,spaceGB)
            local percent = usedGB/spaceGB*100
            local percent = math.floor(percent*10+0.5)/10
            local out = color..usedGB..brightColor.."/\027[0m"..spaceGB
            local out = out.." ("..color..percent.."%\027[0m) GB"
            line = line..out.."\n"
        end
    end
    return line:sub(1,-1)
end

lineFunctions["Terminal"] = function()
    local term = ""
    if not failedCygwinTest then
        term = terminal
    else
        --  There isn't really a way to check for Console2,
        --  the only other possible terminal emulator...
        term = "Command Prompt"
        local ssh = os.getenv("WINSSHDGROUP")
        --  Account for bitvise ssh here
        if ssh then
            term = "Bitvise ssh"
        end
    end
    return term
end

lineFunctions["Users"] = function()
    local userString = ""
    local users
    if not failedCygwinTest then
        users = io.popen("ls -1 /home")
        --  users = io.popen("cmd /c dir /b %HOMEDRIVE%\\\\Users")
    else
        users = io.popen("dir /b %HOMEDRIVE%\\Users")
    end
    local count = 0
    for line in users:lines() do
        local line = line:gsub("[^\032%w%p_]","")
        local bool = false
        for i = 1,#excludedUsers do
            if excludedUsers[i] == line then
                bool = true
            end
        end
        if not bool then
            local check
            if not failedCygwinTest then
                check = os.getenv("USER")
            else
                check = os.getenv("USERNAME")
            end
            if line == check then
                userString = userString..brightColor..line..resetColor..", "
            else
                userString = userString.. line..", "
            end
            count = count + 1
        end
    end
    return ("(%s) (%s%s\027[0m)"):format(userString:sub(0,-3),brightColor,count)
end

lineFunctions["MoBo"] = function()
    return getGood("wmic csproduct get name")
end

lineFunctions["Font"] = function()
    if failedCygwinTest or terminal == "cygwin" then
        if data256Color then
            return "\027[38;5;240mNot found"
        else
            return "\027[1;30mNot found"
        end
    else
        local default,font
        if terminal:find("xterm") then --attempt to pull from .minttyrc
			local dir = os.getenv("HOMEDRIVE").."\\\\cygwin\\\\home\\\\"..os.getenv("USERNAME")
			local dir = io.popen("cmd /c type "..dir.."\\\\.minttyrc")
			
            for line in dir:lines() do
                if line:sub(1,5) == "Font=" then
                    font = line:match("Font=(.+)")
                end
            end
        end
        for line in io.popen("ls -a ~ -1"):lines() do
            if line == ".Xdefaults" then
                default = ".Xdefaults"
            elseif line == ".Xresources" then
                default = ".Xresources"
            end
        end
        if default and not font then
            for line in io.popen("cat ~/"..default):lines() do
                if terminal:find("xterm") then  --  ambiguous, could be mintty or xterm
                    match = line:match("faceName: (.+)")
                    if match then font = match end
                else
                    match = line:match("font: (.+)")
                    if match then font = match end
                end
            end
        end
        if not font then
            if data256Color then
                return "\027[38;5;240mNot found"
            else
                return "\027[1;30mNot found"
            end
        else
            local font = font:gsub("xft:",""):gsub(":%w+=%w+",""):gsub(",\\",", ")
            return font
        end
    end
end

lineFunctions["WM"] = function()
    local tasks = io.popen("tasklist") -- Get task list
    local WM = ""
    local dwm = false
    for line in tasks:lines() do
        if line:find("dwm.exe") then
            if not dwm then
                if not failedCygwinTest then
                    local ps = io.popen("ps")
                    for line in ps:lines() do
                        if line:find("dwm") then
                            WM = WM.."dwm, "
                        end
                    end
                end
                dwm = true
            end
        elseif line:find("explorer.exe") and not WM:find("Explorer") then
            WM = WM.."Explorer, "
        elseif line:find("blackbox.exe") and not WM:find("bbLean") then
            WM = WM.."bbLean, "
        elseif line:find("wmfs.exe") and not WM:find("wmfs") then
            WM = WM.."wmfs, "
        elseif line:find("xfwm4") and not WM:find("xfwm4") then
            WM = WM.."xfwm4, "
        elseif line:find("bugn") and not WM:find("bug") then
            WM = WM.."bug.n, "
        end
    end
    if not WM then
        if data256Color then
            return "\027[38;5;240mNot found"
        else
            return "\027[1;30mNot found"
        end
    else
        return WM:sub(1,-3)
    end
end

lineFunctions["IRC Client"] = function()
    local tasks = io.popen("tasklist") -- Get task list
    local client = ""
    for line in tasks:lines() do
        if line:find("hexchat%.exe") then
            client = "Hexchat"
        elseif line:find("weechat%-curses%.exe") or line:find("weechat.exe") then
            client = "WeeChat"
        elseif line:find("irssi%.exe") then
            client = "irssi"
        end
    end
    if client == "" then
        if data256Color then
            return "\027[38;5;240mNot found"
        else
            return "\027[1;30mNot found"
        end
    else
        return client
    end
end

lineFunctions["Music Player"] = function()
    local tasks = io.popen("tasklist") -- Get task list
    local player = ""
    for line in tasks:lines() do
        if line:find("winamp.exe") then
            player = "Winamp"
        elseif line:find("foobar2000.exe") then
            player = "Foobar"
        elseif line:find("ncmpcpp.exe") then
            player = "ncmpcpp"
        end
    end
    if player =="" then
        if data256Color then
            return "\027[38;5;240mNot found"
        else
            return "\027[1;30mNot found"
        end
    else
        return player
    end
end

lineFunctions["Shell"] = function()
    if not failedCygwinTest then
        return os.getenv("SHELL") or "Not found"
    else
        return "CMD"
    end
end

lineFunctions["Processes"] = function()
    local tasks = io.popen("tasklist /fo csv /nh") -- Get task list
    local count = 0
    for line in tasks:lines() do
        count = count + 1
    end
    return tostring(count)
end

--//    Help information    //--

helpLines = {
    "Write an OS logo to the output with relevant information.\n",
    "  -h, --help            Write what you're looking at to the output",
    "  -c, --color COLOR     Change the color of the logo",
    "                             red, yellow, green, blue, violet",
    "                             black, white, none, cyan, rainbow",
    "  -l, --logo LOGO       Change the logo",
    "                             windows8, windows7, none",
    "  -b, --bright          Use only bright colors",
    "  -d, --dull            Use only dull colors",
    "      --showWarning     Show the Ansicon/Cygwin PTY warning.",
    "  -a, --align           Align the lines",
    "  -s, --stripe [4>#>-1] stripe the colors for the logo in the manner of screenfo",
    "                            Argument: 0: do not stripe (auto)",
    "                                      1: stripe vertically",
    "                                      2: stripe horizontally",
    "                                      3: stripe diagonally",
    "  -B, --block [#>0]     use a stripe step as high and/or as wide as the argument",
    "                            Default: 1",
    "  -L, --lefty           Flip the logo and information",
    "  -C, --center          Center information vertically relative to logo",
    "  -2, --256color        Use 256 colors",
    "  -1, --18color         Force use of 18 colors, do not allow automatic switching",
    "  -D, --down            Position the logo at the bottom of the information",
    "\nv.3.0.2",
    "By Hal, Zanthas, tested (and approved) by KittyKatt, other people"
}

--//    Argument parsing    //--

function parseArg(arg,arg2)
    if arg == "-h" or arg == "--help" then
        for i = 1,#helpLines do  --  Dump help information
            print(helpLines[i])
        end
        return  -- Stop script here
    elseif arg == "--showWarning" then
        warning()
        return false
    elseif arg == "-D" or arg == "--down" then
        down = not down
        if down then center = false end
    elseif arg == "-2" or arg == "--256color" then
        data256Color = true
    elseif arg == "-1" or arg == "--18color" then
        data256Color = false
    elseif arg == "-c" or arg == "--color" then
        if not arg2 or not colors[string.lower(arg2)] then  --  Argument isn't correct
            print("\nError: Improper syntax for option \"--color\"")
            print("Correct syntax: ")
            print("cmdfetch \"[-c,--color] ["..table.concat(colorNames,",").."]\"")
            return false
        else
            color = string.lower(arg2)
        end
    elseif arg == "-l" or arg == "--logo" then
        if not arg2 or not logos[string.lower(arg2)] then  --  Argument isn't correct
            print("\nError: Improper syntax for option \"--logo\"")
            print("Correct syntax: ")
            print("cmdfetch \"[-l,--logo] ["..table.concat(logoNames,",").."]\"")
            return false
        else
            logo = string.lower(arg2)
        end
    elseif arg == "-b" or arg == "--bright" then
        bright = not bright
        if bright then dull = false end
    elseif arg == "-d" or arg == "--dull" then
        dull = not dull
        if dull then bright = false end
    elseif arg == "-a" or arg == "--align" then
        align = not align
    elseif arg == "-s" or arg == "--stripe" then
        local canfit = (not tonumber(arg2)) or (tonumber(arg2) < 0 or tonumber(arg2) > 3) 
        if not arg2 or canfit then
            print("\nError: Improper syntax for option \"--stripe\"")
            print("Correct syntax:")
            print("cmdfetch \"[-s,--stripe] [4 > number > -1]\"")
            return false
        else
            stripe = tonumber(arg2)
        end 
    elseif arg == "-B" or arg == "--block" then
        if not arg2 or not tonumber(arg2) or tonumber(arg2) <= 0 then  --  Argument isn't correct
            print("\nError: Improper syntax for option \"--block\"")
            print("Correct syntax:")
            print("cmdfetch \"[-b,--block] [number > 0]\"")
            return false
        else
            block = tonumber(arg2)
        end
    elseif arg == "-L" or arg == "--lefty" then
        lefty = not lefty
    elseif arg == "-C" or arg == "--center" then
        center = not center
        if center then down = false end
    elseif arg:sub(1,1) == "-" and arg:sub(2,2) ~= "-" and not arg:find("[^%-hclbdoasBLC12D]") then
        local argblock = arg:sub(2)
        for match in argblock:gmatch("%w") do
            if ("sBcl"):find(match) then
                print("\nError: use of a flag that takes an argument in a argument block")
                print("This is not allowed to ambiguity, use only switches in argument blocks")
                return
            end
            parseArg("-"..match)
        end
    elseif arg:sub(1,1) == "-" and arg:sub(2,2) ~= "-" then
        local wrongArg = arg:match("[^%-hclbdoasBLC12D]")
        print("\nError: unknown flag used in an argument block \""..wrongArg.."\" ")
        print("See --help for a list of valid arguments")
        print("You may have meant to use \"-"..arg.."\"")
        return
    else
    end
    return true
end

for i = 1,#arg do
    local passed = parseArg(arg[i],arg[i+1])
    if not passed then
        return
    end
end

if not canColor and not (color == "none") then
    warning()
    return
end

--//    Populate logo with new colors    //--

if color then
    local bar = 1
    for i = 1,math.max(#colors[color],#logos[logo]["colors"]) do
        logos[logo]["colors"][i] = colors[color][bar]
        bar = bar + 1
        if bar > #colors[color] then
            bar = 1
        end
    end
end

--//    Populate table of information    //--

local cap = 0
for i = 1,#usedLines do
    cap = math.max(cap,usedLines[i]:len())
end
local dataLines,logoLines = {},{}
for i = 1,#usedLines do
    local info = (lineFunctions[usedLines[i]]()):gsub("[^\032\027%w%p_\n]","") or "hi"
    local firstLine = true
    for line in info:gmatch("[^\n]+") do
        if not (line:lower():find("not found") and noNotFound) then
            if firstLine then
                if align then
                    table.insert(
                        dataLines,(" "):rep(cap-usedLines[i]:len())..usedLines[i]..": "..line
                    )
                else
                    table.insert(dataLines,usedLines[i]..": "..line)
                end
                firstLine = false
            else
                local cleanTag = usedLines[i]:gsub("\027%[%d-%;-%d-m","")
                if align then
                    tag = (" "):rep(cap+2)
                else
                    tag = (" "):rep(cleanTag:len()+2)
                end
                table.insert(dataLines,tag..line)
            end
        end
    end
end

for i = 1,#dataLines do
    currentColor = 0  --  reset global color for the color toggle
    local head = dataLines[i]:match(".*:")
    local tail = dataLines[i]:match(".*:(.+)")
    if head then
        if stripe == 0 then
            dataLines[i] = dataLines[i]:gsub(head,logos[logo]["colors"][1]..head.."\027[0m")
        elseif stripe == 1 then
            local newLine = ""
            for i = 1,head:len(),block do
                local color = toggleColor()
                newLine = newLine..logos[logo]["colors"][color]..head:sub(i,i+block-1)
            end
            dataLines[i] = newLine.."\027[0m"..tail
        elseif stripe == 2 then
            local step = ((i)-((i-1)%block)%block)
            local color = ((step-step%block)/block+1)%#logos[logo]["colors"]
            if color == 0 then
                color = #logos[logo]["colors"]
            end
            if block == 1 then
                color = color - 1
                if color == 0 then
                    color = #logos[logo]["colors"]
                end
            end
            dataLines[i] = logos[logo]["colors"][color]..head.."\027[0m"..tail
        elseif stripe == 3 then
            local newLine = ""
            local step = ((i)-((i-1)%block)%block)
            local mcolor = ((step-step%block)/block+1)%#logos[logo]["colors"]
            if mcolor == 0 then
                mcolor = #logos[logo]["colors"]
            end
            if block == 1 then
                mcolor = mcolor - 1
                if mcolor == 0 then
                    mcolor = #logos[logo]["colors"]
                end
            end
            for i = 1,head:len(),block do
                local color = toggleColor()
                local modColor = (color+mcolor)%#logos[logo]["colors"]
                if modColor == 0 then
                    modColor = #logos[logo]["colors"]
                end
                newLine = newLine..logos[logo]["colors"][modColor]..head:sub(i,i+block-1)
            end
            dataLines[i] = newLine.."\027[0m"..tail
        end
    end
end

if stripe ~= 0 then --stripe
    for a = 1,#logos[logo] do
        for b = 1,#logos[logo]["colors"] do
            logos[logo][a] = logos[logo][a]:gsub("${c"..b.."}","")
        end
    end
end

for i = 1,#logos[logo] do
    if stripe == 0 then
        for b = 1,#logos[logo]["colors"] do
            logos[logo][i] = logos[logo][i]:gsub("${c"..b.."}",logos[logo]["colors"][b])
        end
    elseif stripe == 1 then
        currentColor = 0  --  reset color
        local newLine = ""
        for b = 1,logos[logo][i]:len(),block do
            local color = toggleColor()
            newLine = newLine..logos[logo]["colors"][color]..logos[logo][i]:sub(b,b+block-1)
        end
        logos[logo][i] = newLine
    elseif stripe == 2 then
        local step = ((i)-((i-1)%block)%block)
        local color = ((step-step%block)/block+1)%#logos[logo]["colors"]
        if color == 0 then
            color = #logos[logo]["colors"]
        end
        if block == 1 then
            color = color - 1
            if color == 0 then
                color = #logos[logo]["colors"]
            end
        end
        logos[logo][i] = logos[logo]["colors"][color]..logos[logo][i]
    elseif stripe == 3 then
        currentColor = 0  --  reset color
        local newLine = ""
        local step = ((i)-((i-1)%block)%block)
        local mcolor = ((step-step%block)/block+1)%#logos[logo]["colors"]
        if mcolor == 0 then
            mcolor = #logos[logo]["colors"]
        end
        if block == 1 then
            mcolor = mcolor - 1
            if mcolor == 0 then
                mcolor = #logos[logo]["colors"]
            end
        end
        for b = 1,logos[logo][i]:len(),block do
            local color = toggleColor()
            local modColor = (color+mcolor)%#logos[logo]["colors"]
            if modColor == 0 then
                modColor = #logos[logo]["colors"]
            end
            newLine = newLine..logos[logo]["colors"][modColor]..logos[logo][i]:sub(b,b+block-1)
        end
        logos[logo][i] = newLine
    end
end

local newLogo = {}
local lLines,dLines = #logos[logo],#dataLines
local dataWidth = 0
for i = 1,#dataLines do
    dataWidth = math.max(dataWidth,dataLines[i]:gsub("\027%[[%d;]+m",""):len())
end


for i = 1,#dataLines do
    if lefty then
        dataLines[i] = dataLines[i].." "
    else
        dataLines[i] = " "..dataLines[i]
    end
end

if center then
    if lLines < dLines then
        up = math.floor((dLines-lLines)/2)
        down = math.ceil((dLines-lLines)/2)
        local logoWidth = logos[logo][1]:gsub("\027%[[%d;]+m",""):len()
        for i = 1,up do
            if not lefty then
                table.insert(newLogo,(" "):rep(logoWidth)..dataLines[i])
            else
                table.insert(newLogo,dataLines[i])
            end
        end
        for i = 1,lLines do
            if not lefty then
                table.insert(newLogo,logos[logo][i]..dataLines[up+i])
            else
                local pad = dataLines[up+i]:len()-dataLines[up+i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[up+i]:len()
                local out = (dataLines[up+i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        end
        for i = 1,down do
            if not lefty then
                table.insert(newLogo,(" "):rep(logoWidth)..dataLines[lLines+up+i])
            else
                table.insert(newLogo,dataLines[lLines+up+i])
            end
        end
    elseif lLines > dLines then
        up = math.floor((lLines-dLines)/2)
        down = math.ceil((lLines-dLines)/2)
        for i = 1,up do
            if not lefty then
                table.insert(newLogo,logos[logo][i])
            else
                table.insert(newLogo,(" "):rep(dataWidth)..logos[logo][i])
            end
        end
        for i = up+1,lLines-down do
            if not lefty then
                table.insert(newLogo,logos[logo][i]..dataLines[i-up])
            else
                local pad = dataLines[i-up]:len()-dataLines[i-up]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i-up]:len()
                local out = (dataLines[i-up]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        end
        for i = lLines-down+1,lLines do
            if not lefty then
                table.insert(newLogo,logos[logo][i])
            else
                table.insert(newLogo,(" "):rep(dataWidth)..logos[logo][i])
            end
        end
    else
        for i = 1,lLines do
            if not lefty then
                table.insert(newLogo,logos[logo][i]..dataLines[i])
            else
                local pad = dataLines[i]:len()-dataLines[i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i]:len()
                local out = (dataLines[i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        end
    end
elseif down then
    local logoWidth = logos[logo][1]:gsub("\027%[[%d;]+m",""):len()
    local up = dLines-lLines
    if lLines < dLines then
        if lefty then
            for i = 1,up do
                table.insert(newLogo,dataLines[i])
            end
            for i = 1,lLines do
                local pad = dataLines[up+i]:len()-dataLines[up+i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[up+i]:len()
                local out = (dataLines[up+i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        else
            for i = 1,up do
                table.insert(newLogo,(" "):rep(logoWidth)..dataLines[i])
            end
            for i = 1,lLines do
                table.insert(newLogo,logos[logo][i]..dataLines[up+i])
            end
        end
    elseif lLines == dLines then
        if lefty then
            for i = 1,lLines do
                local pad = dataLines[i]:len()-dataLines[i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i]:len()
                local out = (dataLines[i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        else
            for i = 1,lLines do
                table.insert(newLogo,logos[logo][i]..dataLines[i])
            end
        end
    elseif lLines > dLines then
        for i = 1,lLines-dLines do
            if not lefty then
                table.insert(newLogo,logos[logo][i])
            else
                table.insert(newLogo,(" "):rep(dataWidth)..logos[logo][i])
            end
        end
        for i = 1,dLines do
            if not lefty then
                table.insert(newLogo,logos[logo][lLines-dLines+i]..dataLines[i])
            else
                local pad = dataLines[i]:len()-dataLines[i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i]:len()
                local out = (dataLines[i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][lLines-dLines+i])
            end
        end
    end
else
    local logoWidth = logos[logo][1]:gsub("\027%[[%d;]+m",""):len()
    local up = dLines-lLines
    if lLines < dLines then
        if lefty then
            for i = 1,lLines do
                local pad = dataLines[i]:len()-dataLines[i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i]:len()
                local out = (dataLines[i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
            for i = 1,up do
                table.insert(newLogo,dataLines[i+lLines])
            end
        else
            for i = 1,lLines do
                table.insert(newLogo,logos[logo][i]..dataLines[i])
            end
            for i = 1,up do
                table.insert(newLogo,(" "):rep(logoWidth)..dataLines[i+lLines])
            end
        end
    elseif lLines == dLines then
        if lefty then
            for i = 1,lLines do
                local pad = dataLines[i]:len()-dataLines[i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i]:len()
                local out = (dataLines[i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        else
            for i = 1,lLines do
                table.insert(newLogo,logos[logo][i]..dataLines[i])
            end
        end
    elseif lLines > dLines then
        for i = 1,dLines do
            if not lefty then
                table.insert(newLogo,logos[logo][i]..dataLines[i])
            else
                local pad = dataLines[i]:len()-dataLines[i]:gsub("\027%[[%d;]+m",""):len()
                local width = dataLines[i]:len()
                local out = (dataLines[i]..(" "):rep(dataWidth)):sub(1,pad+dataWidth)
                table.insert(newLogo,out..logos[logo][i])
            end
        end
        for i = 1,lLines-dLines do
            if not lefty then
                table.insert(newLogo,logos[logo][i+dLines])
            else
                table.insert(newLogo,(" "):rep(dataWidth)..logos[logo][i+dLines])
            end
        end
    end
end

for i = 1,#newLogo do
    out = "\027[0m"..newLogo[i].."\027[0m"
    if bright then
        out = out:gsub("\027%[0;","\027[1;")
    end
    if dull then
        out = out:gsub("\027%[1;","\027[0;")
    end
    if color and color:lower() == "none" then
        out = out:gsub("\027%[[%d;]+m","")
    end
    print(out)
end
>>>>>>> a9d68a46d9331341072428e602de4427424c0a59
