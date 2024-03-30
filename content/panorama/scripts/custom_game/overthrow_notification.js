"use strict";
// Notifications for Overthrow

function OnItemWillSpawn(msg) {
	//	$.Msg( "OnItemWillSpawn: ", msg );
	$.GetContextPanel().SetHasClass("item_will_spawn", true);
	$.GetContextPanel().SetHasClass("item_has_spawned", false);
	GameUI.PingMinimapAtLocation(msg.spawn_location);
	$("#AlertMessage_Chest").html = true;
	$("#AlertMessage_Delivery").html = true;
	$("#AlertMessage_Chest").text = $.Localize("#Chest");
	$("#AlertMessage_Delivery").text = $.Localize("#ItemWillSpawn");

	$.Schedule(3, ClearItemSpawnMessage);
}

function OnItemHasSpawned(msg) {
	//	$.Msg( "OnItemHasSpawned: ", msg );
	$.GetContextPanel().SetHasClass("item_will_spawn", false);
	$.GetContextPanel().SetHasClass("item_has_spawned", true);
	GameUI.PingMinimapAtLocation(msg.spawn_location);
	$("#AlertMessage_Chest").html = true;
	$("#AlertMessage_Delivery").html = true;
	$("#AlertMessage_Chest").text = $.Localize("#Chest");
	$("#AlertMessage_Delivery").text = $.Localize("#ItemHasSpawned");

	$.Schedule(3, ClearItemSpawnMessage);
}

function ClearItemSpawnMessage() {
	$.GetContextPanel().SetHasClass("item_will_spawn", false);
	$.GetContextPanel().SetHasClass("item_has_spawned", false);
	$("#AlertMessage").text = "";
}

//==============================================================
//==============================================================
function OnItemDrop(msg) {
	//	$.Msg( "recent_item_drop: ", msg );
	//	$.Msg( msg.hero_id )
	$.GetContextPanel().SetHasClass("recent_item_drop", true);

	$("#PickupMessage_Hero_Text").SetDialogVariable("hero_id", $.Localize("#" + msg.hero_id));
	$("#PickupMessage_Item_Text").SetDialogVariable("item_id", $.Localize("#DOTA_Tooltip_Ability_" + msg.dropped_item));

	var hero_image_name = "file://{images}/heroes/" + msg.hero_id + ".png";
	$("#PickupMessage_Hero").SetImage(hero_image_name);

	var chest_image_name = "file://{images}/econ/tools/gift_lockless_luckbox.png";
	$("#PickupMessage_Chest").SetImage(chest_image_name);

	var item_image_name = "file://{images}/items/" + msg.dropped_item.replace("item_", "") + ".png"
	$("#PickupMessage_Item").SetImage(item_image_name);
//	$.Msg(item_image_name)

	$.Schedule(5, ClearDropMessage);
}

function ClearDropMessage() {
	$.GetContextPanel().SetHasClass("recent_item_drop", false);
}


(function () {
	GameEvents.Subscribe("item_will_spawn", OnItemWillSpawn);
	GameEvents.Subscribe("item_has_spawned", OnItemHasSpawned);
	GameEvents.Subscribe("overthrow_item_drop", OnItemDrop);
})();