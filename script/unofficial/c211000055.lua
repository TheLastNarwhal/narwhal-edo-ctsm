--Danger Dungeon! The Overslime!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Summon
    Fusion.AddProcMixRep(c,false,false,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DANGER_DUNGEON),2,99)
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
    --Gains ATK equal to amount of materials used for Fusion Summon * 1000
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_MATERIAL_CHECK)
    e2:SetValue(s.matcheck)
    e2:SetLabelObject(e1)
    c:RegisterEffect(e2)
    --Negate, then equip
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_NEGATE+CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
    aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e3)
    --Destroy replace
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
    --Searches for "Danger Dungeon!" monster activation in GY
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={SET_DANGER_DUNGEON}
--Searches for "Danger Dungeon!" monster activation in hand
function s.chainfilter(re,tp,cid)
    return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(SET_DANGER_DUNGEON) and (Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE))
end
--Alternative Special Summon procedure
function s.spfilter(c)
    return c:IsSetCard(SET_DANGER_DUNGEON) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.rescon(sg,e,tp,mg)
    return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0 
        and sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
        and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK)
end
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,tp)
    local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,tp)
    local g=g1:Clone()
    g:Merge(g2)
    return #g1>0 and #g2>0 and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0) and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
    if #sg > 0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    else
        return false
    end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    c:SetMaterial(sg)
    sg:DeleteGroup()
end
--Gains ATK equal to amount of materials used for Fusion Summon * 1000
function s.matcheck(e,c)
    e:GetLabelObject():SetLabel(c:GetMaterialCount())
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=e:GetLabel()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK)
    e1:SetValue(ct*1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE)
    c:RegisterEffect(e2)
end
--Negate, then equip
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp and Duel.IsChainNegatable(ev)
end
function s.cfilter(c,tp)
    return c:IsMonster() and c:IsSetCard(SET_DANGER_DUNGEON) and c:IsAbleToRemoveAsCost() and c:IsLocation(LOCATION_GRAVE)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    --if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,eg,1,0,0)
    end
end
function s.eqval(ec,c,tp)
    return ec:IsControler(1-tp)
end
function s.equipop(c,e,tp,rc)
    c:EquipByEffectAndLimitRegister(e,tp,rc,id)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and rc:IsRelateToEffect(re) then
        rc:CancelToGrave()
        --[[doesn't work with non-monsters, so... did the funny of using Overlay and I think it's more fitting
        --
        s.equipop(c,e,tp,rc)]]
        Duel.Overlay(c,rc)
    end
end
--Destroy replace
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end