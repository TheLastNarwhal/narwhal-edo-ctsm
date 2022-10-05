--Danger Dungeon! Alarm!? - Intruders
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Excavate equal to the number of "Danger Dungeon!" monster controlled +5, Special Summon 1 monster to field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_DANGER_DUNGEON}
--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_DANGER_DUNGEON),tp,LOCATION_MZONE,0,nil)+5
        if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<ct or not (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 or Duel.IsPlayerCanSpecialSummon(tp)) then return false end
        local g=Duel.GetDecktopGroup(1-tp,ct)
        return g:FilterCount(Card.IsSummonableCard,nil)>0
    end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,lv)
    return c:IsMonster() and c:IsLevelBelow(lv) and c:IsSummonableCard()
end
--Excavate equal to the number of "Danger Dungeon!" monster controlled +5, Special Summon 1 monster to field
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_DANGER_DUNGEON),tp,LOCATION_MZONE,0,nil)+5
    if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<ct then return end
    Duel.ConfirmDecktop(1-tp,ct)
    local g=Duel.GetDecktopGroup(1-tp,ct)
    local dc=g:Filter(s.spfilter,nil,ct)
    if #dc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.DisableShuffleCheck()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=dc:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP)
    end
    Duel.ShuffleDeck(1-tp)
    --Cannot Special Summon monsters, except "Danger Dungeon!" monsters, for rest of the turn
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
--Locked into "Danger Dungeon!" monsters
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(SET_DANGER_DUNGEON)
end

