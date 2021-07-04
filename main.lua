local discordia = require('discordia')
local json = require('json')
local http = require('coro-http')
local client = discordia.Client()
local ordinal = require('./modules/ordinal.lua')
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
    ['scroll']=2,
    ['sideways']=3,
    ['halfsideways']=4,
    ['wonly']=5,
    ['aonly']=6,
    ['backwards']=7
}
local stylesr={
    'Autohop',
    'Scroll',
    'Sideways',
    'Half-Sideways',
    'W-Only',
    'A-Only',
    'Backwards',
}
setmetatable(styles,{__index=function(self,i)
    if i=='a' then i='auto'elseif i=='hsw'then i='half'elseif i=='s'then i='scroll'elseif i=='sw'then i='side'elseif i=='bw'then i='back'end
    for ix,v in pairs(self) do
        if string.sub(ix,1,#i):find(i:lower()) then
            return self[ix]
        end
    end
end})
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
local getUserID=function(message,name)
    if type(tonumber(name))=='number' then
        return name
    else
        return get('https://api.roblox.com/users/get-by-username?username='..name)['Id']
    end
    message:reply('No user found')
end
local getUserInfoFromID=function(userid)
    return get('https://users.roblox.com/v1/users/'..userid)
end
local getIdFromRover=function(message,userid)
    local idfromRover=get('https://verify.eryn.io/api/user/'..userid)
    if not idfromRover.error then
        return idfromRover.robloxId
    end
    message:reply(idfromRover.error)
    return
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
    client:setGame({name='%help';type=2})
end)


client:on('messageCreate',function(message)
    local content = message.content
    local author = message.author
    local mention = message.mentionedUsers and message.mentionedUsers.first or nil

    local args = content:split(' ')
    -- [user lookup]
    if args[1] == prefix..'user' and args[2] then
        if args[2]:find('@') or args[2]=='me' then
            local id=getIdFromRover(message,(mention and mention.id or author.id))
            if not id then return end
            local info=getUserInfoFromID(id)
            local res=get(strafesurl..'user/'..id,APIHeader)
            message:reply('```'..info.displayName..' ('..info.name..')\n'..res.ID..'\n'..states[res.State]..'```')
        elseif args[2]~='me' and not args[2]:find('@') then
            local id=getUserID(message,args[2])
            if not id then message:addReaction('❌') return end
            local info=getUserInfoFromID(id)
            local res=get(strafesurl..'user/'..id,APIHeader)
            message:reply('```'..info.displayName..' ('..info.name..')\n'..res.ID..'\n'..states[res.State]..'```')
        end
    elseif args[1]==prefix..'rank' and args[2] then
        if args[2]:find('@')or args[2]=='me'then
            local id=getIdFromRover(message,(mention and mention.id or author.id))
            local game=games[args[3]]
            local style=styles[args[4]]
            if not id then message:addReaction('❌') return end
            local res
            local s,e=pcall(function()
                res=get(strafesurl..'rank/'..id..'?style='..style..'&game='..game,APIHeader) --/id?style=1&game=2
            end)
            print(s,e)
            if not s then message:reply('style/game specified incorrectly i think')return end
            local stats={
                style=stylesr[style],
                rank=ranks[math.floor((res.Rank*19)+1)],
                skill=math.floor(res.Skill*100)~=100 and string.sub(tostring(res.Skill*100), 1, #'00.000')..'%' or '100.000%',
                placement=res.Placement
            }
            message:reply('```Style: '..stats.style..'\nRank: '..stats.rank..'\nSkill: '..stats.skill..'\nPlacement: '..ordinal(res.Placement)..'```')
        else
            local id = getUserID(message,args[2])
            local game=games[args[3]]
            local style=styles[args[4]]
            if not id then message:addReaction('❌') return end
            local res
            local s,e=pcall(function()
                res=get(strafesurl..'rank/'..id..'?style='..style..'&game='..game,APIHeader) --/id?style=1&game=2
            end)
            print(s,e)
            if not s then message:reply('style/game specified incorrectly i think')return end
            local stats={
                style=stylesr[style],
                rank=ranks[math.floor((res.Rank*19)+1)],
                skill=math.floor(res.Skill*100)~=100 and string.sub(tostring(res.Skill*100), 1, #'00.000')..'%' or '100.000%',
                placement=res.Placement
            }
            message:reply('```Style: '..stats.style..'\nRank: '..stats.rank..'\nSkill: '..stats.skill..'\nPlacement: '..ordinal(res.Placement)..'```')
        end
    elseif args[1]==prefix..'help'then
        message:reply('```rank <user> <game> <style>\nuser <user>\nhelp```')
    end
end)

-- 🤮🤮
-- client:on('messageCreate',function(message)
--     local content = message.content
--     local author = message.author
--     local args=content:split(' ')
--     if args[1]==prefix..'rank' and args[2] then
--         local id=getUserID(message,args[2])
--         local game=games[args[3]]
--         local style=styles[args[4]]

--         if args[2]:lower()=='me'then
--             local idfromRover=get('https://verify.eryn.io/api/user/'..message.author.id)
--             if idfromRover.error then
--                 message:reply(idfromRover.error)
--                 return
--             else
--                 id=getUserID(message,idfromRover.robloxId)
--             end
--         end


--         local res=get(strafesurl..'rank/'..id..'?style='..style..'&game='..game,APIHeader) --/id?style=1&game=2
--         local stats={
--             rank=ranks[math.floor((res.Rank*19)+1)],
--             skill=string.sub(tostring(res.Skill*100), 1, #'00.000')..'%',
--             placement=res.Placement
--         }
--         message:reply(stats.rank)
--         message:reply(stats.skill)
--         message:reply(stats.placement)
--     end
-- end)


client:run('Bot '..token)
