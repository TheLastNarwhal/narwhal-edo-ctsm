--Sigil of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --When activated/placed in the Spell & Trap Zone, target 1 player, banish their hand, then they draw same amount of cards
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.bandrwtg)
    e1:SetOperation(s.bandrwop)
    e1:SetHintTiming(TIMING_STANDBY_PHASE+TIMING_END_PHASE)
    c:RegisterEffect(e1)
    --ETB version of above effect
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_MOVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.etbcon)
    c:RegisterEffect(e2)
    --If this card is sent to the GY, return banished cards
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCondition(s.retcon)
    e3:SetOperation(s.retop)
    e3:SetLabelObject({e1,e2})
    c:RegisterEffect(e3)
end
--When activated/placed in the Spell & Trap Zone, target 1 player, banish their hand, then they draw same amount of cards
function s.bandrwtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local you=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
    local opp=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
    local op=-1
    if (you or opp) then
        if you and opp then
            op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        elseif you then
            op=0
        else op=1
        end
        if op==0 then
            local yg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            local ygc=#yg
            if chk==0 then return ygc>0 and yg:FilterCount(Card.IsAbleToRemove,nil)==ygc and Duel.IsPlayerCanDraw(tp,ygc) end
            Duel.SetOperationInfo(0,CATEGORY_REMOVE,yg,ygc,0,0)
            Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ygc)
            e:SetLabel(1)
        else
            local og=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
            local ogc=#og
            if chk==0 then return ogc>0 and og:FilterCount(Card.IsAbleToRemove,nil)==ogc and Duel.IsPlayerCanDraw(1-tp,ogc) end
            Duel.SetOperationInfo(0,CATEGORY_REMOVE,og,ogc,0,0)
            Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ogc)
            e:SetLabel(2)
        end
    end
end
function s.bandrwop(e,tp,eg,ep,ev,re,r,rp)
    local player=e:GetLabel()
    if player==1 then
        local yg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        local ygc=#yg
        if ygc and yg:FilterCount(Card.IsAbleToRemove,nil)==ygc then
            local ybc=Duel.Remove(yg,POS_FACEDOWN,REASON_EFFECT)
            if ybc>0 then
                local tc=yg
                for tc in yg:Iter() do
                    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
                end
                Duel.Draw(tp,ybc,REASON_EFFECT)
            end
        end
    elseif player==2 then
        local og=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
        local ogc=#og
        if ogc and og:FilterCount(Card.IsAbleToRemove,nil)==ogc then
            local obc=Duel.Remove(og,POS_FACEDOWN,REASON_EFFECT)
            if obc>0 then
                local tc=og
                for tc in og:Iter() do
                    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
                end
                Duel.Draw(1-tp,obc,REASON_EFFECT)
            end
        end
    end
end
--ETB version of above effect
function s.etbcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_SZONE) and c:IsLocation(LOCATION_SZONE)
end
--If this card is sent to the GY, return banished cards
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE)
end
function s.filter(c,e)
    local e1,e2=table.unpack(e:GetLabelObject())
    local re=c:GetReasonEffect()
    return c:GetFlagEffect(id) and (re==e1 or re==e2)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local rcg=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED):Match(s.filter,nil,e)
    Duel.SendtoHand(rcg,nil,REASON_EFFECT)
end


