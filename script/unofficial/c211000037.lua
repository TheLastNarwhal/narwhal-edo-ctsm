--Danger Dungeon! Labyrinth!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    --Other "Danger Dungeon!" cards cannot be targeted
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(s.ntgtg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    --Add 1 "Danger Dungeon!" card from Deck to hand, Or send 1 "Danger Dungeon! Treasure!?" card from Deck to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.tutortg)
    e2:SetOperation(s.tutorop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_DANGER_DUNGEON_TREASURE,SET_DANGER_DUNGEON}
--Other "Danger Dungeon!" cards cannot be targeted
function s.ntgtg(e,c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c~=e:GetHandler()
end
--Add 1 "Danger Dungeon!" card from Deck to hand, Or send 1 "Danger Dungeon! Treasure!?" card from Deck to GY
function s.thfilter(c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsMonster() and c:IsAbleToHand()
end
function s.tgfilter(c)
    return c:IsSetCard(SET_DANGER_DUNGEON_TREASURE) and c:IsAbleToGrave()
end
function s.tdfilter(c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsAbleToDeck()
end
function s.tutortg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else op=Duel.SelectOption(tp,aux.Stringid(id,2))+1 end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
    elseif op==1 then
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    end
end
function s.tutorop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if e:GetLabel()==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g1>0 then
            Duel.SendtoHand(g1,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g1)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
            if #g2>0 and Duel.SendtoDeck(g2,nil,1,REASON_EFFECT)~=0 then
                Duel.ShuffleDeck(tp)
            end
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g1>0 then
            Duel.SendtoGrave(g1,REASON_EFFECT)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
            if #g2>0 and Duel.SendtoDeck(g2,nil,1,REASON_EFFECT)~=0 then
                Duel.ShuffleDeck(tp)
            end
        end
    end
end
