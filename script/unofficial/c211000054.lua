--Danger Dungeon! The Oozolith!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Summon
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DANGER_DUNGEON),aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA))
    c:EnableCounterPermit(COUNTER_ABSORB)
    --Alternative Special Summon procedure
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.hspcon)
    e0:SetTarget(s.hsptg)
    e0:SetOperation(s.hspop)
    c:RegisterEffect(e0)
    --If another card is destroyed by battle or card effect, place 1 Absorb Counter on this card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetRange(LOCATION_ONFIELD)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCondition(s.ctcon)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)
    --Place in the Spell/Trap Zone
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spellcon)
    e2:SetTarget(s.spelltg)
    e2:SetOperation(s.spellop)
    c:RegisterEffect(e2)
    --Special Summon from Spell/Trap Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    --While self is a Continuous Spell, other monsters you control gain 300 ATK for each Absorb Counter
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetCondition(s.atkfieldcon)
    e4:SetValue(s.aktfieldval)
    c:RegisterEffect(e4)
    --While self is a Monster gains 300 ATK for each Absorb Counter
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetValue(s.aktfieldval)
    c:RegisterEffect(e5)
    --Destruction Replacement
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e6:SetTarget(s.desreptg)
	e6:SetOperation(s.desrepop)
	c:RegisterEffect(e6)
    --Searches for "Danger Dungeon!" monster activation in hand
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={SET_DANGER_DUNGEON}
s.counter_place_list={COUNTER_ABSORB}
--Searches for "Danger Dungeon!" monster activation in hand
function s.chainfilter(re,tp,cid)
    return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(SET_DANGER_DUNGEON) and (Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND))
end
--Alternative Special Summon procedure
function s.hspfilter(c,tp,sc)
    return c:IsSetCard(SET_DANGER_DUNGEON) and not c:IsType(TYPE_FUSION,sc,MATERIAL_FUSION,tp) and c:IsType(TYPE_EFFECT,sc,MATERIAL_FUSION,tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.CheckReleaseGroup(c:GetControler(),s.hspfilter,1,false,1,true,c,c:GetControler(),nil,false,nil,tp,c) and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,nil,nil,false,nil,tp,c)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    else
        return false
    end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    Duel.Release(g,REASON_COST+REASON_MATERIAL)
    c:SetMaterial(g)
    g:DeleteGroup()
end
--If another card is destroyed by battle or card effect, place 1 Absorb Counter on this card
function s.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    ct=eg:FilterCount(s.ctfilter,nil)
	e:GetHandler():AddCounter(COUNTER_ABSORB,ct)
end
--Place in the Spell/Trap Zone
function s.spellcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)==0
end
function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) end
    local dc=Duel.GetFieldCard(tp,LOCATION_SZONE,c:GetSequence())
    if dc then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,dc,1,0,0)
    end
end
function s.spellop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetCounter(COUNTER_ABSORB)
    if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end
    local seq=c:GetSequence()
    local dc=Duel.GetFieldCard(tp,LOCATION_SZONE,seq)
    if dc then 
        Duel.Destroy(dc,REASON_RULE)
    end
    e:SetLabel(ct)
    if Duel.CheckLocation(tp,LOCATION_SZONE,seq) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true,1<<seq) then
        --Treat as Continuous Spell
        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
        c:RegisterEffect(e1)
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
    end
    Duel.BreakEffect()
    if ct==0 then return end
    c:AddCounter(COUNTER_ABSORB,ct)
    e:SetLabel(0)
end
--Special Summon from Spell/Trap Zone
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsFaceup() and c:IsLocation(LOCATION_SZONE) end
    local dc=Duel.GetFieldCard(tp,LOCATION_MZONE,c:GetSequence())
    if dc then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,dc,1,0,0)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local ct=c:GetCounter(COUNTER_ABSORB)
	if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_SZONE) then return end
    local seq=c:GetSequence()
    local dc=Duel.GetFieldCard(tp,LOCATION_MZONE,seq)
    if dc then 
        Duel.Destroy(dc,REASON_RULE)
    end
    e:SetLabel(ct)
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,1<<seq)
    Duel.BreakEffect()
    if ct==0 then return end
    c:AddCounter(COUNTER_ABSORB,ct)
    e:SetLabel(0)
end
--While self is a Continuous Spell, other monsters you control gain 300 ATK for each Absorb Counter
function s.atkfieldcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0
end
--Value for updating ATK
function s.aktfieldval(e,c)
    return e:GetHandler():GetCounter(COUNTER_ABSORB)*300
end
--Destruction Replacement
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsReason(REASON_RULE) and e:GetHandler():GetCounter(COUNTER_ABSORB)>0 end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RemoveCounter(ep,COUNTER_ABSORB,3,REASON_EFFECT)
end