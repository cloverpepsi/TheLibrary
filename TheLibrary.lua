-- 
-- v3.1.0
-- ADDITIONS
--   Jokers
--     Added Mysterious Alt Figure, CASTORCORE, Just A Toad, and canicao
--   Other
--     Added Index Tag (Free Jumbo Catalog Pack)
--
-- CHANGES
--   Zettex gives $6 per trigger instead of $4
--   Snivy gives +5 hand size instead of +2
--   MayUnderFlowers now also gives +5 Mult when Wild card scored
--   iTeoti now gives +1 Mult per Diamond in deck
--   Random's odds increased to 1 in 8
--   Ironic now acts on both Small and Big Blind
--   Sable renamed to Whole and gives X2 mult 
--   Speediness Potion can now be purchased without empty joker slots
--   DRP is now $8, AnArtichoke_ is now $6
--   cassiepepsi and LeiZ can now always appear
--   Blue bookmark can't be added at random if joker is eternal
--   Green bookmark applies to all joker abilities.
--   Minor texture changes


to_big = to_big or function(x) return x end

loc_colour()
G.ARGS.LOC_COLOURS.twow_main = HEX('166125')
G.ARGS.LOC_COLOURS.twow_index = HEX('666BC1')

Library = {}

Library.is_card = function(card, key)

    if (card.config.center.key == "j_twow_mysterious_alt_figure" and card.ability.stolen == key) then return true end
    return card.config.center.key == key

end

Library.find_card = function(key, count_debuffed)
    local results = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _, v in pairs(area.cards) do
                if v and type(v) == 'table' and (count_debuffed or not v.debuff) then
                    if Library.is_card(v, key) then table.insert(results, v) end
                end
            end
        end
    end
    return results
end

--Creates an atlas for cards to use
SMODS.Atlas {
	key = "twow_jokers",
	path = "Jokers.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "twow_indexes",
	path = "Indexes.png",
	px = 95,
	py = 59
}

SMODS.Atlas {
	key = "twow_boosters",
	path = "Boosters.png",
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = "twow_tags",
    path = "Tags.png",
    px = 34,
    py = 34
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

-- ZETTEX
SMODS.Joker {
    key = "zettex",
    blueprint_compat = true,
    unlocked = true, 
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
        config = { extra = { odds_top = 1, odds_bottom = 6, dollars = 6 } },
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
    unlocked = true, 
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
    unlocked = true, 

    pos = { x = 6, y = 0 },

    loc_txt = {
        name="normalben",
        text={
            "This Joker gains {C:chips}+#2#{} Chips",
            "if played hand was not",
            "played this Ante",
            "{C:inactive}(Currently {C:chips}#1#{C:inactive} Chips)",
        },
    },
    config = { extra = { chips = 0, chip_mod = 7, played_hands = {}} },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
    end,

    calculate = function(self, card, context)

        if context.round_eval and G.GAME.last_blind and G.GAME.last_blind.boss then
            card.ability.extra.played_hands = {}
        end

        if context.before and not context.blueprint then
            if not card.ability.extra.played_hands[context.scoring_name] then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                card.ability.extra.played_hands[context.scoring_name] = true
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


-- ILUCUTHEN
SMODS.Joker {
    key = "ilucuthen",
    blueprint_compat = true,
    unlocked = true, 
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

        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config and Library.is_card(context.other_card, "j_twow_ilucuthen") then
            return {repetitions = 1}
        end
    end,
}


-- TWPAZ
SMODS.Joker{
    key = "twpaz",
    blueprint_compat = true,
    unlocked = true, 
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
    unlocked = true, 
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
    unlocked = true, 
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 1 },

    loc_txt = {
        name="iTeoti",
        text={
            "This Joker gives {C:mult}+#1#{} Mult",
            "per {C:diamonds}Diamond{} in deck", 
            "{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)",
        },
    },
    config = { extra = { mult = 1 } },
    loc_vars = function(self, info_queue, card)

        local card_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:is_suit("Diamonds") then card_tally = card_tally + 1 end
            end
        end

        return { vars = { card.ability.extra.mult, card.ability.extra.mult * card_tally } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local card_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if playing_card:is_suit("Diamonds") then card_tally = card_tally + 1 end
                end
            end
            return { mult = card_tally*card.ability.extra.mult }
        end
    end,

}


-- WOOOOWOOOO
SMODS.Joker {
    key = "woooowoooo",
    blueprint_compat = true,
    unlocked = true, 
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
    config = { extra = { chips = 70, type = 'High Card' } },
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
    blueprint_compat = false, eternal_compat = false,
    unlocked = true, 
    rarity = 1,
    cost = 6,
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
    eternal_compat = false,
    unlocked = true, 
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

            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
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
            end

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
    unlocked = true, 
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
    unlocked = true, 
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
    unlocked = true, 
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
    unlocked = true, 
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
    end

    --in_pool = function(self, args)
    --    for _, playing_card in ipairs(G.playing_cards or {}) do
    --        if SMODS.has_enhancement(playing_card, 'm_lucky') then
    --            return true
    --        end
    --    end
    --    return false
    --end,
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
            card.lucky_trigger = false
            local ret = {}
            if SMODS.pseudorandom_probability(card, 'lucky_mult', 1, card.ability.extra.mult_odds) then
                card.lucky_trigger = true
                local leiz_joker = Library.find_card('j_twow_leiz')
                if next(Library.find_card('j_twow_leiz')) then
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

}, true)

-- PURPLEGAZE
SMODS.Joker {
    key = "purplegaze",
    blueprint_compat = true,
    unlocked = true, 
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
    unlocked = true, 
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',

    pos = { x = 7, y = 0 },

    loc_txt = {
        name="Verigold",
        text={
            "{C:attention}Gold Cards{} and",
            "{C:attention}Steel Cards{} both",
            "count as one another",
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
    unlocked = true, 
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
    unlocked = true, 
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
    unlocked = true, 
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

    config = { extra = { h_size = 5, is_active = false } },

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
    unlocked = true, 
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
            "{C:inactive}(Currently {X:mult,C:white} X#1# {}{C:inactive} Mult)",
        },
    },

    config = { extra = { xmult = 1, xmult_mod = 0.03 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Clubs') and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT
            }
        end
        if context.joker_main then return {xmult = card.ability.extra.xmult} end
    end
}


-- KOOPA
SMODS.Joker {
    key = "koopa",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 7, y = 1 },

    loc_txt = {
        name="Koopa",
        text={
            "This Joker gives",
            "{C:mult}+#1#{} Mult for every extra",
            "{C:attention}4{}, {C:attention}7{}, or {C:attention}2{} in deck",
            "{C:inactive}(Currently {C:mult}+#2#{}{C:inactive} Mult)",

        },
    },
    config = { extra = { mult = 6 } },
    loc_vars = function(self, info_queue, card)
        local card_tally = {nil, 0, nil, 0, nil, nil, 0}
        local total_mult = 0
        local deck_values = G.GAME.current_round.twow_koopa_values or {nil, 0, nil, 0, nil, nil, 0}
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if card_tally[playing_card:get_id()] then card_tally[playing_card:get_id()] = card_tally[playing_card:get_id()] + 1 end
            end
            total_mult = card.ability.extra.mult * (
            math.max(card_tally[4] - deck_values[4], 0) +
            math.max(card_tally[7] - deck_values[7], 0) +
            math.max(card_tally[2] - deck_values[2], 0))
        end
        
        return { vars = { card.ability.extra.mult, total_mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local card_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if playing_card:get_id() == 4 or playing_card:get_id() == 7 or playing_card:get_id() == 2 then card_tally = card_tally + 1 end
                end
            end
            return { mult = card.ability.extra.mult * math.max(card_tally - 12, 0) }
        end
    end,
}

local function get_twow_koopa_initial_ranks()
    G.GAME.current_round.twow_koopa_values = {nil, 0, nil, 0, nil, nil, 0}
    for _, playing_card in ipairs(G.playing_cards) do
        local current_rank_thing = G.GAME.current_round.twow_koopa_values[playing_card:get_id()]
        if not SMODS.has_no_rank(playing_card) and current_rank_thing then
            G.GAME.current_round.twow_koopa_values[playing_card.base.id] = current_rank_thing + 1
        end
    end
end


-- MISCH13VOUS
SMODS.Joker {
    key = "misch13vous",
    blueprint_compat = true,
    unlocked = true, 
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
    unlocked = true, 
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
		return { vars = { G.localization.misc.poker_hands['Three of a Kind'], G.localization.misc.poker_hands['Four of a Kind'] } }
	end,

	calculate = function(self, card, context)
		if context.evaluate_poker_hand and context.scoring_name == "Three of a Kind" and not context.blueprint then
			context.poker_hands["Four of a Kind"] = context.poker_hands["Three of a Kind"]
			return { replace_scoring_name = "Four of a Kind" }
		end
	end
}

-- CTLASERDISC
SMODS.Joker {
    key = "ctlaserdisc",
    blueprint_compat = true,
    unlocked = true, 
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
    unlocked = true, 
    rarity = 2,
    cost = 7,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 2 },

    config = { extra = {cards = 0}, immutable = { requirement = 4 } },

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
		return { vars = { card.ability.immutable.requirement, card.ability.immutable.requirement - card.ability.extra.cards } }
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
    blueprint_compat = true,
    unlocked = true, 
	loc_vars = function(self, info_queue, card)
		--info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        info_queue[#info_queue + 1] = G.P_CENTERS.c_justice
	end,

	rarity = 3,
	atlas = 'twow_jokers',
	pos = { x = 0, y = 0 },
	cost = 8,
    calculate = function(self, card, context)
        if context.remove_playing_cards then
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
                return nil, true
            end
        end
    end,
    --in_pool = function(self, args)
    --    for _, playing_card in ipairs(G.playing_cards or {}) do
    --        if SMODS.has_enhancement(playing_card, 'm_glass') then
    --            return true
    --        end
    --    end
    --    return false
    --end,
}


-- TROJAN
SMODS.Joker{
    key = "trojan",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',

    pos = { x = 2, y = 1 },

    loc_txt = {
        name="Trojan",
        text={
            "Destroy all scoring cards",
            "in {C:attention}first{} hand, {C:white,X:mult}X#2#{} Mult",
            "per card destroyed",
            "{C:inactive}(Currently {X:mult,C:white} X#1# {}{C:inactive} Mult)",
        },
    },

    config = { extra = { xmult = 1, xmult_mod = 0.1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,

    calculate = function(self, card, context)

        if context.destroy_card and context.cardarea == G.play and G.GAME.current_round.hands_played == 0 and not context.blueprint then
            return { remove = true }
        end

        if context.remove_playing_cards and not context.blueprint then
            if #context.removed > 0 then
                card.ability.extra.xmult = card.ability.extra.xmult + (#context.removed) * card.ability.extra.xmult_mod
                return { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } } }
            end
        end
        if context.joker_main then return {xmult = card.ability.extra.xmult} end
    end
}


-- SABLE
SMODS.Joker {
    key = "whole",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 2, y = 2 },

    loc_txt = {
        name="Sable",
        text={
			"Played {C:attention}Stone Cards{} give",
			"{X:mult,C:white} X#1# {} Mult when scored"
        },
    },

    config = { extra = { xmult = 2 } },

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
    unlocked = true, 
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 2 },

    loc_txt = {
        name="Ironic",
        text={
            "This Joker gives a",
            "Blind's {C:attention}skip tag{}",
            "when selected"
        },
    },

    config = { extra = { mult = 9 } },

	loc_vars = function(self, info_queue, card)
	end,

    calculate = function(self, card, context)
        if context.setting_blind and context.blind.key == 'bl_small' then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    local tag_to_copy = Tag(G.GAME.round_resets.blind_tags.Small)
                    add_tag(tag_to_copy)
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
        end

        if context.setting_blind and context.blind.key == 'bl_big' then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    local tag_to_copy = Tag(G.GAME.round_resets.blind_tags.Big)
                    add_tag(tag_to_copy)
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
        end
    end
}



-- FLEET
SMODS.Joker {
    key = "fleet",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 3,
    cost = 10,
    atlas = 'twow_jokers',
    pos = { x = 5, y = 4 },

    loc_txt = {
        name="Fleetcat",
        text={
            "Copies the ability",
            "of rightmost",
            "{C:attention}Uncommon Joker"
        },
    },

    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then

            local other_joker = nil
            for i = #G.jokers.cards, 1, -1 do
                if G.jokers.cards[i].config.center.rarity == 2 then
                    other_joker = G.jokers.cards[i]
                    break
                end
            end
            
            local joker_name = other_joker and G.localization.descriptions.Joker[other_joker.config.center.key].name or nil
            local compatible = other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat
            local textbox_color = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8)
            main_end = { {
                n = G.UIT.C,
                config = { align = "bm", minh = other_joker and 0.7 or 0.4 },
                nodes = { {
                        n = G.UIT.R,
                        config = { ref_table = card, align = "m", colour = textbox_color, r = 0.05, padding = 0.06 },
                        nodes = {  { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible and 'compatible' or 'incompatible')) .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } }, }
                    } }
            } }

            if other_joker then
                main_end[1].nodes[2] = main_end[1].nodes[1]
                main_end[1].nodes[1] = {
                    n = G.UIT.R,
                    config = { ref_table = card, align = "m", colour = textbox_color, r = 0.05, padding = 0.06 },
                    nodes = {  { n = G.UIT.T, config = { text = ' ' .. joker_name .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } }, }
                }
            end

            return { main_end = main_end }
        end
    end,

    calculate = function(self, card, context)

        local other_joker = nil
        for i = #G.jokers.cards, 1, -1 do
            if G.jokers.cards[i].config.center.rarity == 2 then
                other_joker = G.jokers.cards[i]
                break
            end
        end

        local ret = SMODS.blueprint_effect(card, other_joker, context)
        if ret then
            ret.colour = G.C.MONEY
        end
        return ret
    end
}


-- CATWORLD
SMODS.Joker {
    key = "catworld",
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 0, y = 4 },

    loc_txt = {
        name="Catworld",
        text={
            "Sell this card to",
            "add #1# {C:attention}9{}s and #2# {C:attention}3{}s",
            "to your deck",
            "{s:0.8}May have an {}{C:enhanced,s:0.8}Enhancement{},",
            "{s:0.8,C:dark_edition}Edition{}{s:0.8}, and/or a {}{C:attention,s:0.8}Seal{}",
        },
    },

    config = { extra = { amount_1 = 3, amount_2 = 9 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.amount_1, card.ability.extra.amount_2 } }
    end,

    calculate = function(self, card, context)
        if context.selling_self then

            local added_cards = {}

            for i = card.ability.extra.amount_1, 1, -1 do
                local random_seal = SMODS.poll_seal {key = "twow_catworld_seal"}
                local random_edition = SMODS.poll_edition {key = "twow_catworld_edition", no_negative = true}
                added_cards[#added_cards+1] = SMODS.add_card{set = "Playing Card", seal = random_seal, edition = random_edition, key_append = "twow_catworld", area = G.deck, rank = '9'}
            end
            for i = card.ability.extra.amount_2, 1, -1 do
                local random_seal = SMODS.poll_seal {key = "twow_catworld_seal"}
                local random_edition = SMODS.poll_edition {key = "twow_catworld_edition", no_negative = true}
                added_cards[#added_cards+1] = SMODS.add_card{set = "Playing Card", seal = random_seal, edition = random_edition, key_append = "twow_catworld", area = G.deck, rank = '3'}
            end

            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.calculate_context({ playing_card_added = true, cards = added_cards })
                    return true
                end
            }))

            return {
                message = "+"..(card.ability.extra.amount_1 + card.ability.extra.amount_2).." Cards",
                colour = G.C.PURPLE,
            }

        end
    end,
}


-- INTERSECTINGPLANES
SMODS.Joker {
    key = "intplanes",
    blueprint_compat = false,
    perishable_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 1, y = 4 },

    loc_txt = {
        name="IntersectingPlanes",
        text={
            "Earn {C:money}$#1#{} at end of round",
            "Increases by {C:money}$#2#{} if {C:attention}Blind{}",
            "won on {C:attention}first{} hand. Resets",
            "if won on {C:attention}last{} hand"
        },
    },

    config = { extra = { dollars = 1, dollars_mod = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollars_mod } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            if G.GAME.current_round.hands_played == 1 then
                card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollars_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MONEY
                }
            elseif G.GAME.current_round.hands_left == 0 then
                card.ability.extra.dollars = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED
                }
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}


-- RANDOM
SMODS.Joker {
    key = "random",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 2, y = 4 },

    loc_txt = {
        name="Random",
        text={
            "This Joker has {C:green}#1# in #2#{}",
            "odds to gain {C:mult}+#3#{} Mult",
            "any time you do anything",
            "{C:inactive}(Currently {}{C:mult}+#4#{}{C:inactive} Mult){}",
        },
    },
    config = { extra = { odds_top = 1, odds_bottom = 8, mult = 0, mult_mod = 1 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.odds_top, card.ability.extra.odds_bottom, 'twow_randomg')
        return { vars = { numerator, denominator, card.ability.extra.mult_mod, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if (
            context.change_suit or context.playing_card_added or context.setting_blind or context.pre_discard or context.blind_disabled or context.blind_defeated
            or context.press_play or context.starting_shop or context.ending_shop or context.open_booster or context.ending_booster or context.buying_card or
            context.selling_card or context.using_consumeable or context.reroll_shop or context.skip_blind or context.tag_added or context.joker_type_destroyed or 
            context.change_suit or context.change_rank
        ) and not context.blueprint and SMODS.pseudorandom_probability(card, 'twow_randomg', card.ability.extra.odds_top, card.ability.extra.odds_bottom) then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
            }
        end

        if context.joker_main then
            return {mult = card.ability.extra.mult}            
        end
    end
}


-- CHARITO
SMODS.Joker {
    key = "charito",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 3, y = 4 },

    loc_txt = {
        name="Charito",
        text={
            "{C:red}+#2#{} discards and",
            "{C:blue}-#1#{} hands each round"
        },
    },

    config = { extra = { hands = 2, discards = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands, card.ability.extra.discards } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discards
        ease_discard(card.ability.extra.discards)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
        ease_hands_played(-card.ability.extra.hands)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discards
        ease_discard(-card.ability.extra.discards)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
        ease_hands_played(card.ability.extra.hands)
    end,
}



-- CATIE (8TH)
SMODS.Joker {
    key = "catie",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 4, y = 4 },

    loc_txt = {
        name="Catie",
        text={
            "Each {C:attention}Enhanced Card{}",
            "held in hand",
            "gives {C:chips}+#1#{} Chips"
        },
    },

    config = { extra = { chips = 40 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and next(SMODS.get_enhancements(context.other_card)) then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'), colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end,
}


-- ZIXI
SMODS.Joker {
    key = "zixi",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 4 },

    loc_txt = {
        name="Zixi",
        text={
            "Turn first scoring",
            "card {C:attention}Wild{} if poker hand",
            "contains {C:attention}#1#"
        },
    },


    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        return { vars = { localize('Straight', 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and next(context.poker_hands['Straight']) then
            context.scoring_hand[1]:set_ability('m_wild', nil, true)
            G.E_MANAGER:add_event(Event({
                func = function()
                    context.scoring_hand[1]:juice_up()
                    return true
                end
            }))
            return {
                message = 'Wild',
                colour = G.C.PURPLE
            }
        end
    end
}


-- MEPTUNE
SMODS.Joker {
    key = "meptune",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 7, y = 4 },

    loc_txt = {
        name="Meptune",
        text={
            "{C:chips}+#1#{} Chips",
            "{X:mult,C:white} X#2# {} Mult"
        },
    },

    config = { extra = { chips = 150, xmult = 0.5 } },

    loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.chips, card.ability.extra.xmult } } end,

    calculate = function(self, card, context)
        if context.joker_main then return { chips = card.ability.extra.chips, xmult = card.ability.extra.xmult } end
    end
}


-- MAYUNDERFLOWERS
SMODS.Joker {
    key = "mayunderflowers",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 4 },

    loc_txt = {
        name="MayUnderFlowers",
        text={
            "{C:attention}Wild Cards{} give",
            "{C:mult}+#1#{} Mult when scored",
            "and can't be debuffed"
        },
    },

    config = { extra = { mult = 5 } },

    loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.mult } } end,

    calculate = function(self, card, context)
        if context.debuff_card and SMODS.has_enhancement(context.debuff_card, 'm_wild') then
            return { prevent_debuff = true }
        end
        if context.setting_ability and SMODS.has_enhancement(context.other_card, 'm_wild') then
            context.other_card:set_debuff(false)
            return
        end

        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, 'm_wild') then return { mult = card.ability.extra.mult } end
        end
    end,
}




-- QUETZAL

SMODS.Joker {
    key = "quetzal",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 9, y = 4 },

    loc_txt = {
        name="Quetzal",
        text={
            "{X:mult,C:white} X#1# {} Mult for each",
            "{C:attention}Joker{} to the",
            "right of this one",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {}{C:inactive} Mult)"
        },
    },

    config = { extra = { xmult = 0.75 } },

    loc_vars = function(self, info_queue, card)

        local joker_count = 0
        if G.jokers then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then joker_count = #G.jokers.cards - i end
            end
        end

        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult * joker_count } }
    end,


    calculate = function(self, card, context)
        if context.joker_main then

            local joker_count = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then joker_count = #G.jokers.cards - i end
            end

            if joker_count > 0 then return { xmult = card.ability.extra.xmult * joker_count } end
        end
    end
}


-- AUBREY
SMODS.Joker {
    key = "goobrey",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 0, y = 5 },

    loc_txt = {
        name="goobrey",
        text={
            "Decrease {C:attention}rank{} of",
            "{C:attention}first{} played card",
            "when scored"
        },
    },

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card == context.scoring_hand[1] then
            local scored_card = context.other_card
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                local suit_prefix = string.sub(scored_card.base.suit, 1, 1)..'_'
                local rank_suffix = scored_card.base.id == 2 and 14 or math.max(scored_card.base.id-1, 2)
                if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                elseif rank_suffix == 10 then rank_suffix = 'T'
                elseif rank_suffix == 11 then rank_suffix = 'J'
                elseif rank_suffix == 12 then rank_suffix = 'Q'
                elseif rank_suffix == 13 then rank_suffix = 'K'
                elseif rank_suffix == 14 then rank_suffix = 'A'
                end
                scored_card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
            return true end }))

            G.E_MANAGER:add_event(Event({
                func = function()
                    scored_card:juice_up()
                    return true
                end
            }))
        end
    end,
}


-- LEGITSI
SMODS.Joker {
    key = "legitsi",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 1, y = 5 },

    loc_txt = {
        name="LegitSi",
        text={
            "{X:mult,C:white} X#1# {} Mult",
            "Destroys all other",
            "{C:attention}Jokers{} when bought"
        },
    },

    config = { extra = { xmult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.buying_card and context.card == card and G.jokers and not context.blueprint then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and not SMODS.is_eternal(G.jokers.cards[i], card) and not G.jokers.cards[i].getting_sliced then
                    G.jokers.cards[i].getting_sliced = true
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            (card):juice_up(0.8, 0.8)
                            G.jokers.cards[i]:start_dissolve({ G.C.RED }, nil, 1.6)
                            return true
                        end
                    }))
                end
            end
        end
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end
}


-- JOEMAN
SMODS.Joker {
    key = "joeman",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 2, y = 5 },

    loc_txt = {
        name="joeman",
        text={
            "Played {C:attention}number{} cards",
            "give half their {C:attention}rank{}",
            "in {C:mult}+Mult{} when scored",
        },
    },

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local card_rank = context.other_card:get_id()
            if card_rank <= 10 and card_rank >= 2 then
                return {
                    mult = card_rank/2
                }
            end
        end
    end
}

-- VOII
SMODS.Joker {
    key = "voii",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 3, y = 5 },

    loc_txt = {
        name="voii",
        text={
            "This Joker gains {X:mult,C:white} X#2# {} Mult",
            "when card of {C:spades}Spades{}",
            "suit is destroyed",
            "{C:inactive}(Currently {X:mult,C:white} X#1# {}{C:inactive} Mult)"
        },
    },

    config = { extra = { xmult = 1, xmult_mod = 0.4 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local spades = 0
            for _, removed_card in ipairs(context.removed) do
                if removed_card:is_suit("Spades") then spades = spades + 1 end
            end
            if spades > 0 then
                card.ability.extra.xmult = card.ability.extra.xmult + spades * card.ability.extra.xmult_mod
                return { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } } }
            end
        end
        if context.joker_main then return {xmult = card.ability.extra.xmult} end
    end

}


-- CAUSE KEY
SMODS.Joker {
    key = "causekey",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 4, y = 5 },

    loc_txt = {
        name="Cause Key",
        text={
            "Gain {C:blue}+#1#{} hand when",
            "{C:attention}Blind{} selected",
            "{C:red}$-#1#{} each round"
        },
    },
    config = { extra = { hands = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    ease_hands_played(card.ability.extra.hands)
                    SMODS.calculate_effect(
                        { message = localize { type = 'variable', key = 'a_hands', vars = { card.ability.extra.hands } } },
                        context.blueprint_card or card)
                    return true
                end
            }))
            return nil, true
        end
    end,
    calc_dollar_bonus = function(self, card) return -card.ability.extra.hands end
}



-- LEAH
SMODS.Joker {
    key = "leopardsun",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 5, y = 5 },

    loc_txt = {
        name="Leopardsun",
        text={
            "Adds a {C:purple}Purple{} or",
            "{C:attention}Gold Seal{} to a",
            "{C:attention}card{} held in hand",
            "at end of round"
        },
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS['Gold']
        info_queue[#info_queue + 1] = G.P_SEALS['Purple']
    end,

    calculate = function(self, card, context)

        if context.end_of_round and context.main_eval then

            local conv_card = pseudorandom_element(G.hand.cards, 'twow_leopardsun_card')
            local seal_to_add = pseudorandom('twow_leopardsun_card', 1, 2) == 1 and 'Gold' or 'Purple'

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    conv_card:set_seal(seal_to_add, nil, true)
                    return true
                end
            }))
            return { message = seal_to_add..'!', colour = seal_to_add == 'Gold' and G.C.MONEY or G.C.PURPLE}

        end
    end,
}

-- CHECK HUMANY
SMODS.Joker {
    key = "check_humany",
    blueprint_compat = true, eternal_compat = false, 
    unlocked = true, 
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 0, y = 6 },

    loc_txt = {
        name="Check Humany",
        text={
            "{C:chips}+#1#{} Chips",
            "{C:chips}-#2#{} Chips every time",
            "you check this {C:attention}Joker",
        },
    },
    config = { extra = { chips = 80, chip_mod = 2 }, immutable = {check_count = 0} },

    loc_vars = function(self, info_queue, card)

        if card.ability.immutable.check_count < 1 then card.ability.immutable.check_count = card.ability.immutable.check_count + 1 
        else card.ability.extra.chips = math.max(card.ability.extra.chips - card.ability.extra.chip_mod, 0) end

        if not card.area.config.collection and card.ability.extra.chips <= 0 then
            G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()

            attention_text({
                text = "Holy shit new EWOW", scale = 0.9, hold = 1.4,
                backdrop_colour = G.C.MONEY,
                align = 'bm', major = card, yoffset = {x = 0, y = -0.8},
                silent = true
                })

            SMODS.destroy_cards(card, nil, nil, true)

            return true end }))
        end

        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then

            if card.ability.extra.chips <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = "Holy shit new EWOW",
                    colour = G.C.MONEY
                }
            end

            return {chips = card.ability.extra.chips}
        end
    end
}

-- GRACE PERIOD
SMODS.Joker {
    key = "grace_period",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 1, y = 6 },

    loc_txt = {
        name="Grace Period",
        text={
            "{C:attention}Round{} doesn't end",
            "until all hands played",
        },
    },

    calculate = function(self, card, context)
        if context.press_play then
            GLOBAL_twow_grace_period = true
        end
    end,

    add_to_deck = function(self, card, from_debuff) GLOBAL_twow_grace_period = true end,

    remove_from_deck = function(self, card, from_debuff)
        has_other_joker = false
        for _, joker in ipairs(Library.find_card("j_twow_grace_period")) do if joker ~= card then has_other_joker = true end end 
        if not next(Library.find_card("j_twow_grace_period")) then GLOBAL_twow_grace_period = false end
    end,
}


-- SCRAPER
SMODS.Joker {
    key = "scraper",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 2, y = 6 },

    loc_txt = {
        name="Scraper",
        text={
            "{X:mult,C:white} X#1# {} Mult on final",
            "hand if you have",
            "at least {C:attention}80%",
            "of required chips"
            },
    },

    config = { extra = { xmult = 10 } },

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.xmult } }
    end,

    -- this code fucking sucks

    calculate = function(self, card, context)

        if context.joker_main then

            local other_chips = G.GAME.blind.chips

            if G.GAME.blind.config.blind.key == 'bl_mp_nemesis' then
                other_chips = tonumber( string.gsub(MP.INSANE_INT.to_string(MP.GAME.enemy.score), ",", ""), 10 )
                if other_chips == nil then other_chips = to_big( MP.INSANE_INT.to_string(MP.GAME.enemy.score)) end
            end

            if G.GAME.chips / other_chips >= 0.8 and G.GAME.current_round.hands_left == 0 then
                return { xmult = card.ability.extra.xmult }
            end
        end
        if G.GAME.blind and context.drawing_cards then

            local other_chips = G.GAME.blind.chips

            if G.GAME.blind.config.blind.key == 'bl_mp_nemesis' then
                other_chips = tonumber( string.gsub(MP.INSANE_INT.to_string(MP.GAME.enemy.score), ",", ""), 10 )
                if other_chips == nil then other_chips = to_big( MP.INSANE_INT.to_string(MP.GAME.enemy.score)) end
            end

            if G.GAME.chips / other_chips >= 0.8 and G.GAME.current_round.hands_left == 1 and not context.blueprint then
                local eval = function(card) return G.GAME.current_round.hands_left == 1 and not G.RESET_JIGGLES end
                juice_card_until(card, eval, true)
            end
        end
    end,
}

-- SPEEDINESS POTION
SMODS.Joker {
    key = "speediness_potion",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 1,
    cost = 4,
    atlas = 'twow_jokers',
    pos = { x = 3, y = 6 },

    loc_txt = {
        name="Speediness Potion",
        text={
            "{C:attention}X#1#{} Game Speed",
            "{C:dark_edition}+1{} Joker Slot",
            },
    },

    config = { extra = { new_game_speed = 4 } },

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.new_game_speed } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.jokers:change_size(1)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.jokers:change_size(-1)
    end,
}

local gfcfbs = G.FUNCS.check_for_buy_space
G.FUNCS.check_for_buy_space = function(card)
    if card.config.center.key == "j_twow_speediness_potion" then
        return G.jokers.config.card_limit <= G.jokers.config.card_count
    end
    return gfcfbs(card)
end


-- TRACT B
SMODS.Joker {
    key = "tract_b",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 4, y = 6 },

    loc_txt = {
        name="[TRACT B]",
        text={
            "This Joker gains {C:mult}+#1#{} Mult",
            "every {C:attention}#4#th{} card scored",
            "{C:inactive}(#3#/#4#) (Currently {C:red}+#2#{C:inactive} Mult)",
            },
    },

    config = { extra = { mult = 0, mult_mod = 2 }, immutable = {scored = 0, to_score = 5} },

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.mult_mod, card.ability.extra.mult, card.ability.immutable.scored, card.ability.immutable.to_score } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.immutable.scored = card.ability.immutable.scored + 1

            while card.ability.immutable.scored >= card.ability.immutable.to_score do

                card.ability.immutable.scored = card.ability.immutable.scored - card.ability.immutable.to_score
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                
                return {
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                    message_card = card,
                    colour = G.C.MULT,
                }
                
            end
        end
    end,
}

-- GLICKO MODE
SMODS.Joker {
    key = "glicko_mode",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 3,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 5, y = 6 },

    loc_txt = {
        name="Glicko Mode",
        text={
            "{C:blue}Common{} Jokers give",
            "{X:mult,C:white} X#1# {} Mult and",
            "are {C:attention}debuffed{}"
            },
    },

    config = { extra = { xmult = 2 } },

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.card_added and context.card.ability.set == 'Joker' then
            for _, joker in ipairs(G.jokers.cards or {}) do
                if joker.config.center.rarity == 1 then
                    SMODS.debuff_card(joker, true, 'glicko_mode')
                end
            end
            if context.card.config.center.rarity == 1 then
                SMODS.debuff_card(context.card, true, 'glicko_mode')
            end
        end
        if context.other_joker and context.other_joker.config.center.rarity == 1 then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        for _, joker in ipairs(G.jokers.cards or {}) do
            if joker.config.center.rarity == 1 then
                SMODS.debuff_card(joker, true, 'glicko_mode')
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        for _, joker in ipairs(G.jokers.cards or {}) do
            if joker.config.center.rarity == 1 then
                SMODS.debuff_card(joker, false, 'glicko_mode')
            end
        end
    end,

}


-- PUNSLOP
SMODS.Joker {
    key = "punslop",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 1,
    cost = 5,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 6 },

    loc_txt = {
        name="Punslop",
        text={
            "{C:mult}+#1#{} Mult per",
            "unique scoring {C:attention}suit{}"
            },
    },

    config = { extra = { mult = 5 } },

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.mult}}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #context.scoring_hand do
                if not SMODS.has_any_suit(context.scoring_hand[i]) then
                    for suit_name, _ in pairs(suits) do
                        if context.scoring_hand[i]:is_suit(suit_name) and suits[suit_name] == 0 then suits[suit_name] = 1 break
                        end
                    end
                end
            end
            for i = 1, #context.scoring_hand do
                if SMODS.has_any_suit(context.scoring_hand[i]) then
                    for suit_name, _ in pairs(suits) do
                        if context.scoring_hand[i]:is_suit(suit_name) and suits[suit_name] == 0 then suits[suit_name] = 1 break
                        end
                    end
                end
            end
            total_scoring_suits = suits["Hearts"] + suits["Diamonds"] + suits["Spades"] + suits["Clubs"]
            return {
                mult = card.ability.extra.mult * total_scoring_suits
            }
        end
    end,

}
  

-- DRP
SMODS.Joker {
    key = "drp",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 7, y = 6 },

    loc_txt = {
        name="DRP",
        text={
            "Balance {C:attention}base{}",
            "{C:blue}Chips{} and {C:red}Mult{}",
            },
    },

    calculate = function(self, card, context)
        if context.modify_hand then
            mult = mod_mult((hand_chips + mult)%2+mult)
            return {balance = true}
        end
    end,

}

-- GRIDLOCK
SMODS.Joker {
    key = "gridlock",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 6 },

    loc_txt = {
        name="Gridlock",
        text={
            "{V:1}#1#{} count as {C:attention}Wild Cards",
            "{s:0.8}suit changes at end of round",
            },
    },

    config = { extra = { } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        local suit = (G.GAME.current_round.twow_gridlock or {}).suit or 'Spades'
        return { vars = { localize(suit, 'suits_plural'), colours = { G.C.SUITS[suit] } } }
    end,
    calculate = function(self, card, context)
        if context.check_enhancement then
            if context.other_card:is_suit(G.GAME.current_round.twow_gridlock.suit) then
                return {m_wild = true} 
            end
        end
    end
}


local function reset_twow_gridlock()
    G.GAME.current_round.twow_gridlock = G.GAME.current_round.twow_gridlock or { suit = 'Spades' }
    local valid_suits = {}
    for k, v in ipairs({ 'Spades', 'Hearts', 'Clubs', 'Diamonds' }) do
        if v ~= G.GAME.current_round.twow_gridlock.suit then valid_suits[#valid_suits + 1] = v end
    end
    local gridlock = pseudorandom_element(valid_suits, 'twow_gridlock_' .. G.GAME.round_resets.ante)
    G.GAME.current_round.twow_gridlock.suit = gridlock
end

-- ALUMNUS
SMODS.Joker {
    key = "alumnus",
    blueprint_compat = true,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 9, y = 6 },

    loc_txt = {
        name="Alumnus",
        text={
            "Create an {C:twow_index}Index Card{} the",
            "first time {C:attention}secret hand",
            "is played this Ante",
            "{C:inactive}(Must have room)",
            },
    },

    config = { extra = { played_this_ante = false } },

    calculate = function(self, card, context)
        if context.before then
            if (next(context.poker_hands["Five of a Kind"]) or next(context.poker_hands["Flush Five"]) or next(context.poker_hands["Flush House"])) and not card.ability.extra.played_this_ante then
                card.ability.extra.played_this_ante = true
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            SMODS.add_card {
                                set = 'twow_Index',
                                key_append = 'twow_seance' 
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)
                    }))
                    return {
                        message = '+Index',
                        colour = HEX('166125')
                    }
                end
            end
        end
        if context.end_of_round and context.game_over == false and context.beat_boss and not context.repetition and not context.blueprint then
            card.ability.extra.played_this_ante = false
        end
    end
}

-- MYSTERIOUS ALT FIGURE
SMODS.Joker {
    key = "mysterious_alt_figure",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 6,
    atlas = 'twow_jokers',
    pos = { x = 6, y = 5 },

    loc_txt = {
        name="Mysterious Alt Figure",
        text={
            "Has the effect of a",
            "random {C:attention}Library Joker{}"
            },
    },

    config = { extra = { }, stolen = nil },

    calculate = function(self, card, context)

        if card.ability ~= nil and card.ability.stolen == nil then

            card.ability.stolen = true

            local modjokers = {}
            for k, v in pairs(G.P_CENTER_POOLS.Joker) do
                if v.mod and v.mod.id == "TheLibrary" and v.rarity ~= 4 then
                    table.insert(modjokers, v)
                end
            end
            local joker = pseudorandom_element(modjokers, pseudoseed("twow_maf"))
            card.ability.stolen = joker.key
            card.ability.extra = joker.config.extra
            card.ability.immutable = joker.config.immutable
        end

        if card.ability.stolen ~= nil then
            local success, result = pcall(function()
                return G.P_CENTERS[card.ability.stolen].calculate(self, card, context)
            end)
            if success then return result end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        if card.ability.stolen ~= nil then
            local success, result = pcall(function()
                return G.P_CENTERS[card.ability.stolen].add_to_deck(self, card, from_debuff)
            end)
            if success then return result end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if card.ability.stolen ~= nil then
            local success, result = pcall(function()
                return G.P_CENTERS[card.ability.stolen].remove_from_deck(self, card, from_debuff)
            end)
            if success then return result end
        end
    end,

}


-- CASTORCORE
SMODS.Joker {
    key = "castorcore",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 7, y = 5 },

    loc_txt = {
        name="CASTORCORE",
        text={
            "All {C:tarot}Arcana Packs{} in",
            "the shop are {C:attention}free",
            },
    },

    config = { extra = { }, stolen = nil },

    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, other_card in pairs(G.I.CARD) do
                    if other_card.set_cost then other_card:set_cost() end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, other_card in pairs(G.I.CARD) do
                    if other_card.set_cost then other_card:set_cost() end
                end
                return true
            end
        }))
    end,
}

local card_set_cost_value_ref = Card.set_cost_value
function Card:set_cost_value(...)
    local ret = card_set_cost_value_ref(self, ...)
    if next(Library.find_card("j_twow_castorcore")) then
        if (self.ability.set == 'Booster' and self.config.center.kind == 'Arcana') then self.cost = 0 end
    end
    return ret
end

-- OLIVE
SMODS.Joker {
    key = "justatoad",
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true, 
    rarity = 3,
    cost = 10,
    atlas = 'twow_jokers',
    pos = { x = 8, y = 5 },

    loc_txt = {
        name="Just A Toad",
        text={
            "Sell this card to",
            "apply a random {C:attention}Bookmark{}",
            "to all your {C:attention}Jokers{}"
        },
    },

    config = { extra = { } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.amount_1, card.ability.extra.amount_2 } }
    end,

    calculate = function(self, card, context)
        if context.selling_self then

            for i = 1, #G.jokers.cards do
                if not has_bookmark(G.jokers.cards[i]) and card ~= G.jokers.cards[i] then
                    add_bookmark(G.jokers.cards[i], 'any')
                end
            end

            return {
                message = "Bookmarked!",
                colour = G.ARGS.LOC_COLOURS.twow_index,
            }

        end
    end,
}

-- canicao
SMODS.Joker {
    key = "canicao",
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true, 
    rarity = 2,
    cost = 8,
    atlas = 'twow_jokers',
    pos = { x = 9, y = 5 },

    loc_txt = {
        name="canicao",
        text={
            "{X:mult,C:white} X#1# {} Mult",
            "Shuffles {C:attention}Jokers{}",
            "when hand played"
        },
    },

    config = { extra = { xmult = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.press_play then
            G.jokers:unhighlight_all()
            if #G.jokers.cards > 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.jokers:shuffle('twow_canicao')
                                play_sound('cardSlide1', 0.85)
                                return true
                            end,
                        }))
                        delay(0.5)
                        return true
                    end
                }))
            end
        end

        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}

-- CARYKH
SMODS.Joker {
    key = "carykh",
    blueprint_compat = false,
    unlocked = true, 
    rarity = 4,
    cost = 20,
    atlas = 'twow_jokers',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },

    loc_txt = {
        name="carykh",
        text={
            "Doubles the values",
            "in all {C:attention}Library Jokers{}"
        },
    },

    calculate = function(self, card, context)
        if context.card_added and not context.blueprint then
            if context.card.ability.extra
            and (context.card.config.center.mod or {}).id == 'TheLibrary'
            and context.card.config.center.key ~= "j_twow_carykh" then
                for k, v in pairs(context.card.ability.extra) do
                    if type(v) == 'number' then
                        if (k == 'xmult') then context.card.ability.extra[k] = 2*v -- 2*v-1
                        else context.card.ability.extra[k] = 2*v end
                    end
                end
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        for _, curr_joker in pairs(G.jokers.cards) do
            if curr_joker.ability.extra and curr_joker
            and (curr_joker.config.center.mod or {}).id == 'TheLibrary'
            and curr_joker.config.center.key ~= "j_twow_carykh" then
                for k, v in pairs(curr_joker.ability.extra) do
                    if type(v) == 'number' then
                        if (k == 'xmult') then curr_joker.ability.extra[k] = 2*v -- 2*v-1
                        else curr_joker.ability.extra[k] = 2*v end
                    end
                end
            end
        end

    end,

    remove_from_deck = function(self, card, from_debuff)
        for _, curr_joker in pairs(G.jokers.cards) do
            if curr_joker.ability.extra and curr_joker
            and (curr_joker.config.center.mod or {}).id == 'TheLibrary'
            and curr_joker.config.center.key ~= "j_twow_carykh" then
                for k, v in pairs(curr_joker.ability.extra) do
                    if type(v) == 'number' then
                        if (k == 'xmult') then curr_joker.ability.extra[k] = v/2 -- (v+1)/2
                        else curr_joker.ability.extra[k] = v/2 end
                    end
                end
            end
        end
    end,

}


function SMODS.current_mod.reset_game_globals(run_start)
    if run_start then
        get_twow_koopa_initial_ranks()
        GLOBAL_twow_grace_period = false
    end
    reset_twow_gridlock()
end



-- INDEX CARDS & RELATED CONTENT

SMODS.ConsumableType {
    key = 'twow_Index',
    default = 'c_twow_thaumaturgic',
    loc_txt = {
        name = 'Index',
        collection = 'Index Cards',
        text = { 'Test' },
    },

    primary_colour = HEX("666BC1"),
    secondary_colour = HEX("8F92E8"),
    collection_rows = { 2, 2 }
}

-- Packs
create_booster = function(key, weight, name, options, choices, x, y, cost)
    SMODS.Booster {
        key = key,
        set = "Booster",
        weight = weight,
        atlas = 'twow_boosters',
        kind = 'twow_Index', 
        cost = cost,
        pos = { x = x, y = y },
        config = { extra = options, choose = choices },

        loc_txt = {
            name=name,
            group_name = "Catalog Pack",
            text={
                "Choose {C:attention}"..choices.."{} of up to",
                "{C:attention}"..options.."{C:twow_index} Index{} cards",
            },
        },

        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, HEX("666BC1"))
            ease_background_colour({new_colour = HEX("666BC1"), special_colour = HEX("363970"), contrast = contrast})
        end,

        create_card = function(self, card, i)
            return {
                set = "twow_Index",
                area = G.pack_cards,
                skip_materialize = true,
                key_append = "_twow_ind"
            }
        end,
    }
end



create_booster('index_normal_1', 0.3, "Catalog Pack", 2, 1, 0, 0, 6)
create_booster('index_normal_2', 0.3, "Catalog Pack", 2, 1, 1, 0, 6)
create_booster('index_jumbo_1', 0.3, "Jumbo Catalog Pack", 4, 1, 2, 0, 8)
create_booster('index_mega_1', 0.07, "Mega Catalog Pack", 4, 2, 3, 0, 10)

-- THAUMATURGIC
SMODS.Consumable {
    key = 'thaumaturgic',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 0, y = 0 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Thaumaturgic",
        text={
            "Add a {C:purple}Purple Bookmark{}",
            "to selected Joker",
        },
    },

    config = { extra = { bookmark = 'purple'}},

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "twow_bookmark_"..card.ability.extra.bookmark, vars = {} }
    end,


    use = function(self, card, area, copier) add_bookmark(G.jokers.highlighted[1], card.ability.extra.bookmark) end,
    can_use = function(self, card) return #G.jokers.highlighted > 0 end
}

-- VERBIGERATIVE
SMODS.Consumable {
    key = 'verbigerative',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 1, y = 0 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Verbigerative",
        text={
            "Add a {C:red}Red Bookmark{}",
            "to selected Joker",
        },
    },

    config = { extra = { bookmark = 'red'}},

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'twow_verbigerative')
        info_queue[#info_queue + 1] = { set = "Other", key = "twow_bookmark_"..card.ability.extra.bookmark, vars = { numerator, denominator } }
    end,

    use = function(self, card, area, copier) add_bookmark(G.jokers.highlighted[1], card.ability.extra.bookmark) end,
    can_use = function(self, card) return #G.jokers.highlighted > 0 end
}

-- AUSPICIOUS
SMODS.Consumable {
    key = 'auspicious',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 2, y = 0 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Auspicious",
        text={
            "Add a {C:green}Green Bookmark{}",
            "to selected Joker",
        },
    },

    config = { extra = { bookmark = 'green'}},

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "twow_bookmark_"..card.ability.extra.bookmark, vars = {} }
    end,

    use = function(self, card, area, copier) add_bookmark(G.jokers.highlighted[1], card.ability.extra.bookmark) end,
    can_use = function(self, card) return #G.jokers.highlighted > 0 end
}

-- EFFULGENCE
SMODS.Consumable {
    key = 'effulgence',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 3, y = 0 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Effulgence",
        text={
            "Add a {C:money}Yellow Bookmark{}",
            "to selected Joker",
        },
    },

    config = { extra = { bookmark = 'yellow'}}, 

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "twow_bookmark_"..card.ability.extra.bookmark, vars = {} }
    end,

    use = function(self, card, area, copier) add_bookmark(G.jokers.highlighted[1], card.ability.extra.bookmark) end,
    can_use = function(self, card) return #G.jokers.highlighted > 0 end
}

-- PHANTASM
SMODS.Consumable {
    key = 'phantasm',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 4, y = 0 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Phantasm",
        text={
            "Add a {C:spectral}Blue Bookmark{}",
            "to selected Joker",
        },
    },

    config = { extra = { bookmark = 'blue'}},

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "twow_bookmark_"..card.ability.extra.bookmark, vars = {} }
    end,

    use = function(self, card, area, copier) add_bookmark(G.jokers.highlighted[1], card.ability.extra.bookmark) end,
    can_use = function(self, card) return #G.jokers.highlighted > 0 end
}

-- ALACRITY
SMODS.Consumable {
    key = 'alacrity',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 0, y = 1 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Alacrity",
        text={
            "Add an {C:diamonds}Orange Bookmark{}",
            "to selected Joker",
        },
    },

    config = { extra = { bookmark = 'orange'}},

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "twow_bookmark_"..card.ability.extra.bookmark, vars = {} }
    end,

    use = function(self, card, area, copier) add_bookmark(G.jokers.highlighted[1], card.ability.extra.bookmark) end,
    can_use = function(self, card) return #G.jokers.highlighted > 0 end
}

-- PERCIPIENCE
SMODS.Consumable {
    key = 'percipience',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 3, y = 1 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Percipience",
        text={
            "Create a {C:attention}Joker{} with",
            "a random {C:attention}Bookmark{}",
        },
    },

    use = function(self, card, area, copier)

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'Joker', stickers = {'twow_bookmark_any'} })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

-- PANACEA
SMODS.Consumable {
    key = 'panacea',
    set = 'twow_Index',
    atlas = 'twow_indexes',
    pos = { x = 4, y = 1 },
    cost = 5,
    display_size = {w = 95, h = 59},

    loc_txt = {
        name="Panacea",
        text={
            "Add a {C:attention}Bookmark{}",
            "to two random {C:attention}Jokers{}",
        },
    },

    use = function(self, card, area, copier)

        local empty_jokers = {}
        for i = 1, #G.jokers.cards do
            if not has_bookmark(G.jokers.cards[i]) then
                empty_jokers[#empty_jokers + 1] = G.jokers.cards[i]
            end
        end

        pseudoshuffle(empty_jokers, 'twow_panacea')
        add_bookmark(empty_jokers[1], 'any')
        add_bookmark(empty_jokers[2], 'any')

    end,
    can_use = function(self, card)
        local empty_jokers = {}
        for i = 1, #G.jokers.cards do
            if not has_bookmark(G.jokers.cards[i]) then
                empty_jokers[#empty_jokers + 1] = G.jokers.cards[i]
            end
        end
        return #empty_jokers >= 2
    end
}

--- BOOKWORM DECK
SMODS.Back{
    name = "Bookworm Deck",
    unlocked = true, discovered = true,
    key = "bookworm",
    atlas = 'twow_jokers',
    pos = {x = 8, y = 3},

    loc_txt = {
        name ="Bookworm Deck",
        text={
            "{C:attention}Jokers{} in shop",
            "can have {C:attention}Bookmarks{}",
        },
    },

    apply = function(self)
        G.GAME.modifiers.twow_enable_bookmarks_in_shop = true
    end,

}


-- DOG-EARED
SMODS.Voucher {
    key = 'dog_eared',
    pos = { x = 0, y = 7 },
    atlas = 'twow_jokers',

    loc_txt = {
        name = 'Dog-Eared',
        text = {
            "{C:attention}Jokers{} in Booster Packs",
            "can have {C:attention}Bookmarks{}",
        }
    },

    redeem = function(self, card)
        G.GAME.modifiers.twow_enable_bookmarks_in_packs = true
    end
}

-- MARKED UP
SMODS.Voucher {
    key = 'marked_up',
    requires = { 'v_twow_dog_eared' },
    pos = { x = 1, y = 7 },
    atlas = 'twow_jokers',

    loc_txt = {
        name = 'Marked Up',
        text = {
            "{C:twow_index}Catalog Packs{} are {C:attention}2X",
            "more likely to appear",
        }
    },

    redeem = function(self, card)
        G.P_CENTERS.p_twow_index_normal_1.weight = G.P_CENTERS.p_twow_index_normal_1.weight * 2
        G.P_CENTERS.p_twow_index_normal_2.weight = G.P_CENTERS.p_twow_index_normal_2.weight * 2
        G.P_CENTERS.p_twow_index_jumbo_1.weight = G.P_CENTERS.p_twow_index_jumbo_1.weight * 2
        G.P_CENTERS.p_twow_index_mega_1.weight = G.P_CENTERS.p_twow_index_mega_1.weight * 2
    end
}

-- BOOKMARKS

bookmark_list = {'any','yellow','red','green','purple','blue','orange'}

has_bookmark = function(joker)
    for _, bookmark in ipairs(bookmark_list) do
        if joker.ability["twow_bookmark_"..bookmark] then
            return true
        end
    end
    return false
end

add_bookmark = function(card, bookmark)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
            card:add_sticker('twow_bookmark_'..bookmark)
            card:juice_up(0.3, 0.3)
            play_sound('card1', 1.2, 0.4)
        return true
        end
    }))
end

global_bookmark_apply = function(self, card, val)
    card.ability[self.key] = val 
    if val then
        for _, bookmark_to_kill in ipairs(bookmark_list) do
            if "twow_bookmark_"..bookmark_to_kill ~= self.key then
                card:remove_sticker("twow_bookmark_"..bookmark_to_kill)
            end
        end
    end
end

global_bookmark_draw = function(self, card) --don't draw shine
    G.shared_stickers[self.key].role.draw_major = card
    G.shared_stickers[self.key]:draw_shader("dissolve", nil, nil, nil, card.children.center)
end

global_bookmark_should_apply = function(self, card, center, area, bypass_roll) return card.ability.set == "Joker" and bypass_roll end,


SMODS.Sticker {
    key = "bookmark_any",
    badge_colour = HEX('A0363B'),
    atlas = 'twow_jokers',
    no_collection = true, unlocked = true, discovered = true,
    pos = { x = 2, y = 3 },

    default_compat = true,

    loc_txt = {
        name="Any Bookmark",
        label = "Bookmarked",
        text={
            "Applies a random", "{C:attention}Bookmark",
        },
    },

    should_apply = function(self, card, center, area, bypass_roll)
        return card.ability.set == "Joker" and
            (
                (G.GAME.modifiers.twow_enable_bookmarks_in_shop and pseudorandom('twow_apply_bookmark') < 0.1) or
                ( area == G.pack_cards and G.GAME.modifiers.twow_enable_bookmarks_in_packs and pseudorandom('twow_apply_bookmark_pack') < 0.1 )
                or bypass_roll
            )
    end,

    apply = function(self, card, val)
        if val then
            local bookmark_options = {'yellow','red','green','purple','blue','orange'}
            if card.ability.eternal then table.remove(bookmark_options, 5) end

            local bookmark_to_add = pseudorandom_element(bookmark_options,'twow_bookmarks')
            card:add_sticker("twow_bookmark_"..bookmark_to_add, true)
            card:remove_sticker(self.key)
        end
    end,
    
	draw = global_bookmark_draw,
}

SMODS.Sticker {
    key = "bookmark_purple",
    badge_colour = HEX('9050B2'),
    atlas = 'twow_jokers',
    pos = { x = 2, y = 3 },
    default_compat = true,
    rate = 0,

    loc_txt = {
        name="Purple Bookmark",
        label = "Purple Bookmark",
        text={
            "Create a {C:tarot}Tarot{} card",
            "at end of round",
            "{C:inactive}(Must have room)",
        },
    },

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
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

            return {
                message = localize('k_plus_tarot'),
                colour = G.C.PURPLE,
            }
        end
    end,
    
    should_apply = global_bookmark_should_apply,
    apply = global_bookmark_apply,
	draw = global_bookmark_draw,
}

SMODS.Sticker {
    key = "bookmark_red",
    badge_colour = HEX('E04C53'),
    atlas = 'twow_jokers',
    pos = { x = 3, y = 3 },
    default_compat = true,
    rate = 0,

    loc_txt = {
        name="Red Bookmark",
        label = "Red Bookmark",
        text={
            "{C:green}#1# in #2#{} odds to",
            "retrigger this {C:attention}Joker",
        },
    },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'twow_verbigerative')
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card == card then
            if SMODS.pseudorandom_probability(card, 'twow_verbigerative', 1, 3) then 
                return {repetitions = 1}
            end
        end
    end,
    
    should_apply = global_bookmark_should_apply,
    apply = global_bookmark_apply,
	draw = global_bookmark_draw,
}

SMODS.Sticker {
    key = "bookmark_green",
    badge_colour = HEX('53A54C'),
    atlas = 'twow_jokers',
    pos = { x = 4, y = 3 },
    default_compat = true,
    rate = 0,

    loc_txt = {
        name="Green Bookmark",
        label = "Green Bookmark",
        text={
            "Doubles all {C:attention}Joker",
            "{C:green,E:1,S:1.1}probabilities",
        },
    },

	calculate = function(self, card, context)
		if context.mod_probability and context.trigger_obj.ability.set == "Joker" and context.identifier ~= "twow_verbigerative" then
			return {
				numerator = context.numerator * 2,
			}
		end
	end,
    
    should_apply = global_bookmark_should_apply,
    apply = global_bookmark_apply,
	draw = global_bookmark_draw,
}

SMODS.Sticker {
    key = "bookmark_yellow",
    badge_colour = HEX('CEA640'),
    atlas = 'twow_jokers',
    pos = { x = 5, y = 3 },
    default_compat = true,
    rate = 0,

    loc_txt = {
        name="Yellow Bookmark",
        label = "Yellow Bookmark",
        text={
            "Gain {C:money}$4{} at",
            "end of round",
        },
    },

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            return { dollars = 4, func = function()
                G.E_MANAGER:add_event(Event({ func = function()
                        G.GAME.dollar_buffer = 0
                        return true
                    end
                })) end
            }
        end
    end,
    
    should_apply = global_bookmark_should_apply,
    apply = global_bookmark_apply,
	draw = global_bookmark_draw,
}

SMODS.Sticker {
    key = "bookmark_blue",
    badge_colour = HEX('387EB7'),
    atlas = 'twow_jokers',
    pos = { x = 6, y = 3 },
    default_compat = true,
    rate = 0,

    loc_txt = {
        name="Blue Bookmark",
        label = "Blue Bookmark",
        text={
            "Create a {C:spectral}Spectral{} card",
            "when this {C:attention}Joker{} sold",
            "{C:inactive}(Must have room)",
        },
    },

    loc_vars = function(self, info_queue, card) return { vars = { 5 } } end,

    calculate = function(self, card, context)
        if context.selling_self and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    SMODS.add_card({ set = 'Spectral' })
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))

            return {
                message = localize('k_plus_spectral'),
                colour = G.C.SECONDARY_SET.Spectral,
            }
        end
    end,
    
    should_apply = global_bookmark_should_apply,
    apply = global_bookmark_apply,
	draw = global_bookmark_draw,
}

SMODS.Sticker {
    key = "bookmark_orange",
    badge_colour = HEX('DD884B'),
    atlas = 'twow_jokers',
    pos = { x = 7, y = 3 },
    default_compat = true,
    rate = 0,

    loc_txt = {
        name="Orange Bookmark",
        label = "Orange Bookmark",
        text={
            "Gives a random {C:attention}Tag",
            "when {C:attention}Boss Blind{} defeated",
        },
    },

    loc_vars = function(self, info_queue, card) return { vars = { 5 } } end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.beat_boss and not context.repetition and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    local tag_pool = get_current_pool('Tag')
                    local selected_tag = pseudorandom_element(tag_pool, 'twow_orange')
                    local it = 1
                    while selected_tag == 'UNAVAILABLE' do
                        it = it + 1
                        selected_tag = pseudorandom_element(tag_pool, 'twow_orange_resample'..it)
                    end
                    add_tag(Tag(selected_tag, false, 'Small'))
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            })) 
        end
    end,
    
    should_apply = global_bookmark_should_apply,
    apply = global_bookmark_apply,
	draw = global_bookmark_draw,
}


-- Index Tag
SMODS.Tag {
    key = "indextag",
    min_ante = 2,
    atlas = 'twow_tags',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name="Index Tag",
        text={
            "Gives a free",
            "{C:twow_index}Catalog Pack",
        },
    },

    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_twow_index_jumbo_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local booster = SMODS.create_card { key = 'p_twow_index_jumbo_1', area = G.play }
                booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
                booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
                booster.T.w = G.CARD_W * 1.27
                booster.T.h = G.CARD_H * 1.27
                booster.cost = 0
                booster.from_tag = true
                G.FUNCS.use_card({ config = { ref_table = booster } })
                booster:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

--[[ Testing Tag
SMODS.Tag {
    key = "testing",
    pos = { x = 3, y = 4 },
    loc_txt = {
        name="Debug Tag",
        text={
            "For testing purposes"
        },
    },
    apply = function(self, tag, context)
        if context.type == 'store_joker_create' then
            local card = SMODS.create_card {
                set = "Joker",
                area = context.area,
                key = "j_twow_check_humany"
            }
            create_shop_card_ui(card, 'Joker', context.area)
            card.states.visible = false
            tag:yep('+', G.C.GREEN, function()
                card:start_materialize()
                card.ability.couponed = true
                card:set_cost()
                return true
            end)
            tag.triggered = true
            return card
        end
    end,
    in_pool = function(self, args)
        return false
    end
}
]]

----------------------------------------------
------------MOD CODE END----------------------