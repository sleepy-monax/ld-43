json = require('libs.json')
inspect = require('libs.inspect')

DEBUG = true
LANG = "en"

-- Love2d callbacks ------------------------------------------------------------

function love.load(arg)
  -- Load decks
  deckmanager_init()
  game_load()

  math.randomseed(os.time())

  love.graphics.setDefaultFilter("nearest", "nearest", 0)

  print("Loading fonts...")

  assets_font_romulus_big = love.graphics.newFont("assets/romulus.ttf", 32)
  assets_font_romulus = love.graphics.newFont("assets/romulus.ttf", 26)

  print("Loading images...")
  icons = {}
  local files = love.filesystem.getDirectoryItems("assets/icons")
  for k, file in ipairs(files) do
    icons[file] = love.graphics.newImage("assets/icons/" .. file)
  	print(k .. ". " .. file)
  end
end

function love.update(dt)
  mouse_update()
  game_update(dt)
end

function love.draw()
  game_draw()
end


-- Deck Managments -------------------------------------------------------------

function deckmanager_init()
  loaded_deck = {}
end

function deckmanager_load(name)
  if loaded_deck[name] == nil then
    if love.filesystem.exists("decks/" .. name .. ".json") then
      local deck_json = love.filesystem.read("decks/" .. name .. ".json")
      local deck_data = json.decode(deck_json)

      print("Deck loaded '" .. name .. "' !")

      loaded_deck[name] = deck_data
      return deck_data

    else
      error("No deck named '" .. name .. "' !")
    end
  else
    return loaded_deck[name]
  end
end

function deck_unlock(name)
  print("Deck unlocked '" .. name .. "' !")

  if decks[name] == nil then
    decks[name] = deckmanager_load(name)
  end

  return deck
end

function deck_lock(name)
  print("Deck locked '" .. name .. "' !")
  decks[name] = nil
end

-- Deck managment --------------------------------------------------------------

function card_valid_equal(card)
  local requirements = card.requirement.equal

  if (requirements == nil) then return true end

  local r = true

  for k,v in pairs(requirements) do
    r = r and game_states[k] == v
  end

  return r
end

function card_valid_morethan(card)
  local requirements = card.requirement.morethan

  if (requirements == nil) then return true end

  local r = true

  for k,v in pairs(requirements) do
    if game_states[k] == nil then return false end
    r = r and game_states[k] > v
  end

  return r
end

function card_valid_lessthan(card)
  local requirements = card.requirement.lessthan

  if (requirements == nil) then return true end

  local r = true

  for k,v in pairs(requirements) do
    if game_states[k] == nil then return false end
    r = r and game_states[k] < v
  end

  return r
end

function card_valid_morethanorequal(card)
  local requirements = card.requirement.morethanorequal

  if (requirements == nil) then return true end

  local r = true

  for k,v in pairs(requirements) do
    if game_states[k] == nil then return false end
    r = r and game_states[k] >= v
  end

  return r
end

function card_valid_lessthanorequal(card)
  local requirements = card.requirement.lessthanorequal

  if (requirements == nil) then return true end

  local r = true

  for k,v in pairs(requirements) do
    if game_states[k] == nil then return false end
    r = r and game_states[k] <= v
  end

  return r
end

function deck_get_nextcard()
  local valid_card = {}
  local sum_weight = 0

  for _, deck in pairs(decks) do
    for _, card in ipairs(deck) do
      if card.weight ~= nil and card.weight > 0 then
        if card.requirement == nil or
           card_valid_equal(card) and
           card_valid_lessthan(card) and
           card_valid_morethan(card) and
           card_valid_lessthanorequal(card) and
           card_valid_morethanorequal(card) then

           table.insert(valid_card, card)
           sum_weight = sum_weight + card.weight
        end
      end
    end
  end

  local rnd_weight = math.random(0, sum_weight * 100) / 100

  for _,card in ipairs(valid_card) do
    rnd_weight = rnd_weight - card.weight
    if rnd_weight <= 0 then
      return card
    end
  end

  error("Out of card")
end


function deck_get_nextcard_in_deck(deck)
  local valid_card = {}
  local sum_weight = 0


  for _, card in ipairs(deck) do
    if card.weight ~= nil and card.weight > 0 then
      if card.requirement == nil or
         card_valid_equal(card) and
         card_valid_lessthan(card) and
         card_valid_morethan(card) and
         card_valid_lessthanorequal(card) and
         card_valid_morethanorequal(card) then

         table.insert(valid_card, card)
         sum_weight = sum_weight + card.weight
      end
    end
  end


  local rnd_weight = math.random(0, sum_weight * 100) / 100

  for _,card in ipairs(valid_card) do
    rnd_weight = rnd_weight - card.weight
    if rnd_weight <= 0 then
      return card
    end
  end

  error("Out of card")
end

function deck_get_nextcard_by_nick(nick)
  for _, deck in pairs(loaded_deck) do
    for _, card in ipairs(deck) do
      if card.nick == nick then
        return card
      end
    end
  end

  error("No card named " .. nick .. "!")
end

-- card ------------------------------------------------------------------------

function card_do_respond(respond)
  animation = 1

  -- Set game states
  if respond.set ~= nil then
    for k,v in pairs(respond.set) do
      print("set ".. k .. ":" .. tostring(v))
      game_states[k] = v
    end
  end

  -- Add game states
  if respond.add ~= nil then
    for k,v in pairs(respond.add) do
      print("add ".. k .. ":" .. tostring(v))
      if game_states[k] == nil then
        game_states[k] = v
      else
        game_states[k] = game_states[k] + v
      end
    end
  end

  -- Substract game states
  if respond.sub ~= nil then
    for k,v in pairs(respond.sub) do
      print("sub ".. k .. ":" .. tostring(v))
      if game_states[k] == nil then
        game_states[k] = -v
      else
        game_states[k] = game_states[k] - v
      end
    end
  end

  -- Unlock decks
  if respond.unlock ~= nil then
    for i,v in ipairs(respond.unlock) do
      deck_unlock(v)
    end
  end

  -- lock decks
  if respond.lock ~= nil then
    for i,v in ipairs(respond.lock) do
      deck_lock(v)
    end
  end

  -- get the next card
  if respond.nextcard ~= nil then
    current_card = deck_get_nextcard_by_nick(respond.nextcard)
  elseif respond.nextindeck ~= nil then
    current_card = deck_get_nextcard_in_deck(deckmanager_load(respond.nextindeck))
  else
    current_card = deck_get_nextcard()
  end
end

function card_draw()
    animation = animation*0.90
  -- Render the card title
  local text = love.graphics.newText( assets_font_romulus_big, current_card.question[LANG] )
  love.graphics.setColor(0,0,0, 0.45)
  love.graphics.draw(text, love.graphics.getWidth()  / 2 + 4,
                           love.graphics.getHeight() / 2 - 128 + 4,
                           0, 1, 1,
                           text:getWidth() / 2, text:getHeight() / 2)

  love.graphics.setColor(1,1,1)
  love.graphics.draw(text, love.graphics.getWidth()  / 2,
                           love.graphics.getHeight() / 2 - 128,
                           0, 1, 1,
                           text:getWidth() / 2, text:getHeight() / 2)

  -- Render card option
  love.graphics.setColor(1, 1, 1)

  for i, respond in ipairs(current_card.respond) do
    if button(love.graphics.getWidth()  / 2 - (480/2) * (1 - animation),
              love.graphics.getHeight() / 2 + (72 * (i + 1)) * (1 - animation) - 72,
              480 * (1 - animation),
              64 * (1 - animation), respond[LANG], (1-animation)) then
      card_do_respond(respond)
    end
  end
end

-- game loop -------------------------------------------------------------------

function game_load()
  decks = {}
  animation = 1

  local game_states_json = love.filesystem.read("game_states.json")
  game_states = json.decode(game_states_json)

  local game_states_names_json = love.filesystem.read("attribute.json")
  game_states_names = json.decode(game_states_names_json)

  deck_unlock("intro")
  deck_unlock("endings/money")
  deck_unlock("endings/health")

  current_card = deck_get_nextcard_by_nick("game_start")
end

function game_update(dt)
  -- body...
end

function game_draw()
  love.graphics.clear(0.094, 0.078, 0.145)

  card_draw()


  local i = 0
  for k,v in pairs(game_states) do
    if game_states_names[k] ~= nil then
      love.graphics.print(game_states_names[k][LANG] .. " : " .. tostring(v), 16, 16 + 16 * i)
      i = i + 1
    end
  end

end

-- UI --------------------------------------------------------------------------

function button(x, y, w, h, text, alpha)
  alpha = alpha or 1

  love.graphics.setLineWidth(2)
  if check_collision(x, y, w, h, love.mouse.getX(), love.mouse.getY(), 1, 1) then
    love.graphics.setColor(0.996, 0.682, 0.204, alpha)
    text = "> " .. text .. " <"
  else
    love.graphics.setColor(1, 1, 1, alpha)
  end

  local text = love.graphics.newText( assets_font_romulus, text )
  love.graphics.draw(text, x + w / 2 - text:getWidth() / 2,
                           y + h / 2 - text:getHeight() / 2 + 2)

   love.graphics.setColor(1, 1, 1)
   return check_collision(x, y, w, h, love.mouse.getX(), love.mouse.getY(), 1, 1) and mouse_click()
end

-- Utils -----------------------------------------------------------------------

function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function check_collision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function mouse_update()
  old_mouse_lclick = mouse_lclick
  mouse_lclick = love.mouse.isDown(1)
end

function mouse_click()
  return mouse_lclick and not old_mouse_lclick
end
