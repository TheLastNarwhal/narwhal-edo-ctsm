--Danger Dungeon! The Mimeoplasm!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Summon procedure
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.matfilter,1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),2)
    --Fusion Summon only
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.fuslimit)
    c:RegisterEffect(e1)
    --On Fusion Summon: if used materials with different names, can change the ATK of all monsters opponent controls to 0
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_MATERIAL_CHECK)
    e3:SetValue(s.valcheck)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
    --On Fusion Summon: Banish 3 monsters, 1 from the field, 2 from the GY(s), except self, then gain effects of 1 and ATK/DEF of other 2
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.sumeffcon)
    e4:SetTarget(s.sumefftg)
    e4:SetOperation(s.sumeffop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_DANGER_DUNGEON}
function s.matfilter(c,fc,sumtype,tp)
    return c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsSetCard(SET_DANGER_DUNGEON,fc,sumtype,tp)
end
--Material check for all different names
function s.valcheck(e,c)
    local g=c:GetMaterial()
    if g:GetClassCount(Card.GetCode)==3 then e:GetLabelObject():SetLabel(1) end
end
--On Fusion Summon, if used materials with different names, can change the ATK of all monsters opponent controls to 0
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
--On Fusion Summon: Banish 3 monsters, 1 from the field, 2 from the GY(s), except self, then gain effects of 1 and ATK/DEF of other 2
function s.rmvfilter(c)
    return c:IsMonster() and c:IsAbleToRemove() and not c:IsCode(id) and aux.SpElimFilter(c,true,true)
end
function s.sumeffcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,e:GetHandler():IsCode(id)) and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil,tp,e:GetHandler():IsCode(id))
end
function s.sumefftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():IsCode(id)) and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil,e:GetHandler():IsCode(id)) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    local g2=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
    local rg=g1:Clone()
    rg:Merge(g2)
    rg:KeepAlive()
    e:SetLabelObject(rg)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end
function s.sumeffop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=e:GetLabelObject()
    if not g then return end
    if Duel.Remove(g,POS_FACEUP,REASON_COST)~=0 then
        --Gains the effects of 1 of the banished monsters
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
        local sg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_EFFECT)
        local code=sg:GetFirst():GetOriginalCodeRule()
        c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD)
        g:Sub(sg)
        --Gains ATK and DEF equal to the combined ATK and DEF of the banished monsters, respectively
        local atk=g:GetSum(Card.GetAttack)
        local def=g:GetSum(Card.GetDefense)
        local val=atk+def
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)
    end
end