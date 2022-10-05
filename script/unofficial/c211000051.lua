--Danger Dungeon! Alarm!? - Reinforcements
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon 2 "Danger Dungeon!" monsters from Deck, but shuffle into Deck during End Phase, also cannot Special Summon, except "Danger Dungeon!" monsters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spdcon)
    e1:SetTarget(s.spdtg)
    e1:SetOperation(s.spdop)
    c:RegisterEffect(e1)
    --Banish self from GY to Special Summon 1 "Danger Dungeon!" monster from hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sphtg)
    e2:SetOperation(s.sphop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_DANGER_DUNGEON}
--Special Summon 2 "Danger Dungeon!" monsters from Deck, but shuffle into Deck during End Phase, also cannot Special Summon, except "Danger Dungeon!" monsters
function s.cfilter(c)
    return c:IsFacedown() or not c:IsSetCard(SET_DANGER_DUNGEON)
end
function s.spdcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spdfilter(c,e,tp)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetMZoneCount(tp,c)>1 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,c) and Duel.IsExistingMatchingCard(s.spdfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.spdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsExistingMatchingCard(s.spdfilter,tp,LOCATION_DECK,0,2,nil,e,tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spdfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
        if #sg>1 then
            local fid=c:GetFieldID()
            local tc=sg:GetFirst()
            for tc in sg:Iter() do
                Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(aux.Stringid(id,0))
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
            Duel.SpecialSummonComplete()
            sg:KeepAlive()
            --Return to Deck during EP
            local e1=Effect.CreateEffect(c)
            e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            e1:SetCategory(CATEGORY_TODECK)
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetLabel(fid)
            e1:SetLabelObject(sg)
            e1:SetCondition(s.rtdcon)
            e1:SetOperation(s.rtdop)
            Duel.RegisterEffect(e1,tp)
        end
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetTarget(s.splimit)
            e1:SetTargetRange(1,0)
            Duel.RegisterEffect(e1,tp)
            --Lizard Check
            aux.addTempLizardCheck(c,tp,s.lizfilter)
        end
    end
end
function s.rtdfilter(c,fid)
    return c:GetFlagEffectLabel(id)==fid
end
function s.rtdcon(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g:IsExists(s.rtdfilter,1,nil,e:GetLabel()) then
        g:DeleteGroup()
        e:Reset()
        return false
    else return true end
end
function s.rtdop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    local tg=g:Filter(s.rtdfilter,nil,e:GetLabel())
    Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.splimit(e,c)
    return not c:IsSetCard(SET_DANGER_DUNGEON)
end
function s.lizfilter(e,c)
    return not c:IsOriginalSetCard(SET_DANGER_DUNGEON)
end
--Banish self from GY to Special Summon 1 "Danger Dungeon!" monster from hand
function s.sphfilter(c,e,tp)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sphtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sphfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.sphop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sphfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end