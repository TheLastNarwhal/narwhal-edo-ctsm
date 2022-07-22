--Custom card constants
CARD_LAWSTONES_ETERNAL_REALM  = 211000027

--Custom Tokens constants
TOKEN_ETERNAL_SHARD           = 211000020

--[[
    Effect.CreateEternalSPEffect(c,id,desc,uniquecat,uniquetg,uniqueop)

    Creates an Ignition Effect object for the "Eternal" effects that banish 1 other "Eternal" card from the hand or field.
    Includes handling for "CARD_LAWSTONES_ETERNAL_REALM" cost replacement.

    Card c: the owner of the Effect.
    int id: the card ID used for the HOPT restriction and strings.
    int desc: the string ID of the effect description (will also be used for the limitcount code.)
    int uniquecat: the category of the unique effect.
    function uniquetg: the target function for the effect.
    function uniqueop: the unique effect's operation function, excluding the Special Summoning procedure,
        the function must return true to proceed to the Special Summon,
        it can also return an optional passcode (int) which will be excluded from the Special Summon.
]]
Effect.CreateEternalSPEffect=(function()
    local stringbase=211000015 --use strings from "Ehir the Omen-Speaker Eternal"
    local function eternalcostfilter(c)
        return c:IsSetCard(0x200) and c:IsAbleToRemoveAsCost()
    end

    local function eternalcost(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then return Duel.IsExistingMatchingCard(eternalcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,eternalcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end

    function eternalspfilter(c,e,tp)
        return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:Iscode(id)
    end

    local function eternalop(uniqueop,e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and e:GetHandler():RegisterFlagEffect(e:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1) and Duel.SpecialSummon(e:GetHandler(),1,tp,tp,false,false,POS_FACEUP) then
            uniqueop(e,tp,eg,ep,ev,re,r,rp)
        end
    end

    return function(c,id,desc,uniquecat,uniquetg,uniqueop)
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,desc))
        e1:SetCategory(uniquecat|CATEGORY_SPECIAL_SUMMON)
        e1:SetType(EFFECT_TYPE_IGNITION)
        e1:SetRange(LOCATION_HAND)
        e1:SetCountLimit(1,{id,desc})
        e1:SetCost(aux.CostWithReplace(eternalcost,CARD_LAWSTONES_ETERNAL_REALM))
        e1:SetTarget(uniquetg)
        e1:SetOperation(function(...) eternalop(uniqueop,...) end)
        return e1
    end
end)()