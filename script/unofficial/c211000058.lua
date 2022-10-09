--Danger Dungeon! Treasure!? - Deck of Many Things
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Can only control 1 
    c:SetUniqueOnField(1,0,id)
    c:EnableCounterPermit(0xddc)
    --Activation: Roll d6, place counters on self equal to roll
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)
    --Remove 1 counter, roll a d20, effect based on result
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_COUNTER+CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.d20cost)
    e2:SetTarget(s.d20tg)
    e2:SetOperation(s.d20op)
    c:RegisterEffect(e2)
    --Send to GY when last counter is removed
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_REMOVE_COUNTER+0xddc)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.tgcon)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end
s.roll_dice=true
s.counter_place_list={0xddc}
--Activation: Roll d6, place counters on self equal to roll
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local d6=Duel.TossDice(tp,1)
    e:GetHandler():AddCounter(0xddc,d6)
end
--Remove 1 counter, roll a d20, effect based on result
function s.d20cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetHandler():GetCounter(0xddc)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xddc,1,REASON_COST) end
    e:GetHandler():RemoveCounter(tp,0xddc,1,REASON_COST)
    if e:GetHandler():GetCounter(0xddc)<ct then
        Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0xddc,e,REASON_EFFECT,tp,tp,1)
    end
end
function s.d20tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,nil)
    local g2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
    local dam=g2:FilterCount(Card.IsAbleToGrave,nil,1-tp)
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,LOCATION_ONFIELD)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,g2,#g2,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dam*300)
end
--Filter for roll of 16-19
function s.spfilter(c)
    return c:IsMonster()
end
--Filter for roll of 20
function s.sgfilter(c,p)
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
function s.d20op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local d20=Duel.GetRandomNumber(1,20)
    Debug.Message("Your d20 roll is "..tostring(d20)..".")
    --On roll of 1: Banish all cards on your field face-down, then end turn
    if d20==1 then
        local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,nil)
        if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)==0 then return end
        Duel.BreakEffect()
        Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
        Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_BP)
        e1:SetTargetRange(0,1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    --On roll of 2-7: Add card from your GY to hand
    elseif d20>=2 and d20<=7 then
        local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g1>0 then
            Duel.SendtoHand(g1,tp,REASON_EFFECT)
        end
    --On roll of 8-15: Each player discards 1, then draws 1
    elseif d20>=8 and d20<=15 then
        local d1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
        local d2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
        if d1<1 or d2<1 or not Duel.IsPlayerCanDraw(tp,1) or not Duel.IsPlayerCanDraw(1-tp,1) then return end
        local h1=Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
        local h2=Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
        if h1>0 or h2>0 then Duel.BreakEffect() end
        if h1>0 then
            Duel.Draw(tp,1,REASON_EFFECT)
            Duel.ShuffleHand(tp)
        end
        if h2>0 then
            Duel.Draw(1-tp,1,REASON_EFFECT)
            Duel.ShuffleHand(1-tp)
        end
    --On roll of 16-19: Draw 2, then can Special Summon 1 drawn monster, ignoring Summoning conditions
    elseif d20>=16 and d20<=19 then
        if Duel.IsPlayerCanDraw(tp,2) then
            Duel.Draw(tp,2,REASON_EFFECT)
            local tc=Duel.GetOperatedGroup()
            if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or tc:FilterCount(s.spfilter,nil)==0 then return end
            if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                local sp=tc:FilterSelect(tp,s.spfilter,1,1,nil)
                if Duel.ConfirmCards(1-tp,sp)~=0 then
                    Duel.SpecialSummon(sp,0,tp,tp,true,false,POS_FACEUP)
                end
            end
        end
    --On roll of 20: Send all cards your opponent controls and in their hand to GY, then inflict 300 damage for each sent card
    elseif d20==20 then
        local gy=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
        if #gy>0 then
            Duel.SendtoGrave(gy,REASON_EFFECT)
            local og=Duel.GetOperatedGroup()
            local dam=og:FilterCount(s.sgfilter,nil,1-tp)
            if dam>0 then
                Duel.BreakEffect()
                Duel.Damage(1-tp,dam*300,REASON_EFFECT)
            end
        end
    end
end
--Send to GY when last counter is removed
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0xddc)==0
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
