json = require('libs.json')

function love.load(arg)
  -- Load decks
  game_load()
end

function love.update(dt)
  -- body...
end

function love.draw()
    love.graphics.print('Hello World!', 400, 300)
end

-- Deck Managments -------------------------------------------------------------

function deck_unlock(name)
  if deck[name] == nil then
    local deck_json = love.filesystem.read("decks/" .. name .. ".json")
    local deck_data = json.decode(deck_json)

    decks[name] = deck_data
  end
end

function deck_card()

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

end
