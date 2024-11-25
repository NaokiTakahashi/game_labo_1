pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
ws = {}
function ws.push(tbl)
  index = #ws+1
  ws[index] = tbl
  ws[index].selected = ws[index].selected or 1
  ws[index].visible = ws[index].visible or true
  return index
end

function ws.pop()
  ws[#ws] = nil
end

function ws.draw()
  for w in all(ws) do
    if w.visible then
      rectfill(w.x-4,w.y-4,w.x+w.w+4,w.y+w.h+4,0)
      rect(w.x-4,w.y-4,w.x+w.w+4,w.y+w.h+4,7)
      if w.title then
        print("\#0"..w.title, w.x, w.y-6, 7) 
      end
      for i=1,#w.texts do
        if w.is_info then
          print(w.texts[i],w.x,w.y+i*6-4,7)
        else
          local color
          if w.selected == i then
            color = 7
            print(">",w.x,w.y+i*6-4,7)
          else
            color = 13
          end
          print(w.texts[i],w.x+8,w.y+i*6-4,color)
        end
      end
    end
  end
end

function ws.update()
  if (#ws == 0) return
		if ws[#ws].is_info then
		  return
		end
  local s = ws[#ws].selected
  local num = #(ws[#ws].texts)
  if btnp(⬇️) then
    s+=1
    if s>num then
      s = 1
    end
  elseif btnp(⬆️) then
    s-=1
    if s<1 then
      s = num
    end
  end
  ws[#ws].selected = s
  if btnp(🅾️) then
    if ws[#ws].callback ~= nil then
      ws[#ws].callback(s)
    end
  elseif btnp(❎) then
    if ws[#ws].cancel ~= nil then
      ws[#ws].cancel()
    end
  end
end


-->8
local message={
  index = nil,
  printing = false,
  l=1,
  n=1,
  texts={},
  btn_flag=false,
  callback=nil,
  waiting=false
}

function message.init()
  if message.index == nil then
    message.index = ws.push{x=8,y=100,w=112,h=20,
      texts={
      },
      is_info=true,
      visible=true,
    }
  end
end

function message.set_visible(visible)
  ws[message.index].visible = visible
end

function message.print(texts,callback)
  ws[message.index].texts = {}
  message.printing = true
  while #texts<3 do
    texts[#texts+1]=" "
  end
  message.texts = texts
  message.l = 1
  message.n = 1
  message.btn_flag = false
  message.callback = callback
  message.waiting = false
end

function message.update()
  if (not message.printing) return
  if message.n < 4 then
    if message.l < #message.texts[message.n] then
      ws[message.index].texts[message.n]=sub(message.texts[message.n],1,message.l)
      message.l+=2
    else
      ws[message.index].texts[message.n]=message.texts[message.n]
      message.n+=1
      message.l=1
    end
		else
		  message.waiting = true
		  if btnp(🅾️) then
		    message.btn_flag = true
		  end
		  if message.btn_flag and not btn(🅾️) then
				  message.waiting = false
				  message.btn_flag = false
				  message.printing = false
				  message.callback()
		  end
  end
end

-->8
function _init()
  poke(0x5f5c, 255)
  message.init()
  game_main()
end

function _update()
  message.update()
  ws.update()
end

function _draw()
  cls()
  ws.draw()
  if message.waiting then
    print("◆",116,116,7)
  end
end


-->8
local hp=20
local mp=12
local hpmax=40
local mpmax=40
local status_w
function game_main()
  open_status()
  message.print({"モンスタ-か゛あらわれた。"}, open_command)
end

function open_status()
  status_w = ws.push{x=8,y=8,w=40,h=20,
    title="ステ-タス",
    is_info=true
  }
  set_status()
end

function set_status()
  ws[status_w].texts={
    "ゆうしゃ",
    "hp:"..hp.."/"..hpmax,
    "mp:"..mp.."/"..mpmax
  }
end

function open_command()
  ws.push{x=40,y=74,w=48,h=20,
    title="コマント゛",
    texts={
      "たたかう",
      "まほう",
      "にけ゛る"},
    callback=command,
  }
end

function command(i)
  if i==1 then
  ws.push{x=60,y=80,w=48,h=20,
    title="たたかう",
    texts={
      "スライム",
      "コウモリ",
      "コ゛フ゛リン"},
    callback=attack,
    cancel=function()
      ws.pop()
    end,
  }
  elseif i==2 then
  ws.push{x=60,y=80,w=48,h=20,
    title="まほう",
    texts={
      "ほのお",
      "こおり",
      "かいふく"},
    callback=magic,
    cancel=function()
      ws.pop()
    end
  }
  else
    runaway()
  end
end

function attack(i)
  local enemy = ws[#ws].texts[i]
  ws.pop()
  ws.pop()
  sfx(0)
  message.print({"あなたのこうけ゛き!",enemy.."に3のタ゛メ-シ゛!"},open_command)
end

function magic(i)
  local magic = ws[#ws].texts[i]
  ws.pop()
  ws.pop()
  sfx(1)
  if mp<4 then
    message.print({magic.."のまほうをとなえた!","しかしmpか゛たりない。"}, open_command)
  else
    mp-=4
    if i==3 then
      message.print({magic.."のまほうをとなえた!","hpか゛かいふくした。"}, open_command)
      hp=hpmax
    else
      message.print({magic.."のまほうをとなえた!","こうかか゛なかった。"}, open_command)
    end
    set_status()
  end
end

function runaway()
  ws.pop()
  sfx(2)
  message.print({"あなたはにけ゛た゛した!","まわりこまれてしまった..."}, open_command)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002e4702e4702d4702d4602c4602b4702a4702947028470274702746027450254602546024460244702446022460204601e4701e4601c4601b4601a470194701947017470174701645013450114500e450
0001000010450104501145010450104500f4500f4500e4500e4500b4500e4500d4500c450104501145012450144501645017450194501c4501e450204502445026450294502f45033450394503d4503f45000000
000100002a4500000029450204501a450154501545015450174501a450214502a4502c450214501b4500b4500b4500b450124501c4502045021450204501d45018450144501b4501e4501f450204501b45012450
