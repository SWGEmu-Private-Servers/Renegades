
/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions. */

#ifndef FORCERUN3COMMAND_H_
#define FORCERUN3COMMAND_H_

#include "server/zone/objects/creature/buffs/PrivateSkillMultiplierBuff.h"
#include "JediQueueCommand.h"

class ForceRun3Command : public JediQueueCommand {
public:

	ForceRun3Command(const String& name, ZoneProcessServer* server)
	: JediQueueCommand(name, server) {
		// BuffCRC's, first one is used.
		buffCRC = BuffCRC::JEDI_FORCE_RUN_3;

        // If these are active they will block buff use
		blockingCRCs.add(BuffCRC::JEDI_FORCE_RUN_1);
		blockingCRCs.add(BuffCRC::JEDI_FORCE_RUN_2);

		skillMods.put("force_run", 3);
		skillMods.put("slope_move", 99);
	}

	int doQueueCommand(CreatureObject* creature, const uint64& target, const UnicodeString& arguments) const {
		if (creature->hasBuff(BuffCRC::JEDI_FORCE_RUN_3)) // Allow removal of buff on second click
		{
			Buff* frBuff = creature->getBuff(BuffCRC::JEDI_FORCE_RUN_3);
			Locker frlocker(frBuff);
			creature->removeBuff(frBuff);

			Buff* mtBuff = creature->getBuff(name.hashCode());
			Locker mtlocker(mtBuff);
			creature->removeBuff(mtBuff);

			creature->updateCooldownTimer("forcerun", 5000); // 5 second re-use
			return -1;
		}

		if (!creature->checkCooldownRecovery("forcerun"))
		{
			creature->sendSystemMessage("You must wait before you can use that ability again.");
			return -1;
		}

		int res = creature->hasBuff(buffCRC) ? NOSTACKJEDIBUFF : doJediSelfBuffCommand(creature);

		if (res == NOSTACKJEDIBUFF) {
			creature->sendSystemMessage("@jedi_spam:already_force_running"); // You are already force running.
			return GENERALERROR;
		}

		if (res != SUCCESS) {
			return res;
		}

		// need to apply the damage reduction in a separate buff so that the multiplication and division applies right
		Buff* buff = creature->getBuff(BuffCRC::JEDI_FORCE_RUN_3);
		if (buff == nullptr)
			return GENERALERROR;

		ManagedReference<PrivateSkillMultiplierBuff*> multBuff = new PrivateSkillMultiplierBuff(creature, name.hashCode(), duration, BuffType::JEDI);

		Locker locker(multBuff);

		multBuff->setSkillModifier("private_damage_divisor", 20);

		creature->updateCooldownTimer("forcerun", (duration + 3) * 1000);

		creature->addBuff(multBuff);

		locker.release();

		Locker blocker(buff);

		buff->addSecondaryBuffCRC(multBuff->getBuffCRC());

		if (creature->hasBuff(STRING_HASHCODE("burstrun")) || creature->hasBuff(STRING_HASHCODE("retreat"))) {
			creature->removeBuff(STRING_HASHCODE("burstrun"));
			creature->removeBuff(STRING_HASHCODE("retreat"));
		}

		return SUCCESS;
	}

};

#endif //FORCERUN3COMMAND_H_
