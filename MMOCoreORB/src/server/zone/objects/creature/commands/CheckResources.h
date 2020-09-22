#ifndef CHECKRESOURCESCOMMAND_H_
#define CHECKRESOURCESCOMMAND_H_

#include "server/zone/objects/scene/SceneObject.h"
#include "server/zone/objects/player/sui/callbacks/ResourceListSuiCallback.h"

class CheckResourcesCommand : public QueueCommand
{
	public:
	CheckResourcesCommand(const String& name, ZoneProcessServer* server) : QueueCommand(name, server) { }

	int doQueueCommand(CreatureObject* creature, const uint64& target, const UnicodeString& arguments) const
	{
		if (!creature->isPlayerCreature()) return GENERALERROR;

		ManagedReference<PlayerObject*> ghost = creature->getPlayerObject();

		if (ghost == nullptr || ghost->hasSuiBoxWindowType(SuiWindowType::FREE_RESOURCE))
		{
			ghost->removeSuiBoxType(SuiWindowType::FREE_RESOURCE);
			return 0;
		}

		ManagedReference<ResourceManager*> resourceManager = server->getZoneServer()->getResourceManager();
		ManagedReference<SuiListBox*> sui = new SuiListBox(creature, SuiWindowType::FREE_RESOURCE);
		sui->setCallback(new ResourceListSuiCallback(server->getZoneServer(), "Resource"));
		sui->setPromptTitle("Resource List");
		sui->setPromptText("Select a type:");
		sui->setOtherButton(true, "@back");
		sui->setCancelButton(true, "@cancel");
		sui->setOkButton(true, "@ok");

		resourceManager->addNodeToListBox(sui, "resource");

		ghost->addSuiBox(sui);
		creature->sendMessage(sui->generateMessage());

		return SUCCESS;
	}
};

#endif //CHECKRESOURCESCOMMAND_H_
