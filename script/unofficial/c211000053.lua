--Danger Dungeon! Elder Oblex!?
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Cannot be Special Summoned, except by own effect
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)
    --Special Summon by banishing 3 "Danger Dungeon!" monsters, 1 each from your hand, field, GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Shuffle 1 of your banished "Danger Dungeon!" monsters into the Deck, copy that monster's name/effects until EP
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.copycost)
    e2:SetOperation(s.copyop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_DANGER_DUNGEON}
--Special Summon by banishing 3 "Danger Dungeon!" monsters, 1 each from your hand, field, GY
function s.spfilter(c,tp)
    return c:IsMonster() and c:IsSetCard(SET_DANGER_DUNGEON) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.rescon(sg,e,tp)
    return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0 
        and sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) 
        and sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) 
        and sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,tp)
    local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil,tp)
    local g3=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,tp)
    local g=g1:Clone()
    g:Merge(g2)
    g:Merge(g3)
    return #g1>0 and #g2>0 and #g3>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,tp)
    local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil,tp)
    local g3=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,tp)
    local rg=g1:Clone()
    rg:Merge(g2)
    rg:Merge(g3)
    local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
    if #g>0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    --Gains ATK and DEF equal to the combined ATK and DEF of the banished monsters, respectively
    local atk=g:GetSum(Card.GetAttack)
    local def=g:GetSum(Card.GetDefense)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
    e:GetHandler():RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(def)
    e:GetHandler():RegisterEffect(e2)
    g:DeleteGroup()
end
--Shuffle 1 of your banished "Danger Dungeon!" monsters into the Deck, copy that monster's name/effects until EP
function s.ddfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DANGER_DUNGEON) and c:IsMonster() and c:IsAbleToDeck()
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.ddfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    local g=Duel.SelectMatchingCard(tp,s.ddfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler())
    e:SetLabelObject(g:GetFirst())
    Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=e:GetLabelObject()
    local code=e:GetLabelObject():GetOriginalCodeRule()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
    e:SetLabelObject(nil)
end