json = require('libs.json')

function love.load(arg)
  -- Load decks
  game_load()

  love.graphics.setDefaultFilter("nearest", "nearest", 0)

  assets_font_alagard = love.graphics.newFont("assets/alagard.ttf", 26)
  assets_font_romulus = love.graphics.newFont("assets/romulus.ttf", 26)
end

function love.update(dt)
  game_update(dt)
end

function love.draw()
    game_draw()
end

-- Deck Managments -------------------------------------------------------------

function deck_unlock(name)
  if decks[name] == nil then
    local deck_json = love.filesystem.read("decks/" .. name .. ".json")
    local deck_data = json.decode(deck_json)

    decks[name] = deck_data
  end
end

function card_valid_equal(card)
  local requirements = card.requirement.equal
  local r = true

  for k,v in pairs(requirements) do
    r = r and game_states[k] == v
  end

  return r
end

function card_valid_morethan(card)
  local requirements = card.requirement.morethan
  local r = true

  for k,v in pairs(requirements) do
    r = r and game_states[k] > v
  end

  return r
end

function card_valid_lessthan(card)
  local requirements = card.requirement.lessthan
  local r = true

  for k,v in pairs(requirements) do
    r = r and game_states[k] < v
  end

  return r
end

function card_valid_morethanorequal(card)
  local requirements = card.requirement.morethanorequal
  local r = true

  for k,v in pairs(requirements) do
    r = r and game_states[k] >= v
  end

  return r
end

function card_valid_lessthanorequal(card)
  local requirements = card.requirement.lessthanorequal
  local r = true

  for k,v in pairs(requirements) do
    r = r and game_states[k] <= v
  end

  return r
end

function deck_get_nextcard()

end

function deck_get_nextcard_by_nick()

end

-- GAME ------------------------------------------------------------------------

function game_load()
  decks = {}
  game_states = {}

  deck_unlock("exemple")
end

function game_update(dt)
  -- body...
end

function game_draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.clear(0.094, 0.078, 0.145)
  love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 128, love.graphics.getHeight() / 2 - 256, 256, 256)

  love.graphics.setLineWidth(2)

  for i=1,5 do
    button(love.graphics.getWidth() / 2 - 480/2, love.graphics.getHeight() / 2 + 48 * i, 480, 32, "Lorem ipsum")
  end

end

-- UI --------------------------------------------------------------------------

function button(x, y, w, h, text)
  if check_collision(x, y, w, h, love.mouse.getX(), love.mouse.getY(), 1, 1) then
    love.graphics.setColor(0.996, 0.682, 0.012, 0.75)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0.996, 0.906, 0.38, 0.75)
    love.graphics.rectangle("line", x, y, w, h)
  else
    love.graphics.setColor(0.227, 0.267, 0.4)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0.353, 0.412, 0.533)
    love.graphics.rectangle("line", x, y, w, h)
  end

  love.graphics.setColor(1, 1, 1)
  local text = love.graphics.newText( assets_font_romulus, text )
  love.graphics.draw(text, x + w / 2 - text:getWidth() / 2,
                           y + h / 2 - text:getHeight() / 2 + 2)

   return check_collision(x, y, w, h, love.mouse.getX(), love.mouse.getY(), 1, 1) and love.mouse.isDown(1)
end

-- Utils -----------------------------------------------------------------------

function check_collision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
