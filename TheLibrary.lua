--[[
------------------------------Basic Table of Contents------------------------------

--]]

function maximum(table)
    local highestnumber = nil
    for i, v in pairs(table) do
        local number = tonumber(v)
        if highestnumber == nil or number > highestnumber then
            highestnumber = number
        end
    end
    return highestnumber
end

loc_colour()
G.ARGS.LOC_COLOURS.twow_blacker = HEX('1f2729')

--Creates an atlas for cards to use
SMODS.Atlas {
	key = "twow_jokers",
	path = "Jokers.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "twow_extras",
	path = "Enhancers.png",
	px = 71,
	py = 95
}


SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}

SMODS.current_mod.optional_features = {
    retrigger_joker = true,
    quantum_enhancements = true
}


-- Black Seal
SMODS.Seal {
    key = 'black',
    atlas = 'twow_extras',
    loc_txt = {
        label = 'Black Seal',
        name = 'Black Seal',
        text={
            "Destroys this card",
            "when {C:attention}discarded",
        },
    },
    pos = { x = 0, y = 0 },
    badge_colour = G.C.BLACK,
    calculate = function(self, card, context)
        if context.discard and context.other_card == card then
            return { remove = true }
        end
    end,
    in_pool = function() return false end
}




-- ZETTEX
SMODS.Joker {
    key = "zettex",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 2, y = 0 },

    loc_txt = {
        name="Zettex",
        text={
            "{C:green}#1# in #2#{} odds to gain",
            "{C:money}$#3#{} for any scoring",
            "{C:attention}2{}, {C:attention}4{}, {C:attention}6{}, {C:attention}Jack{}, or {C:attention}King{}"
        },
    },
        config = { extra = { odds_top = 1, odds_bottom = 6, dollars = 4 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.odds_top, card.ability.extra.odds_bottom, 'twow_zettex')
        if numerator == 1 then
            numerator = numerator*6
            denominator = denominator*6 
        elseif numerator == 8 then
            numerator = numerator*5
            denominator = numerator*5
        end
        return { vars = { numerator, denominator, card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and

            (context.other_card.base.id == 2 or context.other_card.base.id == 4 or context.other_card.base.id == 6
            or context.other_card.base.id == 11 or context.other_card.base.id == 13) and

            SMODS.pseudorandom_probability(card, 'twow_zettex', card.ability.extra.odds_top, card.ability.extra.odds_bottom) then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
                func = function() -- This is for timing purposes, this goes after the dollar modification
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end
}



-- AARON
SMODS.Joker {
    key = "aaronvx",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 4, y = 0 },

    loc_txt = {
        name="aaronvx",
        text={
            "This Joker gains {C:chips}+#2#{} Chips",
            "if played hand contains a",
            "scoring {C:attention}5{} or {C:attention}10{}",
            "{C:inactive}(Currently {C:chips}#1#{C:inactive} Chips)",

        },
    },
    config = { extra = { chips = 0, chip_mod = 5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local contains_card = false
            for _, card in pairs(context.scoring_hand) do
               if card:get_id() == 5 or card:get_id() == 10 then contains_card = true end
            end
            if contains_card then
                -- See note about SMODS Scaling Manipulation on the wiki
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
                }
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}




-- NORMALBEN
SMODS.Joker {
    key = "normalben",
    blueprint_compat = true,
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    unlocked = true, discovered = true,

    pos = { x = 6, y = 0 },

    loc_txt = {
        name="normalben",
        text={
            "{C:chips}+#1#{} Chips for each card",
            "held in hand of your",
            "deck's most common rank",
            "{C:inactive}(Currently {C:attention}#2#{C:inactive})",
        },
    },
    config = { extra = { chips = 60} },
    loc_vars = function(self, info_queue, card)

        local rank_counts = {}
        local ranks_lookup = {}
        for _, playing_card in pairs(G.playing_cards or {}) do

            if not SMODS.has_no_rank(playing_card) then
                ranks_lookup[playing_card.base.id] = playing_card.base.value
                local current_rank = playing_card.base.id
                if rank_counts[current_rank] then rank_counts[current_rank] = rank_counts[current_rank] + 1
                else rank_counts[current_rank] = 1 end
            end
        end

        local highest_count = maximum(rank_counts)
        local highest_ranks = {}
        for rank, count in pairs(rank_counts) do
            if count == highest_count then
                highest_ranks[#highest_ranks+1] = rank
            end
        end

        table.sort(highest_ranks or {14})
        local current_id = highest_ranks[((G.GAME.current_round.twow_normalben_selection or 0) % #highest_ranks) + 1]
        card.ability.extra.rank = {rank = ranks_lookup[current_id], id = current_id}

        return { vars = { card.ability.extra.chips, localize((card.ability.extra.rank.rank) or 'Ace', 'ranks')} }
    end,

    calculate = function(self, card, context)

        if context.before or context.change_rank then
            local rank_counts = {}
            local ranks_lookup = {}
            for _, playing_card in pairs(G.playing_cards or {}) do

                if not SMODS.has_no_rank(playing_card) then
                    ranks_lookup[playing_card.base.id] = playing_card.base.value
                    local current_rank = playing_card.base.id
                    if rank_counts[current_rank] then rank_counts[current_rank] = rank_counts[current_rank] + 1
                    else rank_counts[current_rank] = 1 end
                end
            end

            local highest_count = maximum(rank_counts)
            local highest_ranks = {}
            for rank, count in pairs(rank_counts) do
                if count == highest_count then
                    highest_ranks[#highest_ranks+1] = rank
                end
            end

            table.sort(highest_ranks)
            local current_id = highest_ranks[(G.GAME.current_round.twow_normalben_selection % #highest_ranks) + 1]
            card.ability.extra.rank = {rank = ranks_lookup[current_id], id = current_id}

        end

        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            --print(card.ability.extra.rank)
        end

        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:get_id() == card.ability.extra.rank.id then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end,
}


-- ILUCUTHEN
SMODS.Joker {
    key = "ilucuthen",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 0 },

    loc_txt = {
        name="Ilucuthen",
        text={
            "{X:mult,C:white} X#1# {} Mult",
            "Retrigger all copies",
            "of {C:attention}Ilucuthen{}",
        },
    },
    config = { extra = { xmult = 1.25, queue_elements = 0 } },
    loc_vars = function(self, info_queue, card)
    
        if not card.fake_card then 
            for i = 1, 10, 1 do
                info_queue[#info_queue + 1] = G.P_CENTERS.j_twow_ilucuthen
            end
        end

        return { vars = { card.ability.extra.xmult} }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
                return {
                    xmult = card.ability.extra.xmult
                }
        end

        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.key == 'j_twow_ilucuthen' then
            return {repetitions = 1}
        end
    end,
}


-- TWPAZ
SMODS.Joker{
    key = "twpaz",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 6,
    atlas = 'twow_jokers',

    pos = { x = 0, y = 1 },

    loc_txt = {
        name="twpaz.",
        text={
            "Earn {C:money}$#1#{} for each",
            "discarded {C:attention}Diamond{}"
        },
    },

    config = { extra = { dollars = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and
            context.other_card:is_suit("Diamonds") then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
                func = function() -- This is for timing purposes, it runs after the dollar manipulation
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end
}


-- NEONIC
SMODS.Joker {
    key = "neonic",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 5, y = 1 },

    loc_txt = {
        name="Neonic",
        text={
            "{C:chips}+#1#{} Chips or {C:mult}+#2#{} Mult,",
            "whichever increases",
            "your score more",
        },
    },
    config = { extra = { chips = 80, mult = 12 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if (hand_chips+card.ability.extra.chips)*mult > hand_chips*(card.ability.extra.mult+mult) then
                return {
                    chips = card.ability.extra.chips
                }
            else
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end,
}


-- ITEOTI
SMODS.Joker {
    key = "iteoti",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 1 },

    loc_txt = {
        name="iTeoti",
        text={
            "This Joker gains {C:mult}+#2#{} Mult",
            "if a card becomes", 
            "a {C:diamonds}Diamond{} card", 
            "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)",
        },
    },
    config = { extra = { mult = 0, mult_mod = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    calculate = function(self, card, context)
        if context.change_suit and context.new_suit == "Diamonds" and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
            }
        end

        if context.joker_main then
            return {mult = card.ability.extra.mult}            
        end
    end,
}


-- WOOOOWOOOO
SMODS.Joker {
    key = "woooowoooo",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 9, y = 1 },

    loc_txt = {
        name="woooowoooo",
        text={
            "{C:blue}+#1#{} Chips if played",
            "hand is a {C:attention}#2#{}",
        },
    },
    config = { extra = { chips = 80, type = 'High Card' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, localize(card.ability.extra.type, 'poker_hands')} }
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == "High Card" then
            return { chips = card.ability.extra.chips }
        end
    end,
}

-- ANARTICHOKE
SMODS.Joker {
    key = "anartichoke",
    blueprint_compat = true, eternal_compat = false,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 0, y = 2 },

    loc_txt = {
        name="AnArtichoke_",
        text={
            "Gain {C:money}$#1#{} at end",
            "of round, {C:mult}-$#2#{}",
            "per round played",
        },
    },
    config = { extra = { dollars = 6, dollars_mod = 1, initialized = true } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollars_mod } }
    end,

	calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
			if card.ability.extra.initialized then
				card.ability.extra.initialized = false
			elseif card.ability.extra.dollars - card.ability.extra.dollars_mod <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = "Sliced!",
                    colour = G.C.GREEN
                }
			else
				card.ability.extra.dollars = card.ability.extra.dollars - card.ability.extra.dollars_mod
				return {
					message = "-$"..card.ability.extra.dollars_mod,
					colour = G.C.RED,
					card = card
				}
			end
		end
	end,

    calc_dollar_bonus = function(self, card) return card.ability.extra.dollars end
    
}


-- AVOCADO
SMODS.Joker {
    key = "avocado",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 3, y = 2 },

    loc_txt = {
        name="Avocado",
        text={
            "At end of round",
            "create a {C:tarot}Tarot{} card",
            "{C:green}#2# in #3#{} chance this",
            "Joker is destroyed",
            "{C:inactive}(Must have room)",
        },
    },

    config = { extra = { odds = 4 } },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'twow_avocado')
        return { vars = { card.ability.extra.mult, numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then

            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    SMODS.add_card({ set = 'Tarot' })
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))

            if not context.blueprint and SMODS.pseudorandom_probability(card, 'twow_avocado', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.GREEN
                }
            else
                return {
                    message = localize('k_safe_ex'),
                    colour = G.C.GREEN
                }
            end
        end
    end,
}

-- ANNE
SMODS.Joker {
    key = "anne",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 4, y = 2 },

    loc_txt = {
        name="Anne",
        text={
			"Played {C:attention}Queens{} give",
            "{C:money}$#1#{}, {C:chips}+#2#{} Chips, or",
            "{C:mult}+#3#{} Mult when scored"
        },
    },

    config = { extra = { dollars = 1, chips = 50, mult = 7 } },

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars, card.ability.extra.chips, card.ability.extra.mult } }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if not SMODS.has_no_rank(context.other_card) and context.other_card:get_id() == 12 then
                local anne_choice = pseudorandom('twow_anne', 1, 3)
                if anne_choice == 1 then
                    return {dollars = card.ability.extra.dollars} 
                elseif anne_choice == 2 then
                    return {chips = card.ability.extra.chips} 
                elseif anne_choice == 3 then
                    return {mult = card.ability.extra.mult} 
                end
			end
		end
	end
}


-- SICTOABU
SMODS.Joker {
    key = "sictoabu",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 7, y = 2 },

    loc_txt = {
        name="sictoabu",
        text={
            "{C:chips}+#1#{} Chips every",
            "{C:attention}#2#{} hands played",
            "{C:inactive}#3#",
        },
    },

    config = { extra = { chips = 150, every = 2, hands_remaining = 2 } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chips,
                card.ability.extra.every + 1,
                localize { type = 'variable', key = (card.ability.extra.hands_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { card.ability.extra.hands_remaining } }
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.hands_remaining = (card.ability.extra.every - 1 - (G.GAME.hands_played - card.ability.hands_played_at_create)) %
                (card.ability.extra.every + 1)
            if not context.blueprint then
                if card.ability.extra.hands_remaining == 0 then
                    local eval = function(card) return card.ability.extra.hands_remaining == 0 and not G.RESET_JIGGLES end
                    juice_card_until(card, eval, true)
                end
            end
            if card.ability.extra.hands_remaining == card.ability.extra.every then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end
}

-- DARK
SMODS.Joker {
    key = "dark",
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 1, y = 0 },

    loc_txt = {
        name="Dark",
        text={
            "Sell this card to",
            "create a {C:attention}Rare Tag{}",
            "and {C:attention}Polychrome Tag{}",
        },
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'tag_rare', set = 'Tag' }
        info_queue[#info_queue + 1] = { key = 'tag_polychrome', set = 'Tag' }
    end,
    calculate = function(self, card, context)
        if context.selling_self then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_rare'))
                    add_tag(Tag('tag_polychrome'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end)
            }))
            return nil, true -- This is for Joker retrigger purposes
        end
    end,
}

-- LEIZ
SMODS.Joker {
    key = "leiz",
    blueprint_compat = false,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',
    pos = { x = 3, y = 0 },

    loc_txt = {
        name="LeiZ",
        text={
            "{C:attention}Lucky Cards{} give",
            "{X:mult,C:white} X#1# {} Mult instead",
            "of {C:mult}+20{} Mult",
        },
    },
    config = { extra = { xmult = 3 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return { vars = { card.ability.extra.xmult } }
    end,

    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_lucky') then
                return true
            end
        end
        return false
    end,
}

SMODS.Enhancement:take_ownership('lucky', {
    pos = { x = 4, y = 1 },

    config = { extra = { mult = 20, dollars = 20, mult_odds = 5, dollars_odds = 15 } },
    loc_vars = function(self, info_queue, card)
        local mult_numerator, mult_denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.mult_odds,
            'lucky_mult')
        local dollars_numerator, dollars_denominator = SMODS.get_probability_vars(card, 1,
            card.ability.extra.dollars_odds, 'lucky_money')
        return { vars = { mult_numerator, card.ability.extra.mult, mult_denominator, card.ability.extra.dollars, dollars_denominator, dollars_numerator } }
    end,
    
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local ret = {}
            if SMODS.pseudorandom_probability(card, 'lucky_mult', 1, card.ability.extra.mult_odds) then
                card.lucky_trigger = true
                local leiz_joker = SMODS.find_card('j_twow_leiz')
                if next(SMODS.find_card('j_twow_leiz')) then
                    ret.xmult = leiz_joker[1].ability.extra.xmult
                else 
                    ret.mult = card.ability.extra.mult
                end
            end
            if SMODS.pseudorandom_probability(card, 'lucky_money', 1, card.ability.extra.dollars_odds) then
                card.lucky_trigger = true
                ret.dollars = card.ability.extra.dollars
            end
            return ret
        end
    end,

})

-- PURPLEGAZE
SMODS.Joker {
    key = "purplegaze",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 5, y = 0 },

    config = { extra = { do_trigger = false } },

    loc_txt = {
        name="Purplegaze",
        text={
            "Retrigger all played cards",
            "if poker hand contains a",
            "{C:diamonds}Diamond{} card, {C:clubs}Club{} card,",
            "{C:hearts}Heart{} card, and {C:spades}Spade{} card",
        },
    },

    calculate = function(self, card, context)
        if context.before then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #context.scoring_hand do
                if not SMODS.has_any_suit(context.scoring_hand[i]) then
                    for suit_name, _ in pairs(suits) do
                        if context.scoring_hand[i]:is_suit(suit_name) and suits[suit_name] == 0 then suits[suit_name] = suits[suit_name] + 1 break
                        end
                    end
                end
            end
            for i = 1, #context.scoring_hand do
                if SMODS.has_any_suit(context.scoring_hand[i]) then
                    for suit_name, _ in pairs(suits) do
                        if context.scoring_hand[i]:is_suit(suit_name) and suits[suit_name] == 0 then suits[suit_name] = suits[suit_name] + 1 break
                        end
                    end
                end
            end
            card.ability.extra.do_trigger = suits["Hearts"] > 0 and suits["Diamonds"] > 0 and suits["Spades"] > 0 and suits["Clubs"] > 0
        end

        if context.cardarea == G.play and context.repetition and card.ability.extra.do_trigger then
            return {repetitions = 1}
        end
    end,
}

-- VERIGOLD
SMODS.Joker{
    key = "verigold",
    blueprint_compat = false,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',

    pos = { x = 7, y = 0 },

    loc_txt = {
        name="Verigold",
        text={
            "{C:attention}Gold Cards{} and",
            "{C:attention}Steel Cards{} both",
            "count as one other",
        },
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return
    end,

    calculate = function(self, card, context)
        if context.check_enhancement then
            if context.other_card.config.center.key == "m_gold" then
                return {m_steel = true}
            end
            if context.other_card.config.center.key == "m_steel" then
                return {m_gold = true}
            end
        end
    end
}

-- ADAMANTI
SMODS.Joker{
    key = "adamanti",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',

    pos = { x = 9, y = 0 },

    loc_txt = {
        name="Adamanti",
        text={
            "Retrigger all played",
            "{C:attention}Aces #1#{} times",
        },
    },

    config = { extra = { repetitions = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions }}
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:get_id() == 14 and not SMODS.has_no_rank(context.other_card) then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}

-- COOLGAMER707
SMODS.Joker{
    key = "coolgamer707",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',

    pos = { x = 1, y = 1 },

    loc_txt = {
        name="coolgamer707",
        text={
                    "Every played {C:attention}7{}",
                    "permanently gains",
                    "{C:mult}+#1#{} Mult when scored",
        },
    },

    config = { extra = { mult = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 7 then
            context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) +
                card.ability.extra.mult
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT
            }
        end
    end
}



-- SGT SNIVY
SMODS.Joker{
    key = "snivy",
    blueprint_compat = false,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',

    pos = { x = 3, y = 1 },

    loc_txt = {
        name="SergeantSnivy",
        text={
            "{C:attention}+#1#{} hand size in",
            "{C:attention}final hand{} of round",
        },
    },

    config = { extra = { h_size = 2, is_active = false } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size } }
    end,

    
    calculate = function(self, card, context)
        if G.GAME.blind and not card.ability.extra.is_active and G.GAME.current_round.hands_left == 1 then
            G.hand:change_size(card.ability.extra.h_size)
            card.ability.extra.is_active = true
        end
        if context.end_of_round and context.main_eval and card.ability.extra.is_active then
            G.hand:change_size(-card.ability.extra.h_size)
            card.ability.extra.is_active = false
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        if G.GAME.blind and G.GAME.current_round.hands_left == 1 and not card.ability.extra.is_active then
            G.hand:change_size(card.ability.extra.h_size)
            card.ability.extra.is_active = true
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.is_active then
            G.hand:change_size(-card.ability.extra.h_size)
            card.ability.extra.is_active = false
        end
    end,

}


-- DELL
SMODS.Joker{
    key = "mrdell",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',

    pos = { x = 4, y = 1 },

    loc_txt = {
        name="Mr. Dell",
        text={
            "This Joker gains {X:mult,C:white} X#2# {} Mult",
            "when played card with",
            "{C:clubs}Club{} suit is scored",
            "{C:inactive}(Currently {X:mult,C:white} X#1# {} Mult)",

        },
    },

    config = { extra = { xmult = 1, xmult_mod = 0.03 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Clubs') and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
        end
        if context.joker_main then return {xmult = card.ability.extra.xmult} end
    end
}


-- KOOPA
SMODS.Joker {
    key = "koopa",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 7, y = 1 },

    loc_txt = {
        name="Koopa",
        text={
            "This Joker gives",
            "{C:mult}+#1#{} Mult for every",
            "{C:attention}4{}, {C:attention}7{}, and {C:attention}2{} in deck",
            "{C:inactive}(Currently {C:mult}+#2#{}{C:inactive} Mult)",

        },
    },
    config = { extra = { mult = 2 } },
    loc_vars = function(self, info_queue, card)
        local card_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 4 or playing_card:get_id() == 7 or playing_card:get_id() == 2 then card_tally = card_tally + 1 end
            end
        end
        return { vars = { card.ability.extra.mult, card.ability.extra.mult * card_tally } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local card_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if playing_card:get_id() == 4 or playing_card:get_id() == 7 or playing_card:get_id() == 2 then card_tally = card_tally + 1 end
                end
            end
            return { mult = card.ability.extra.mult * card_tally }
        end
    end,
}


-- MISCH13VOUS
SMODS.Joker {
    key = "misch13vous",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 1 },

    loc_txt = {
        name="misch13vous",
        text={
            "{X:mult,C:white} X#1# {} Mult if poker",
            "hand contains a",
            "scoring {C:attention}3{}, {C:attention}Ace{}, and {C:attention}4{}"
        },
    },
    config = { extra = { xmult = 3.14 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            has_3 = false has_ace = false has_4 = false
            for i = 1, #context.scoring_hand do
                if not SMODS.has_no_rank(context.scoring_hand[i]) then
                    if context.scoring_hand[i]:get_id() == 3 then has_3 = true end
                    if context.scoring_hand[i]:get_id() == 14 then has_ace = true end
                    if context.scoring_hand[i]:get_id() == 4 then has_4 = true end
                end
            end
            if has_3 and has_ace and has_4 then return { xmult = card.ability.extra.xmult } end
        end
    end,
}

-- YUAKIM
SMODS.Joker {
    key = "yuakim",
    blueprint_compat = false,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',
    pos = { x = 1, y = 2 },

    loc_txt = {
        name="Yuakim",
        text={
            "{C:attention}#1#{} counts",
            "as {C:attention}#2#{}"
        },
    },

	loc_vars = function(self, info_queue, card)
		return { vars = { G.localization.misc.poker_hands['Four of a Kind'], G.localization.misc.poker_hands['Five of a Kind'] } }
	end,

	calculate = function(self, card, context)
		if context.evaluate_poker_hand and context.scoring_name == "Four of a Kind" and not context.blueprint then
			context.poker_hands["Five of a Kind"] = context.poker_hands["Four of a Kind"]
            if next(context.poker_hands["Flush"]) then return {replace_scoring_name = "Flush Five"}
			else return { replace_scoring_name = "Five of a Kind" } end
		end
	end,
 
    in_pool = function()
        local rank_counts = {}
        for _, playing_card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_rank(playing_card) then
                local current_rank = playing_card.base.id
                if rank_counts[current_rank] then rank_counts[current_rank] = rank_counts[current_rank] + 1
                else rank_counts[current_rank] = 1 end
            end
        end
        return maximum(rank_counts) >= 5
    end
}

-- CTLASERDISC
SMODS.Joker {
    key = "ctlaserdisc",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',
    pos = { x = 5, y = 2 },

    loc_txt = {
        name="ctlaserdisc",
        text={
            "Each played {C:attention}Jack{},",
            "{C:attention}10{}, or {C:attention}9{} gives",
            "{C:mult}+#1#{} Mult when scored",
        },
    },

    config = { extra = { mult = 10 } },

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 11 or
                context.other_card:get_id() == 10 or
                context.other_card:get_id() == 9 then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}

-- AZURITE
SMODS.Joker {
    key = "azurite",
    blueprint_compat = false,
    unlocked = true, discovered = true,
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 2 },

    config = { extra = {cards = 0}, immutable = { requirement = 8 } },

    loc_txt = {
        name="Azurite",
        text={
            "Create a {C:spectral}Spectral{} card",
            "every #1# {C:attention}playing cards{}",
            "added to your deck",
            "{C:inactive}(#2# remaining)",
        },
    },

    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.immutable.requirement, 8 - card.ability.extra.cards } }
	end,

    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            local spectral_made = false
            card.ability.extra.cards = card.ability.extra.cards + #context.cards 

            while card.ability.extra.cards >= card.ability.immutable.requirement do
                card.ability.extra.cards = card.ability.extra.cards - card.ability.immutable.requirement
                spectral_made = true
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = 'Spectral',
                            key_append = 'twow_azurite' 
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                    }))
                end
            end
            if spectral_made then
                return {
                    message = localize('k_plus_spectral'),
                    colour = G.C.SECONDARY_SET.Spectral
                }
            else return { message = ('+'..#context.cards ) } end

        end
    end,
}

-- CASSIEPEPSI
SMODS.Joker {
	key = 'cassiepepsi',
	loc_txt = {
		name = 'cassiepepsi',
		text = {
			"Creates a copy of",
            "{C:attention}Justice{} when",
            "{C:attention}Glass Card{} breaks"
		}
	},
	config = {},
    blueprint_compat = false,
    unlocked = true, discovered = true,
	loc_vars = function(self, info_queue, card)
		--info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        info_queue[#info_queue + 1] = G.P_CENTERS.c_justice
	end,

	rarity = 3,
	atlas = 'twow_jokers',
	pos = { x = 0, y = 0 },
	cost = 8,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local glass_cards = 0
            for _, removed_card in ipairs(context.removed) do
                if removed_card.shattered then glass_cards = glass_cards + 1 end
            end
            glass_cards = math.min(glass_cards, G.consumeables.config.card_limit - #G.consumeables.cards)
            if glass_cards > 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        while glass_cards > 0 do
                            SMODS.add_card({ key = 'c_justice' })
                            glass_cards = glass_cards - 1
                            end
                        return true
                    end
                }))
                return nil, true -- This is for Joker retrigger purposes
            end
        end
    end,
    in_pool = function(self, args) --equivalent to `enhancement_gate = 'm_glass'`
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_glass') then
                return true
            end
        end
        return false
    end,
}


-- TROJAN
SMODS.Joker{
    key = "trojan",
    blueprint_compat = false,
    unlocked = true, discovered = true,
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',

    pos = { x = 2, y = 1 },

    loc_txt = {
        name="Trojan",
        text={
            "If played hand is",
            "{C:attention}High Card{}, add",
            "{C:twow_blacker}Black Seal{} to all",
            "scoring cards"
        },
    },

    config = { extra = { seal = 'twow_black' } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and context.scoring_name == "High Card" then
            for _, scored_card in ipairs(context.scoring_hand) do
                if not scored_card.debuff then
                    scored_card:set_seal(card.ability.extra.seal, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
            end
                return {
                message = "Doomed!",
                colour = G.C.BLACK
            }
        end
    end
}


-- WHOLE
SMODS.Joker {
    key = "whole",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 2, y = 2 },

    loc_txt = {
        name="Whole",
        text={
			"Played {C:attention}Stone Cards{} give",
			"{X:mult,C:white} X#1# {} Mult when scored"
        },
    },

    config = { extra = { xmult = 1.5 } },

	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_stone 
		return { vars = { card.ability.extra.xmult } }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if SMODS.has_enhancement(context.other_card, 'm_stone') then
				return {
					xmult = card.ability.extra.xmult
				}
			end
		end
	end
}

-- IRONIC
SMODS.Joker {
    key = "ironic",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 2 },

    loc_txt = {
        name="Ironic",
        text={
            "This Joker duplicates",
            "{C:attention}Tags{} made when {C:attention}Blind{}",
            "is skipped"
        },
    },

    config = { extra = { mult = 9 } },

	loc_vars = function(self, info_queue, card)
	end,

    calculate = function(self, card, context)
        if context.skip_blind then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    if G.GAME.tags[#G.GAME.tags].ability and G.GAME.tags[#G.GAME.tags].ability.orbital_hand then
                        G.orbital_hand = G.GAME.tags[#G.GAME.tags].ability.orbital_hand
                    end
                    add_tag(Tag(G.GAME.tags[#G.GAME.tags].key))
                    G.orbital_hand = nil
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
        end
    end
}





-- CARYKH
SMODS.Joker {
    key = "carykh",
    blueprint_compat = true,
    unlocked = true, discovered = true,
    rarity = 4,
    cost = 20,
    atlas = 'twow_jokers',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },

    loc_txt = {
        name="carykh",
        text={
            "Doubles the values",
            "in all {C:attention}TWOW Jokers{}"
        },
    },

    calculate = function(self, card, context)
        if context.card_added then
            if context.card.ability.extra and (context.card.config.center.mod or {}).id == 'TheLibrary' and context.card.config.center.key ~= "j_twow_carykh" then
                for k, v in pairs(context.card.ability.extra) do
                    if type(v) == 'number' then
                        if (k == 'xmult') then context.card.ability.extra[k] = 2*v-1
                        else context.card.ability.extra[k] = 2*v end
                    end
                end
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        for _, curr_joker in pairs(G.jokers.cards) do
            if curr_joker.ability.extra and curr_joker and (curr_joker.config.center.mod or {}).id == 'TheLibrary' and curr_joker.config.center.key ~= "j_twow_carykh" then
                for k, v in pairs(curr_joker.ability.extra) do
                    if type(v) == 'number' then
                        if (k == 'xmult') then curr_joker.ability.extra[k] = 2*v-1
                        else curr_joker.ability.extra[k] = 2*v end
                    end
                end
            end
        end

    end,

    remove_from_deck = function(self, card, from_debuff)
        for _, curr_joker in pairs(G.jokers.cards) do
            if curr_joker.ability.extra and curr_joker and (curr_joker.config.center.mod or {}).id == 'TheLibrary' and curr_joker.config.center.key ~= "j_twow_carykh" then
                for k, v in pairs(curr_joker.ability.extra) do
                    if type(v) == 'number' then
                        if (k == 'xmult') then curr_joker.ability.extra[k] = (v+1)/2
                        else curr_joker.ability.extra[k] = v/2 end
                    end
                end
            end
        end
    end,

}


local function reset_twow_normalben()
    G.GAME.current_round.twow_normalben_selection = pseudorandom('twow_normalben', 1, 6227020800)
end

function SMODS.current_mod.reset_game_globals(run_start)
    reset_twow_normalben()
end

----------------------------------------------
------------MOD CODE END----------------------