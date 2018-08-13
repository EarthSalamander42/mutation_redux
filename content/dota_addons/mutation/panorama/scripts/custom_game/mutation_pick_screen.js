var mutation = [];

function MutationPickScreen(args) {

	$("#MutationsPickScreen").style.visibility = "visible";
	$("#MutationsPickScreen").style.flowChildren = "right";
	$("#MutationsPickScreen").style.marginTop = "31%";
	$("#MutationsPickScreen").style.marginLeft = "46%";

	mutation[1] = args["positive"]
	mutation[2] = args["negative"]
	mutation[3] = args["terrain"]

	for (var i = 1; i <= 3; i++) {
		$("#Mutation" + i + "Label").text = $.Localize("mutation_" + mutation[i]);
	}

	for (var j = 1; j <= 3; j++) {
		SetMutationTooltip(j)
	}
}

function StartMutationPickScreen() {
	var mutations = CustomNetTables.GetTableValue("game_options", "mutations")
	if ($("#MutationsPickScreen") != undefined && mutations != undefined)
		MutationPickScreen(mutations);
	else
		$.Schedule(1.0, StartMutationPickScreen)
}

(function () {
	StartMutationPickScreen()
})();
