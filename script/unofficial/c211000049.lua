--Danger Dungeon! Treasure!? - Chest of Gold
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Can only control 1 
    c:SetUniqueOnField(1,0,id)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(0,TIMING_END_PHASE)
    e0:SetTarget(s.target)
    c:RegisterEffect(e0)
    --Opponent cannot activate Spells/Traps when your "Danger Dungeon!" monster attacks
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.aclimit)
    e1:SetCondition(s.actcon)
    c:RegisterEffect(e1)
    --If your Aqua monster battles an opponent's monster, you can pay LP in multiples of 100 (max. 2000) it gains that much ATK/DEF for that battle only
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.batlcon)
    e2:SetCost(s.batlcost)
    e2:SetOperation(s.batlop)
    c:RegisterEffect(e2)
    --Banish self from GY to Special Summon 1 "Danger Dungeon!" monster from GY, then gain LP equal to its ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetHintTiming(0,TIMING_END_PHASE)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_DANGER_DUNGEON}
--Activate - Destroy on 3rd End Phase
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    --Destroy
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.descon)
    e1:SetOperation(s.desop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
    c:SetTurnCounter(0)
    c:RegisterEffect(e1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetTurnCounter()
    ct=ct+1
    c:SetTurnCounter(ct)
    if ct==3 then
        Duel.Destroy(c,REASON_EFFECT)
    end
end
--Opponent cannot activate Spells/Traps when your "Danger Dungeon!" monster attacks
function s.aclimit(e,re,tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.cfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(SET_DANGER_DUNGEON) and c:IsControler(tp)
end
function s.actcon(e)
    local tp=e:GetHandlerPlayer()
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return (a and s.cfilter(a,tp)) or (d and s.cfilter(d,tp))
end
--If your Aqua monster battles an opponent's monster, you can pay LP in multiples of 100 (max. 2000) it gains that much ATK/DEF for that battle only
function s.batlcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetAttackTarget()~=nil then
        return (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsRace(RACE_AQUA)) or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsRace(RACE_AQUA))
    end
end
function s.batlcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.CheckLPCost(tp,100) end
    local lp=Duel.GetLP(tp)
    local m=math.floor(math.min(lp,2000)/100)
    local t={}
    for i=1,m do
        t[i]=i*100
    end
    local ac=Duel.AnnounceNumber(tp,table.unpack(t))
    Duel.PayLPCost(tp,ac)
    e:SetLabel(ac)
    e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.batlop(e,tp,eg,ep,ev,re,r,rp)
    local c=Duel.GetAttacker()
    if c:IsControler(1-tp) then c=Duel.GetAttackTarget() end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
    e1:SetValue(e:GetLabel())
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)
end
--Banish self from GY to Special Summon 1 "Danger Dungeon!" monster from GY, then gain LP equal to its ATK
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
        end
    end
end