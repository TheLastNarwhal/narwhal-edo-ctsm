--Anu-Horakhty, the Endless Sands
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,99995601,99995602)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Can only control one
	c:SetUniqueOnField(1,0,id)
--destroy all other cards
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SPSUMMON_SUCCESS)
e1:SetCondition(s.descon)
e1:SetTarget(s.destg)
e1:SetOperation(s.desop)
c:RegisterEffect(e1)
--attack and defense increase
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e2:SetCode(EFFECT_UPDATE_ATTACK)
e2:SetRange(LOCATION_MZONE)
e2:SetValue(s.value)
c:RegisterEffect(e2)
local e3=e2:Clone()
e3:SetCode(EFFECT_UPDATE_DEFENSE)
c:RegisterEffect(e3)
end
--fusion material
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_MZONE) or aux.SpElimFilter(c,false,true))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
--destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return c:GetPreviousLocation()==LOCATION_EXTRA
	and c:IsPreviousLocation(LOCATION_EXTRA)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--attack and defense increase
function s.value(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE)*300
end
