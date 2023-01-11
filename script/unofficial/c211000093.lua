--Yuki-Onna Neverspring
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Shuffle 3 "Yuki-Onna" monsters from GY into Deck, draw 2
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)
    --Add 1 "Yuki-Onna" monster from Deck to hand with different name than cards controlled
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_YUKI_ONNA}
--Shuffle 3 "Yuki-Onna" monsters from GY into Deck, draw 2
function s.tdfilter(c)
    return c:IsSetCard(SET_YUKI_ONNA) and c:IsMonster() and c:IsAbleToDeck()
end
--Filter for the Defense Position "Yuki-Onna" monster
function s.posfilter(c)
    return c:IsFaceup() and c:IsDefensePos() and c:IsSetCard(SET_YUKI_ONNA)
end
--Filter for "Yuki-Onna" Normal Summon
function s.sumfilter(c)
    return c:IsSetCard(SET_YUKI_ONNA) and c:IsSummonable(true,nil)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local sum=0
    if Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) then sum=1
    end
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    if sum==1 then
        Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
        Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
        e:SetLabel(1)
    else
        Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
        e:SetLabel(0)
    end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local sum=e:GetLabel()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
    Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
    local g=Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp)
    end
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
    if ct==3 then
        Duel.BreakEffect()
        Duel.Draw(tp,2,REASON_EFFECT)
        if sum==1 and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
            if #g>0 then
                Duel.Summon(tp,g:GetFirst(),true,nil)
            end
        end
    end
end
--Add 1 "Yuki-Onna" monster from Deck to hand with different name than cards controlled
function s.thfilter(c,tp)
    return c:IsMonster() and c:IsSetCard(SET_YUKI_ONNA) and c:IsAbleToHand() and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end