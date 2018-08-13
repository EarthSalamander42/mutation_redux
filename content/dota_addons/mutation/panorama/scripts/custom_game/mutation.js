var mutation = [];

function Mutation(args) {
	$("#Mutations").style.visibility = "visible";
	mutation[1] = args["positive"]
	mutation[2] = args["negative"]
	mutation[3] = args["terrain"]

	$("#Mutation1Label").text = $.Localize("mutation_" + mutation[1]);
	$("#Mutation2Label").text = $.Localize("mutation_" + mutation[2]);
	$("#Mutation3Label").text = $.Localize("mutation_" + mutation[3]);

	for (var j = 1; j <= 3; j++) {
		SetMutationTooltip(j)
	}
}

(function () {
	var mutations = CustomNetTables.GetTableValue("game_options", "mutations")
	Mutation(mutations);
})();
