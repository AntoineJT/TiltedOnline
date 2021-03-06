#if TP_FALLOUT4

#include <Games/Fallout4/PlayerCharacter.h>
#include <Games/Memory.h>
#include <Games/Overrides.h>

TP_THIS_FUNCTION(TActorConstructor, Actor*, Actor, uint8_t aUnk);
TP_THIS_FUNCTION(TActorConstructor2, Actor*, Actor, volatile int** aRefCount, uint8_t aUnk);

TActorConstructor* RealActorConstructor;
TActorConstructor2* RealActorConstructor2;

Actor* TP_MAKE_THISCALL(HookActorContructor, Actor, uint8_t aUnk)
{
    TP_EMPTY_HOOK_PLACEHOLDER;

    const auto pActor = ThisCall(RealActorConstructor, apThis, aUnk);

    return pActor;
}

Actor* TP_MAKE_THISCALL(HookActorContructor2, Actor, volatile int** aRefCount, uint8_t aUnk)
{
    TP_EMPTY_HOOK_PLACEHOLDER;

    const auto pActor = ThisCall(RealActorConstructor2, apThis, aRefCount, aUnk);

    return pActor;
}

GamePtr<Actor> Actor::New() noexcept
{
    const auto pActor = Memory::Allocate<Actor>();

    ThisCall(HookActorContructor, pActor, uint8_t(1));

    return pActor;
}

TESForm* Actor::GetEquippedWeapon(uint32_t aSlotId) const noexcept
{
    using TGetEquippedWeapon = TESForm* (__fastcall)(void*, void*, const Actor*, uint32_t);
    
    POINTER_FALLOUT4(TGetEquippedWeapon, s_getEquippedWeapon, 0x141388BC0 - 0x140000000);

    return s_getEquippedWeapon(nullptr, nullptr, this, aSlotId);
}

void Actor::UnEquipAll() noexcept
{
    TP_THIS_FUNCTION(TUnEquipAll, void, Actor);

    POINTER_FALLOUT4(TUnEquipAll, s_unequipAll, 0x140D8E370 - 0x140000000);

    ThisCall(s_unequipAll, this);
}


Inventory Actor::GetInventory() const noexcept
{
    auto& modSystem = World::Get().GetModSystem();

    Inventory inventory;
    inventory.Buffer = SerializeInventory();

    auto pMainHandWeapon = GetEquippedWeapon(0);
    uint32_t mainId = pMainHandWeapon ? pMainHandWeapon->formID : 0;
    modSystem.GetServerModId(mainId, inventory.LeftHandWeapon);

    return inventory;
}

void Actor::SetInventory(const Inventory& acInventory) noexcept
{
    UnEquipAll();

    if(!acInventory.Buffer.empty())
        DeserializeInventory(acInventory.Buffer);
}

static TiltedPhoques::Initializer s_specificReferencesHooks([]()
    {
        POINTER_FALLOUT4(TActorConstructor, s_actorCtor, 0x140D6E9A0 - 0x140000000);
        POINTER_FALLOUT4(TActorConstructor2, s_actorCtor2, 0x140D6ED80 - 0x140000000);

        RealActorConstructor = s_actorCtor.Get();
        RealActorConstructor2 = s_actorCtor2.Get();

        TP_HOOK(&RealActorConstructor, HookActorContructor);
        TP_HOOK(&RealActorConstructor2, HookActorContructor2);
    });

#endif
