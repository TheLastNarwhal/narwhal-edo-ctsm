--Ehir the Omen-Speaker Eternal
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If leaves field, look at top card of Deck, send to bottom or add to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetTarget(s.peektg)
    e2:SetOperation(s.peekop)
    c:RegisterEffect(e2)
    --Special Summon self and token
    c:RegisterEffect(Effect.CreateEternalSPEffect(c,id,0,CATEGORY_TOKEN,s.sptg,s.spop))
end
s.listed_series={0x200}
--Special Summon self and token
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x200,TYPES_TOKEN+TYPE_TUNER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x200,TYPES_TOKEN+TYPE_TUNER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        local token=Duel.CreateToken(tp,id+1)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        --Cannot Special Summon non-Synchro non-Fairy monsters from Extra Deck
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetAbsoluteRange(tp,1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY)) end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e1,true)
        --Lizard check
        local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not (c:IsOriginalType(TYPE_SYNCHRO) and c:IsOriginalRace(RACE_FAIRY)) end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e2,true)
        Duel.SpecialSummonComplete()
    end
end
--If leaves field, look at top card of Deck, send to bottom or add to hand
function s.peektg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function s.peekop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,1)
    Duel.ConfirmCards(tp,g)
    if not g:GetFirst():IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.MoveSequence(g:GetFirst(),1)
    else
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
    end
end