"use strict";

var secret_key = {};
var party_max_votes = 10;
var party_game = false;
var Parent = $.GetContextPanel().GetParent().GetParent().GetParent();

var view = {
	title: $("#loading-title-text"),
	subtitle: $("#loading-subtitle-text"),
	text: $("#loading-description-text"),
	map: $("#loading-map-text"),
	link: $("#loading-link"),
	link_text:  $("#loading-link-text")
};

var link_targets = "";

function info_already_available() {
	return Game.GetMapInfo().map_name != "";
}

function isInt(n) {
   return n % 1 === 0;
}

function LoadingScreenDebug(args) {
	$.Msg(args)
	view.text.text = view.text.text + ". \n\n" + args.text;
}

function SwitchTab(count) {
	var container = $.GetContextPanel().FindChildrenWithClassTraverse("bottom-footer-container");

	if (container && container[0]) {
		for (var i = 0; i < container[0].GetChildCount(); i++) {
			var panel = container[0].GetChild(i);
			var new_panel = container[0].GetChild(count - 1);

			if (panel == new_panel)
				panel.style.visibility = "visible";
			else
				panel.style.visibility = "collapse";
		}
	}

	var label = $("#BottomLabel");

	if (label) {
		label.text = $.Localize("#loading_screen_custom_games_" + count);
	}
}

function fetch() {
	// if data is not available yet, reschedule
	if (!info_already_available()) {
		$.Schedule(0.1, fetch);
		return;
	}

	var game_options = CustomNetTables.GetTableValue("game_options", "game_version");
	if (game_options == undefined) {
		$.Schedule(0.1, fetch);
		return;
	}

	secret_key = CustomNetTables.GetTableValue("game_options", "server_key");
	if (secret_key == undefined) {
		$.Schedule(0.1, fetch);
		return;
	} else {
		secret_key = secret_key["1"];
	}

	// if (Game.GetMapInfo().map_display_name == "imba_1v1")
		EnableVoting();
	// else if (Game.GetMapInfo().map_display_name == "imba_10v10")
		// party_max_votes = 20;

	var game_version = game_options.value;

	if (isInt(game_version))
		game_version = game_version.toString() + ".0";

	view.title.text = $.Localize("#addon_game_name") + " " + game_version;
	view.subtitle.text = $.Localize("#game_version_name").toUpperCase();


/*
	api.getLoadingScreenMessage(function(data) {
		var found_lang = false;
		var result = data.data;
		var english_row;

		for (var i in result) {
			var info = result[i];

			if (info.lang == $.Localize("#lang")) {
				view.text.text = info.content;
//				view.link_text.text = info.link_text;
				found_lang = true;
				break;
			} else if (info.lang == "en") {
				english_row = info;
			}
		}

		if (found_lang == false) {
			view.text.text = english_row.content;
//			view.link_text.text = english_row.link_text;
		}
	}, function() {
		// error callback
		$.Msg("Unable to retrieve loading screen info.")
	});
*/

	// SetPartyMaxVotes();
};

const mutation_types = [
	"Positive",
	"Negative",
	"Terrain",
]

AllPlayersLoaded();


function AllPlayersLoaded() {
	var mutations = CustomNetTables.GetTableValue("game_options", "mutation_list");
	$.Msg("ALL PLAYERS LOADED IN!");
	
	for (var mutation in mutation_types) {
		var mutation_type = mutation_types[mutation];
		var container = $.GetContextPanel().FindChildTraverse("MutationVote" + mutation_type);

		
		if (container && mutations && mutations[mutation_type.toLowerCase()]) {
			if (Game.IsInToolsMode()) {
				container.RemoveAndDeleteChildren();
			}

			var i = 1;

			while (mutations[mutation_type.toLowerCase()][i]) {
				var mutation_name = mutations[mutation_type.toLowerCase()][i];

				var panel = $.CreatePanel("Panel", container, "MutationVote" + mutation_type + i);
				panel.BLoadLayoutSnippet("MutationVote" + mutation_type + "Snippet");
				panel.FindChildTraverse("MutationVoteText").text = $.Localize("#mutation_" + mutation_name);

				if (i == 1) {
					panel.FindChildTraverse("MutationVoteText").text = panel.FindChildTraverse("MutationVoteText").text;
					// panel.FindChildTraverse("MutationVoteText").text = panel.FindChildTraverse("MutationVoteText").text + " (default)";
				}

				(function (panel, mutation_name, mutation_type) {
					panel.SetPanelEvent("onmouseover", function () {
						$.DispatchEvent("UIShowTextTooltip", panel, $.Localize("#mutation_" + mutation_name + "_description"));
					});

					panel.SetPanelEvent("onmouseout", function () {
						$.DispatchEvent("UIHideTextTooltip", panel);
					});

					panel.SetPanelEvent("onactivate", function () {
						OnVoteButtonPressed(mutation_type.toLowerCase(), mutation_name);
					});
				})(panel, mutation_name, mutation_type);

				i++;
			}
		} else {
			$.Msg("No " + mutation_type + " mutations found.");
		}
	}
}

function HoverableLoadingScreen() {
	if (Game.GameStateIs(2))
		$.GetContextPanel().style.zIndex = "1";
	else
		$.Schedule(1.0, HoverableLoadingScreen)
}

function OnVoteButtonPressed(category, vote) {
	$.Msg("Category: ", category);
	$.Msg("Vote: ", vote);
	GameEvents.SendCustomGameEventToServer("setting_vote", { "category": category, "vote": vote, "PlayerID": Game.GetLocalPlayerID() });
}

let previous_vote;

// if (Game.IsInToolsMode()) {
// 	OnVotesReceived({"table":{"1":{"1":"ultimate_level","2":1}},"category":"positive","vote":"ultimate_level"}, true);
// 	OnVotesReceived({"table":{"1":{"1":"stay_frosty","2":1}},"category":"negative","vote":"stay_frosty"}, true);
// 	OnVotesReceived({"table":{"1":{"1":"wormhole","2":1}},"category":"terrain","vote":"wormhole"}, true);
// }

/* TODO: show how many votes there is on each selections */
function OnVotesReceived(args, test) {
	// $.Msg("Received votes: ", args);
	// If voting for the same mutation, do nothing
	if (args.vote == previous_vote) {
		$.Msg("Same vote, returning");
		return;
	}

	const mutations = CustomNetTables.GetTableValue("game_options", "mutation_list");
	// $.Msg(mutations)
	// $.Msg(args);

	// Capital letter for first letter
	const category = args.category.charAt(0).toUpperCase() + args.category.slice(1);

	// Find the right column
	const column = $("#MutationVote" + category);

	// Find the right row count
	let i = 1;
	let row_count = 0;

	while (mutations[args.category][i]) {
		// $.Msg("Checking row ", i, " mutations[args.category][i]: ", mutations[args.category][i]);
		if (mutations[args.category][i] == args.vote) {
			// $.Msg("Found vote at row ", i, " for ", args.vote);
			row_count = i;
			// break;
		} else {
			// Remove the previous steam image based on the player's steam id
			const steam_image_container = column.FindChildTraverse("MutationVote" + category + i).FindChildTraverse("SteamImageContainer");

			if (steam_image_container) {
				// if (steam_image_container.GetChildCount() > 0) {
					// $.Msg("Number of votes for mutation ", mutations[args.category][i], " is ", steam_image_container.GetChildCount());
				// }

				// $.Msg(mutations[args.category][i], " - ", steam_image_container.FindChildrenWithClassTraverse("SteamImage").length);
				// if (steam_image_container.FindChildrenWithClassTraverse("SteamImage").length > 0) {
				// 	$.Msg(steam_image_container.FindChildrenWithClassTraverse("SteamImage")[0]);
				// 	$.Msg(steam_image_container.FindChildrenWithClassTraverse("SteamImage")[1]);
				// }

				for (let j = 0; j < steam_image_container.FindChildrenWithClassTraverse("SteamImage").length; j++) {
					const steam_image = steam_image_container.FindChildrenWithClassTraverse("SteamImage")[j];
					// $.Msg(steam_image);

					if (steam_image) {
						// if (steam_image.GetChild(0).steamid) {
						// 	$.Msg("Check steam image ", j , " steam id: ", steam_image.steamid, " (", Game.GetLocalPlayerInfo().player_steamid ,") for mutation ", mutations[args.category][i]);
						// }

						if (steam_image.GetChild(0).steamid == Game.GetLocalPlayerInfo().player_steamid) {
							// $.Msg("Removing steam image for SteamID: ", Game.GetLocalPlayerInfo().player_steamid , " for mutation ", mutations[args.category][i]);
							steam_image.DeleteAsync(0);
						}
					// } else {
						// $.Msg("Steam image not found for SteamID ", Game.GetLocalPlayerInfo().player_steamid);
					}
				}

				// $.Msg(steam_image);
				// $.Msg(steam_image.steamid);
				// if (steam_image.steamid == Game.GetLocalPlayerInfo().player_steamid) {
				// 	// $.Msg("Removing steam image for ", args.vote);
				// 	steam_image.DeleteAsync(0);
				// }
			}
		}

		i++;
	}

	previous_vote = args.vote;

	// Hide vote count label if there are no votes
	$.Schedule(0.01, function () {
		let j = 1;

		while (mutations[args.category][j]) {
			// Hide vote count label if there are no votes
			const vote_count = column.FindChildTraverse("MutationVote" + category + j).FindChildTraverse("SteamImageContainer").GetChildCount();

			// $.Msg("Vote count for ", mutations[args.category][j], " is ", vote_count);
			if (vote_count == 0) {
				const vote_count_label = column.FindChildTraverse("MutationVote" + category + j).FindChildTraverse("VoteCount");

				if (vote_count_label && vote_count_label.BHasClass("visible")) {
					// $.Msg("Hiding vote count for ", mutations[args.category][j]);
					// $.Msg(vote_count_label);
					vote_count_label.SetHasClass("visible", false);
				}
			}

			j++;
		}
	});

	// Find the right row
	const row = column.FindChildTraverse("MutationVote" + category + row_count);

	// Create steam image panel to show the votes
	const steam_image = $.CreatePanel("Panel", row.GetChild(0).FindChildTraverse("SteamImageContainer"), "");
	steam_image.BLoadLayoutSnippet("SteamImage");
	let steam_id = Game.GetLocalPlayerInfo().player_steamid;
	if (test) {
		steam_id = 76561198056163496;
	}

	steam_image.FindChildTraverse("AvatarImage").steamid = steam_id;

	// Set vote count label based on how many players have voted for this mutation
	const vote_count = row.GetChild(0).FindChildTraverse("SteamImageContainer").GetChildCount() - 4

	if (vote_count > 0) {
		row.GetChild(0).FindChildTraverse("VoteCount").SetDialogVariableInt("vote", vote_count);
		row.GetChild(0).FindChildTraverse("VoteCount").SetHasClass("visible", true);
	}
}

function HidePickScreenDuringGame() {
	if (Game.GetState() == 3) {
		$.GetContextPanel().style.visibility = "collapse";
	} else
		$.Schedule(1.0, HidePickScreenDuringGame);
}

(function() {
	var vote_info = $.GetContextPanel().FindChildrenWithClassTraverse("vote-info");

	if (vote_info && vote_info[0]) {
		vote_info[0].SetPanelEvent("onmouseover", function () {
			$.DispatchEvent("UIShowTextTooltip", vote_info[0], $.Localize("#vote_gamemode_description"));
		})

		vote_info[0].SetPanelEvent("onmouseout", function () {
			$.DispatchEvent("UIHideTextTooltip", vote_info[0]);
		})
	}

	var bottom_button_container = $.GetContextPanel().FindChildrenWithClassTraverse("bottom-button-container");

	if (bottom_button_container && bottom_button_container[0] && bottom_button_container[0].GetChild(0))
		bottom_button_container[0].GetChild(0).checked = true;

	HoverableLoadingScreen();
	fetch();

	if (!Game.IsInToolsMode())
		$.Schedule(1.0, HidePickScreenDuringGame); // Yeah like wtf, i really have to do this? really? like, really??

	GameEvents.Subscribe("loading_screen_debug", LoadingScreenDebug);
	GameEvents.Subscribe("send_votes", OnVotesReceived);
	GameEvents.Subscribe("all_players_loaded", AllPlayersLoaded);
})();
