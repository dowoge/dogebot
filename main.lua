local discordia = require('discordia')
local json = require('json')
local http = require('coro-http')
local client = discordia.Client()
local token = require('./modules/token.lua')
local APIKey = require('./modules/apikey.lua')
local APIHeader = {{'api-key',APIKey}}
local prefix = '%'
local strafesurl = 'https://api.strafes.net/v1/'
discordia.extensions()

local games={
    ['bhop']=1,
    ['surf']=2
}

local states={
    [0]='default',
    [1]='whitelisted',
    [2]='blacklisted',
    [3]='pending'
}
local styles={
    ['autohop']=1,
    ['scroll']=1,
    ['sideways']=1,
    ['halfsideways']=1,
    ['wonly']=1,
    ['aonly']=1,
    ['backwards']=1
}
local ranks={
    'New',
    'Newb',
    'Bad',
    'Okay',
    'Not Bad',
    'Decent',
    'Getting There',
    'Advanced',
    'Good',
    'Great',
    'Superb',
    'Amazing',
    'Sick',
    'Master',
    'Insane',
    'Majestic',
    'Baby Jesus',
    'Jesus',
    'Half God',
    'God'
}
local get=function(url,headers,params)
    local _,body=http.request('GET',url,headers,params)
    body=json.decode(body)
    return body
end
local getUserID=function(name)
    if type(tonumber(name))=='number' then
        return name
    else
        return get('https://api.roblox.com/users/get-by-username?username='..name)['Id']
    end
    return 'No user found'
end
local getUserInfoFromID=function(id)
    return get('https://users.roblox.com/v1/users/'..id)
end
--[[
    {
        "description": "",
        "created": "2016-04-26T05:46:54.483Z",
        "isBanned": false,
        "id": 123,
        "name": "trolla",
        "displayName": "trolla"
    }
]]

client:on('ready', function()
	client:info('yeah '.. client.user.tag)
	client:info('--------------------------------------------------------------')
end)

client:on('messageCreate',function(message)
    local content = message.content
    local args=content:split(' ')
    if args[1]==prefix..'user' and args[2] then
        local id=getUserID(args[2])
        local info=getUserInfoFromID(id)
        local res=get(strafesurl..'user/'..id,APIHeader)
        message:reply(info.displayName..' ('..info.name..')')
        message:reply(res.ID)
        message:reply(states[res.State])
    elseif args[1]==prefix..'rank' and args[2] then
        local id=getUserID(args[2])
        local game=games[args[3]]
        local style=styles[args[4]]
        local res=get(strafesurl..'rank/'..id..'?style='..style..'&game='..game,APIHeader) --/id?style=1&game=2
        local stats={
            rank=ranks[math.floor((res.Rank*19)+1)],
            skill=string.sub(tostring(res.Skill*100), 1, #'00.000')..'%',
            placement=res.Placement
        }
        message:reply(stats.rank)
        message:reply(stats.skill)
        message:reply(stats.placement)
    end
end)


client:run('Bot '..token)
